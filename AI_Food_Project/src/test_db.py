import streamlit as st

# 1. استيراد الدالة
from src.db import load_foods

# 2. تحميل البيانات
df = load_foods("dataset/food.csv")

# 3. شكل البيانات وعمودان مهمان
print("Shape:", df.shape)
print("Columns:", list(df.columns))

# 4. لمحة سريعة: أول 5 صفوف
print(df.head().to_string(index=False))

# 5. إحصاءات وصفية للأعمدة الرقمية
print(df.describe(include='all').to_string())

from src.db import load_foods

df = load_foods("dataset/food.csv")
print("Shape:", df.shape)
print("Columns:", list(df.columns))
print(df.head().to_string(index=False))

st.markdown("---")
st.subheader("📖 عرض الوصفات المحفوظة")

from src.recipes import view_recipes
import os

if os.path.exists("data/saved_recipes.csv"):
    df = view_recipes()
    if df is not None:
        st.dataframe(df)
else:
    st.info("لا توجد وصفات محفوظة بعد.")
