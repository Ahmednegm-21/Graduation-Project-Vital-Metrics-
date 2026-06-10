import pandas as pd
import numpy as np
import re

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity


def _infer_weights(query: str):
    """
    Infer weights automatically from the user's query.

    Heuristics:
    - default: mostly name
    - if query includes nutrition keywords or numbers -> increase numeric weights
    - if 'protein' intent -> boost protein weight
    - if 'calorie/kcal/diet/low calorie' intent -> boost calories weight
    """
    q = (query or "").lower().strip()

    # defaults (name-dominant)
    w_name, w_cal, w_pro = 0.75, 0.15, 0.10

    # signals
    has_number = bool(re.search(r"\d+(\.\d+)?", q))
    has_cal_kw = any(k in q for k in ["cal", "calorie", "calories", "kcal", "diet", "cut", "low calorie", "weight loss"])
    has_pro_kw = any(k in q for k in ["protein", "high protein", "prot", "muscle"])

    # if query looks nutrition-driven, shift weight from name -> numbers
    if has_number or has_cal_kw or has_pro_kw:
        w_name, w_cal, w_pro = 0.55, 0.25, 0.20

    # boost based on explicit intent
    if has_cal_kw and not has_pro_kw:
        w_name, w_cal, w_pro = 0.55, 0.35, 0.10

    if has_pro_kw and not has_cal_kw:
        w_name, w_cal, w_pro = 0.55, 0.10, 0.35

    if has_pro_kw and has_cal_kw:
        w_name, w_cal, w_pro = 0.50, 0.25, 0.25

    # normalize
    total = w_name + w_cal + w_pro
    w_name, w_cal, w_pro = w_name / total, w_cal / total, w_pro / total
    return w_name, w_cal, w_pro


def analyze_similarity(
    df: pd.DataFrame,
    food_name: str,
    top_n: int = 5,
    drop_exact_match: bool = True
):
    """
    Auto-weights similarity based on query intent:
      - Food name similarity (TF-IDF cosine similarity)
      - Calories numeric closeness
      - Protein numeric closeness

    Returns a dataframe with:
      [Food, Similarity, Caloric_Value, Protein]
    """

    if df is None or df.empty:
        return None
    if "Food" not in df.columns:
        return None

    data = df.copy()

    # Ensure numeric cols exist
    if "Caloric_Value" not in data.columns:
        data["Caloric_Value"] = np.nan
    if "Protein" not in data.columns:
        data["Protein"] = np.nan

    # Clean text
    data["Food"] = data["Food"].astype(str).fillna("")
    query = str(food_name).strip()
    if not query:
        return None

    # infer weights automatically from query
    w_name, w_cal, w_pro = _infer_weights(query)

    # Find target row
    mask = data["Food"].str.lower().str.contains(query.lower(), na=False)
    if mask.any():
        target_idx = data[mask].index[0]
    else:
        vec_tmp = TfidfVectorizer(stop_words="english")
        tfidf_tmp = vec_tmp.fit_transform(data["Food"].tolist() + [query])
        sims_tmp = cosine_similarity(tfidf_tmp[-1], tfidf_tmp[:-1]).ravel()
        target_idx = int(np.argmax(sims_tmp))

    target_row = data.loc[target_idx]

    # 1) Name similarity
    vectorizer = TfidfVectorizer(stop_words="english")
    tfidf = vectorizer.fit_transform(data["Food"].tolist() + [target_row["Food"]])
    name_sims = cosine_similarity(tfidf[-1], tfidf[:-1]).ravel()  # 0..1

    # 2) Numeric similarity (Calories, Protein)
    cal = pd.to_numeric(data["Caloric_Value"], errors="coerce")
    pro = pd.to_numeric(data["Protein"], errors="coerce")

    target_cal = pd.to_numeric(target_row["Caloric_Value"], errors="coerce")
    target_pro = pd.to_numeric(target_row["Protein"], errors="coerce")

    # Calories similarity
    if pd.isna(target_cal):
        cal_sims = np.zeros(len(data), dtype=float)
        w_cal = 0.0
    else:
        cal_sims = 1.0 / (1.0 + (cal - float(target_cal)).abs())
        cal_sims = cal_sims.fillna(0.0).to_numpy()
        mx = cal_sims.max()
        if mx > 0:
            cal_sims = cal_sims / mx
        else:
            cal_sims = np.zeros(len(data), dtype=float)
            w_cal = 0.0

    # Protein similarity
    if pd.isna(target_pro):
        pro_sims = np.zeros(len(data), dtype=float)
        w_pro = 0.0
    else:
        pro_sims = 1.0 / (1.0 + (pro - float(target_pro)).abs())
        pro_sims = pro_sims.fillna(0.0).to_numpy()
        mx = pro_sims.max()
        if mx > 0:
            pro_sims = pro_sims / mx
        else:
            pro_sims = np.zeros(len(data), dtype=float)
            w_pro = 0.0

    # re-normalize weights if any got zeroed
    total_w = w_name + w_cal + w_pro
    if total_w == 0:
        return None
    w_name, w_cal, w_pro = w_name / total_w, w_cal / total_w, w_pro / total_w

    combined = (w_name * name_sims) + (w_cal * cal_sims) + (w_pro * pro_sims)

    out = pd.DataFrame({
        "Food": data["Food"].values,
        "Similarity": combined,
        "Caloric_Value": cal.values,
        "Protein": pro.values
    })

    if drop_exact_match and target_idx in out.index:
        out = out.drop(index=target_idx)

    out = out.sort_values("Similarity", ascending=False).head(int(top_n)).reset_index(drop=True)
    return out
