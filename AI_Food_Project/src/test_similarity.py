# src/test_similarity.py
from src.db import load_foods
from src.ai_similarity import similarity_between, find_similar

def run_tests():
    df = load_foods("data/food.csv")
    # اختبار 1: تشابه بين أول عنصر وثاني عنصر
    a = df["Food"].iloc[0]
    b = df["Food"].iloc[1]
    sim = similarity_between(df, a, b)
    print(f"Similarity {a} vs {b}: {sim:.2f}%")

    # اختبار 2: العثور على مشابهين
    base = a
    res = find_similar(df, base, top_n=3)
    print("\nTop similar to", base)
    print(res.to_string(index=False))

if __name__ == "__main__":
    run_tests()
