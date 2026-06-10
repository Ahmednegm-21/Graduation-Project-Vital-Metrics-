import tkinter as tk
from tkinter import messagebox
from db import load_foods
from ai_module import suggest_meal
from ai_advanced import analyze_similarity
import os

# تحديد المسار الكامل لملف البيانات بشكل آمن
csv_path = os.path.join(os.path.dirname(__file__), '..', 'dataset', 'food.csv')

# تحميل البيانات مرة واحدة
df = load_foods(csv_path)

# إنشاء النافذة الأساسية
root = tk.Tk()
root.title("🍽️ AI Food Assistant")
root.geometry("650x500")
root.config(bg="#f0f4f7")

# العنوان الرئيسي
title = tk.Label(root, text="🤖 الذكاء الاصطناعي للوجبات", font=("Arial", 18, "bold"), bg="#f0f4f7", fg="#333")
title.pack(pady=15)

# إطار رئيسي
frame = tk.Frame(root, bg="#ffffff", bd=2, relief="groove")
frame.pack(pady=20, padx=20, fill="both", expand=True)

# --- قسم اقتراح الوجبات حسب السعرات ---
section1 = tk.LabelFrame(frame, text="اقتراح وجبة حسب السعرات", font=("Arial", 12, "bold"), bg="#ffffff", fg="#2c3e50", padx=10, pady=10)
section1.pack(fill="x", padx=10, pady=10)

tk.Label(section1, text="عدد السعرات المطلوبة:", bg="#ffffff").grid(row=0, column=0, sticky="w")
calories_entry = tk.Entry(section1, width=15)
calories_entry.grid(row=0, column=1, padx=10)

def suggest_meal_action():
    try:
        target = int(calories_entry.get())
        meal = suggest_meal(df, target)
        if meal is not None:
            result = (
                f"🍽️ اسم الوجبة: {meal['food']}\n"
                f"🔥 السعرات: {meal['Caloric_Value']}\n"
                f"💪 البروتين: {meal['Protein']} جم\n"
                f"🥑 الدهون: {meal['Fat']} جم\n"
                f"🍞 الكربوهيدرات: {meal['Carbohydrates']} جم"
            )
            messagebox.showinfo("نتيجة الاقتراح", result)
        else:
            messagebox.showwarning("تنبيه", "❌ لا توجد وجبة مناسبة في هذا النطاق.")
    except ValueError:
        messagebox.showerror("خطأ", "الرجاء إدخال رقم صحيح!")

tk.Button(section1, text="اقترح وجبة", command=suggest_meal_action, bg="#27ae60", fg="white", width=15).grid(row=0, column=2, padx=10)

# --- قسم التحليل الغذائي ---
section2 = tk.LabelFrame(frame, text="تحليل التشابه الغذائي", font=("Arial", 12, "bold"), bg="#ffffff", fg="#2c3e50", padx=10, pady=10)
section2.pack(fill="x", padx=10, pady=10)

tk.Label(section2, text="اسم الوجبة:", bg="#ffffff").grid(row=0, column=0, sticky="w")
food_entry = tk.Entry(section2, width=25)
food_entry.grid(row=0, column=1, padx=10)

result_box = tk.Text(section2, height=8, width=60, wrap="word", state="disabled")
result_box.grid(row=2, column=0, columnspan=3, pady=10)

def analyze_action():
    base_food = food_entry.get().strip()
    if not base_food:
        messagebox.showwarning("تنبيه", "من فضلك أدخل اسم الوجبة أولًا.")
        return

    similar = analyze_similarity(df, base_food)
    if similar is None:
        messagebox.showerror("خطأ", "❌ الوجبة غير موجودة في البيانات.")
        return

    result_box.config(state="normal")
    result_box.delete("1.0", tk.END)
    result_box.insert(tk.END, "🔍 وجبات مشابهة غذائيًا:\n\n")
    for _, row in similar.iterrows():
        result_box.insert(tk.END, f"🍴 {row['Food']} — التشابه: {row['Similarity']:.2f}\n")
    result_box.config(state="disabled")

tk.Button(section2, text="تحليل التشابه", command=analyze_action, bg="#2980b9", fg="white", width=15).grid(row=0, column=2, padx=10)

# --- زر الخروج ---
exit_btn = tk.Button(root, text="خروج", command=root.destroy, bg="#e74c3c", fg="white", font=("Arial", 12), width=10)
exit_btn.pack(pady=10)

# تشغيل التطبيق
root.mainloop()
