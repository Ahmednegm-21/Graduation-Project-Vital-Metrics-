from src.recommender_model import FoodRecommender

rec = FoodRecommender()

print("\nTest 1: high protein chicken meal\n")
res1 = rec.recommend("high protein chicken meal", top_n=5)
print(res1[["Food","Protein","Carbohydrates","similarity"]])

print("\nTest 2: high protein low carb\n")
res2 = rec.recommend("meal", protein=40, carbs=10, top_n=5)
print(res2[["Food","Protein","Carbohydrates","similarity"]])
