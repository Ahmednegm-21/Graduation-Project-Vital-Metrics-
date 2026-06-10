import pandas as pd


def _to_number(series: pd.Series) -> pd.Series:
    """
    Convert a pandas Series to numeric safely (handles strings like '12g', '1,234', etc.).
    """
    # Convert to string, keep digits/dot/minus, then to numeric
    s = series.astype(str).str.replace(",", "", regex=False)
    s = s.str.replace(r"[^0-9\.\-]+", "", regex=True)
    return pd.to_numeric(s, errors="coerce")


def _normalize_and_rename_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Standardize column names and map known source columns to the expected schema.
    Expected schema:
      Food, Caloric_Value, Fat, Protein, Carbohydrates
    """
    out = df.copy()

    # Strip spaces from column names
    out.columns = [c.strip() for c in out.columns]

    # Rename common dataset columns -> expected schema
    rename_map = {
        "name": "Food",
        "calories": "Caloric_Value",
        "total_fat": "Fat",
        "protein": "Protein",
        "carbohydrate": "Carbohydrates",
    }
    out = out.rename(columns=rename_map)

    # Convert macro columns to numeric if present
    for col in ["Caloric_Value", "Fat", "Protein", "Carbohydrates"]:
        if col in out.columns:
            out[col] = _to_number(out[col])

    return out


def suggest_meal(df: pd.DataFrame, target_calories: float, tolerance: float = 50):
    """
    اقتراح وجبة بناءً على السعرات المستهدفة.
    بيرجع صف واحد (Series) أو None لو مفيش نتائج.
    """

    df = _normalize_and_rename_columns(df)

    # ✅ التحقق من الأعمدة المطلوبة
    required = ["Caloric_Value"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise KeyError(
            f"❌ العمود 'Caloric_Value' غير موجود في البيانات.\n"
            f"الأعمدة الحالية هي: {list(df.columns)}"
        )

    # لو فيه NaN بعد التحويل الرقمي
    df = df.dropna(subset=["Caloric_Value"])

    # تصفية الوجبات في حدود السعرات المطلوبة
    filtered = df[
        (df["Caloric_Value"] >= target_calories - tolerance) &
        (df["Caloric_Value"] <= target_calories + tolerance)
    ]

    # في حال لم توجد نتائج
    if filtered.empty:
        return None

    # إعادة وجبة عشوائية من النتائج المطابقة
    return filtered.sample(1).iloc[0]