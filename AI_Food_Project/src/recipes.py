from src.db import conn

def save_recipe(name, foods, calories):
    c = conn.cursor()
    c.execute("INSERT INTO recipes (name, foods, calories) VALUES (?, ?, ?)",
              (name, foods, calories))
    conn.commit()
    print(f"✅ تم حفظ الوصفة ({name}) بنجاح!")

def list_recipes():
    c = conn.cursor()
    c.execute("SELECT * FROM recipes")
    rows = c.fetchall()
    print("📖 قائمة الوصفات المحفوظة:\n")
    print("  Meal Name\t\tFoods\t\tTotal Calories")
    for row in rows:
        print(f"{row[1]}\t{row[2]}\t{row[3]}")

def delete_recipe(name):
    c = conn.cursor()
    c.execute("DELETE FROM recipes WHERE name=?", (name,))
    conn.commit()
    print(f"🗑️ تم حذف الوصفة ({name}) بنجاح!")

if __name__ == "__main__":
    # تجربة الكود
    save_recipe("Healthy Lunch", "Rice, Chicken, Salad", 520)
    list_recipes()
    delete_recipe("Healthy Lunch")
