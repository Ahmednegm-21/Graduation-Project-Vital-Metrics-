import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler

def get_similar_foods(food_name, dataset_path="dataset/healthy_eating_Dataset.csv", top_n=5):
    # قراءة البيانات
    df = pd.read_csv(dataset_path)
    
    # تنظيف أسماء الأعمدة من المسافات
    df.columns = df.columns.str.strip()

    # التأكد من وجود عمود food
    if "food" not in df.columns:
        raise ValueError("❌ ملف CSV يجب أن يحتوي على عمود 'food' لأسماء الأطعمة")

    # -----------------------------
    # 1️⃣ تشابه قائم على النص (اسم الطعام)
    # -----------------------------
    tfidf = TfidfVectorizer().fit_transform(df['food'].astype(str))
    text_sim = cosine_similarity(tfidf, tfidf)

    # -----------------------------
    # 2️⃣ تشابه غذائي (على أساس القيم)
    # -----------------------------
    # اختيار الأعمدة الغذائية فقط
    nutrition_cols = df.select_dtypes(include=['float64', 'int64']).columns

    # توحيد القيم
    scaler = StandardScaler()
    nutrition_scaled = scaler.fit_transform(df[nutrition_cols])

    # حساب التشابه الغذائي
    nutrition_sim = cosine_similarity(nutrition_scaled, nutrition_scaled)

    # -----------------------------
    # 3️⃣ دمج التشابهين (Hybrid Similarity)
    # -----------------------------
    alpha = 0.4   # وزن تشابه الأسماء
    beta = 0.6    # وزن القيم الغذائية

    final_sim = (alpha * text_sim) + (beta * nutrition_sim)

    # -----------------------------
    # 4️⃣ إيجاد الطعام المدخل
    # -----------------------------
    try:
        idx = df[df['food'].str.lower() == food_name.lower()].index[0]
    except IndexError:
        return f"❌ الطعام '{food_name}' غير موجود في قاعدة البيانات."

    # استخراج أعلى النتائج
    similarity_scores = list(enumerate(final_sim[idx]))
    similarity_scores = sorted(similarity_scores, key=lambda x: x[1], reverse=True)

    # إزالة نفس الطعام
    similar_indices = [i for i, score in similarity_scores[1: top_n+1]]

    # إرجاع الأسماء
    return df['food'].iloc[similar_indices].tolist()
