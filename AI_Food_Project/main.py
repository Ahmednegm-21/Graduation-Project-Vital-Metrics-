from src.db import load_foods
from src.ai_module import suggest_meal
from src.ai_advanced import analyze_similarity

print("🤖 أهلاً بك في مشروع الذكاء الاصطناعي الغذائي!")
print("1️⃣ اقتراح وجبة حسب السعرات")
print("2️⃣ إيجاد وجبات مشابهة غذائيًا\n")

choice = input("اختر العملية (1 أو 2): ")

# تحميل البيانات
df = load_foods("dataset/food.csv")

if choice == "1":
    target = int(input("أدخل عدد السعرات المطلوبة: "))
    meal = suggest_meal(df, target)
    if meal is not None:
        print("\n🍽️ الوجبة المقترحة:")
        print(f"اسم الوجبة: {meal['Food']}")
        print(f"السعرات: {meal['Calories']}")
        print(f"البروتين: {meal['Protein (g)']} جم")
        print(f"الدهون: {meal['Fat (g)']} جم")
        print(f"الكربوهيدرات: {meal['Carbohydrates (g)']} جم")
    else:
        print("❌ لا توجد وجبة مناسبة.")
elif choice == "2":
    base_food = input("أدخل اسم الوجبة التي تريد إيجاد وجبات مشابهة لها: ")
    similar = analyze_similarity(df, base_food)
    if similar is not None:
        print("\n🔍 وجبات مشابهة غذائيًا:")
        print(similar[["Food", "Similarity"]].to_string(index=False))
else:
    print("❌ خيار غير صالح.")
