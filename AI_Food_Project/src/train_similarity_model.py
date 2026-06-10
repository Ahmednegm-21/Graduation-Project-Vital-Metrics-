import os, re, joblib
import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import NearestNeighbors

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(BASE_DIR, "dataset", "food.csv")
OUT_DIR = os.path.join(BASE_DIR, "models")
os.makedirs(OUT_DIR, exist_ok=True)

def to_number(x):
    if pd.isna(x):
        return np.nan
    s = str(x).strip().lower()
    s = re.sub(r"[^0-9.\-]+", "", s)  # keep only digits, dot, minus
    try:
        return float(s) if s else np.nan
    except:
        return np.nan

def load_and_prepare(path):
    df = pd.read_csv(path)
    df.columns = (
        df.columns.astype(str).str.strip()
        .str.replace("\ufeff","", regex=False)
        .str.replace(" ", "_", regex=False)
        .str.replace("-", "_", regex=False)
    )

    if "Unnamed:_0" in df.columns:
        df = df.drop(columns=["Unnamed:_0"])

    df = df.rename(columns={
        "name":"Food",
        "calories":"Caloric_Value",
        "total_fat":"Fat",
        "protein":"Protein",
        "carbohydrate":"Carbohydrates",
    })

    for c in ["Food","Caloric_Value","Protein","Fat","Carbohydrates"]:
        if c not in df.columns:
            df[c] = np.nan

    df["Food"] = df["Food"].astype(str).fillna("").str.strip()
    for c in ["Caloric_Value","Protein","Fat","Carbohydrates"]:
        df[c] = df[c].apply(to_number)

    return df[df["Food"]!=""].reset_index(drop=True)

def main():
    print("📦 Loading data...")
    df = load_and_prepare(CSV_PATH)
    print("✅ Rows:", len(df))

    model_name = "all-MiniLM-L6-v2"
    model = SentenceTransformer(model_name)

    print("🧠 Encoding food names...")
    text_emb = model.encode(df["Food"].tolist(), normalize_embeddings=True)

    num_cols = ["Caloric_Value","Protein","Fat","Carbohydrates"]
    X_num = df[num_cols].fillna(0.0).to_numpy().astype(np.float32)

    scaler = StandardScaler()
    X_num_scaled = scaler.fit_transform(X_num) * 0.3
    X = np.hstack([text_emb, X_num_scaled]).astype(np.float32)

    print("📍 Building Nearest Neighbors...")
    nn = NearestNeighbors(n_neighbors=30, metric="cosine")
    nn.fit(X)

    df.to_pickle(os.path.join(OUT_DIR, "foods.pkl"))
    joblib.dump(scaler, os.path.join(OUT_DIR, "scaler.joblib"))
    joblib.dump(nn, os.path.join(OUT_DIR, "nn.joblib"))
    joblib.dump(X, os.path.join(OUT_DIR, "X.joblib"))

    with open(os.path.join(OUT_DIR, "text_model.txt"), "w") as f:
        f.write(model_name)
    with open(os.path.join(OUT_DIR, "num_cols.txt"), "w") as f:
        f.write(",".join(num_cols))
    print("✅ Training finished!")

if __name__ == "__main__":
    main()