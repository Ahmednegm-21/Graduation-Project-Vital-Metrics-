import pandas as pd
import os


def load_foods(csv_path: str) -> pd.DataFrame:
    """
    تحميل بيانات الأكل من CSV وتنظيف الأعمدة.
    """
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"❌ ملف البيانات مش موجود:\n{csv_path}")

    df = pd.read_csv(csv_path)

    # تنظيف أسماء الأعمدة
    df.columns = (
        df.columns
        .str.strip()
        .str.replace('\xa0', ' ', regex=False)
        .str.replace(' ', '_', regex=False)
        .str.replace('\ufeff', '', regex=False)
    )

    # إعادة تسمية الأعمدة للـ schema الموحد
    df = df.rename(columns={
        "food":                       "Food",
        "name":                       "Food",
        "Calories_(kcal_per_100g)":   "Caloric_Value",
        "calories":                   "Caloric_Value",
        "Protein_(g_per_100g)":       "Protein",
        "protein":                    "Protein",
        "Fat_(g_per_100g)":           "Fat",
        "total_fat":                  "Fat",
        "Carbohydrates_(g_per_100g)": "Carbohydrates",
        "carbohydrate":               "Carbohydrates",
        "Sugars_(g_per_100g)":        "Sugars",
        "Dietary_Fiber_(g_per_100g)": "Fiber",
    })

    # تحويل الأعمدة الرقمية
    for col in ["Caloric_Value", "Protein", "Fat", "Carbohydrates"]:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    return df