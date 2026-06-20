# ai_module.py

import pandas as pd


def _to_number(series: pd.Series) -> pd.Series:
    """
    Convert a pandas Series to numeric safely.
    Handles strings like '12g', '1,234', etc.
    """
    s = series.astype(str).str.replace(",", "", regex=False)
    s = s.str.replace(r"[^0-9\.\-]+", "", regex=True)
    return pd.to_numeric(s, errors="coerce")


def _normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Standardize column names and map known variants to the expected schema:
      Food, Caloric_Value, Fat, Protein, Carbohydrates
    """
    out = df.copy()

    # Strip whitespace + BOM from column names
    out.columns = (
        out.columns.astype(str)
        .str.strip()
        .str.replace("\ufeff", "", regex=False)
        .str.replace(" ", "_", regex=False)
        .str.replace("-", "_", regex=False)
    )

    # Drop unnamed index column if present
    if "Unnamed:_0" in out.columns:
        out = out.drop(columns=["Unnamed:_0"])

    # Map common alternative names → expected schema
    rename_map = {
        "name":        "Food",
        "calories":    "Caloric_Value",
        "total_fat":   "Fat",
        "protein":     "Protein",
        "carbohydrate": "Carbohydrates",
        "carbs":       "Carbohydrates",
    }
    out = out.rename(columns={k: v for k, v in rename_map.items() if k in out.columns})

    # Convert macro columns to numeric
    for col in ["Caloric_Value", "Fat", "Protein", "Carbohydrates"]:
        if col in out.columns:
            out[col] = _to_number(out[col])

    return out


def suggest_meal(
    df: pd.DataFrame,
    target_calories: float,
    tolerance: float = 50.0,
) -> pd.Series | None:
    """
    Suggest a random meal whose calorie value is within
    [target_calories - tolerance, target_calories + tolerance].

    Returns a pandas Series (one row) or None if nothing matches.
    """
    df = _normalize_columns(df)

    # Validate required column
    if "Caloric_Value" not in df.columns:
        raise KeyError(
            f"العمود 'Caloric_Value' غير موجود.\n"
            f"الأعمدة الحالية: {list(df.columns)}"
        )

    # Drop rows where calorie value is NaN
    df = df.dropna(subset=["Caloric_Value"])

    # Filter by calorie range
    mask = (
        (df["Caloric_Value"] >= target_calories - tolerance) &
        (df["Caloric_Value"] <= target_calories + tolerance)
    )
    filtered = df[mask]

    if filtered.empty:
        return None

    # Return one random matching row as a dict-like Series
    return filtered.sample(1).iloc[0]