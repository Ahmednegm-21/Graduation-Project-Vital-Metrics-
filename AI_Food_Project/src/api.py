import os
from functools import lru_cache

import pandas as pd
from flask import Flask, jsonify, request
from flask_cors import CORS

try:
    from recommender_model import FoodRecommender
    from ai_module import suggest_meal
    from db import load_foods
except ImportError:
    from src.recommender_model import FoodRecommender
    from src.ai_module import suggest_meal
    from src.db import load_foods


app = Flask(__name__)
CORS(app)

API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "5000"))
API_KEY  = os.getenv("API_KEY", "")


# ─────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────

def success(data, **kwargs):
    return jsonify({"success": True, "data": data, **kwargs})


def fail(message, code=400):
    return jsonify({"success": False, "error": message}), code


def clean(val):
    if val is None:
        return None
    try:
        if pd.isna(val):
            return None
    except Exception:
        pass
    if isinstance(val, (int, float)):
        return round(float(val), 2)
    return str(val)


def parse_num(value, name):
    if value in (None, ""):
        return None
    try:
        return float(value)
    except (TypeError, ValueError):
        raise ValueError(f"{name} must be a number")


def parse_top_n(value, default=5):
    if value in (None, ""):
        return default
    try:
        n = int(value)
    except (TypeError, ValueError):
        raise ValueError("top_n must be an integer")
    if not (1 <= n <= 50):
        raise ValueError("top_n must be between 1 and 50")
    return n


def auth_check():
    if not API_KEY:
        return None
    if request.headers.get("X-API-Key", "") != API_KEY:
        return fail("Invalid or missing API Key", 401)
    return None


# ─────────────────────────────────────────
# Lazy loaders
# ─────────────────────────────────────────

@lru_cache(maxsize=1)
def get_recommender():
    return FoodRecommender()


@lru_cache(maxsize=1)
def get_df():
    base = os.path.dirname(os.path.abspath(__file__))
    for candidate in [
        os.path.join(base, "..", "dataset", "food.csv"),
        os.path.join(base, "dataset", "food.csv"),
    ]:
        if os.path.exists(candidate):
            return load_foods(candidate)
    raise FileNotFoundError("❌ food.csv مش موجود")


# ─────────────────────────────────────────
# CORS
# ─────────────────────────────────────────

@app.after_request
def add_cors(response):
    response.headers["Access-Control-Allow-Origin"]  = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, X-API-Key"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    return response


# ─────────────────────────────────────────
# Routes
# ─────────────────────────────────────────

@app.route("/")
def home():
    return success({
        "message": "AI Food API v2",
        "endpoints": {
            "health":    "GET  /health",
            "foods":     "GET  /foods?search=chicken&limit=20",
            "recommend": "POST /recommend",
            "suggest":   "POST /suggest",
            "similar":   "POST /similar",
        }
    })


@app.route("/health")
def health():
    return success({"status": "ok"})


# GET /foods
@app.route("/foods", methods=["GET"])
def get_foods():
    err = auth_check()
    if err:
        return err

    search = request.args.get("search", "").strip().lower()
    try:
        limit = min(int(request.args.get("limit", 20)), 100)
    except ValueError:
        limit = 20

    try:
        df = get_df()
        if search:
            df = df[df["Food"].str.lower().str.contains(search, na=False)]
        df = df.head(limit)

        items = [
            {
                "food":          clean(r.get("Food")),
                "calories":      clean(r.get("Caloric_Value")),
                "protein":       clean(r.get("Protein")),
                "fat":           clean(r.get("Fat")),
                "carbohydrates": clean(r.get("Carbohydrates")),
            }
            for _, r in df.iterrows()
        ]
        return success(items, count=len(items))

    except Exception as e:
        return fail(str(e), 500)


# POST /recommend
@app.route("/recommend", methods=["POST", "OPTIONS"])
def recommend():
    if request.method == "OPTIONS":
        return ("", 204)

    err = auth_check()
    if err:
        return err

    try:
        d        = request.get_json(silent=True) or {}
        query    = str(d.get("query", "meal")).strip() or "meal"
        calories = parse_num(d.get("calories"), "calories")
        protein  = parse_num(d.get("protein"),  "protein")
        fat      = parse_num(d.get("fat"),       "fat")
        carbs    = parse_num(d.get("carbs", d.get("carbohydrates")), "carbs")
        top_n    = parse_top_n(d.get("top_n", 5))

        result = get_recommender().recommend(
            query_text=query,
            calories=calories, protein=protein,
            fat=fat, carbs=carbs, top_n=top_n,
        )

        if result is None or len(result) == 0:
            return success([], count=0, message="No results found")

        items = [
            {
                "food":          clean(r.get("Food")),
                "calories":      clean(r.get("Caloric_Value")),
                "protein":       clean(r.get("Protein")),
                "fat":           clean(r.get("Fat")),
                "carbohydrates": clean(r.get("Carbohydrates")),
                "similarity":    clean(r.get("similarity")),
            }
            for _, r in result.iterrows()
        ]
        return success(items, count=len(items), query=query)

    except ValueError as e:
        return fail(str(e), 400)
    except Exception as e:
        return fail(str(e), 500)


# POST /suggest
@app.route("/suggest", methods=["POST", "OPTIONS"])
def suggest():
    if request.method == "OPTIONS":
        return ("", 204)

    err = auth_check()
    if err:
        return err

    try:
        d         = request.get_json(silent=True) or {}
        calories  = parse_num(d.get("calories"), "calories")
        weight    = float(d.get("weight",    100) or 100)
        tolerance = float(d.get("tolerance",  50) or 50)

        if calories is None:
            return fail("calories is required", 400)

        meal = suggest_meal(get_df(), calories, tolerance=tolerance)

        if meal is None:
            return success(None, message="No meal found in this calorie range")

        factor = weight / 100.0

        def s(col):
            v = meal.get(col)
            return round(float(v) * factor, 2) if v is not None and not pd.isna(v) else None

        return success({
            "food":          str(meal.get("Food", "")),
            "weight_g":      weight,
            "calories":      s("Caloric_Value"),
            "protein":       s("Protein"),
            "fat":           s("Fat"),
            "carbohydrates": s("Carbohydrates"),
        })

    except ValueError as e:
        return fail(str(e), 400)
    except Exception as e:
        return fail(str(e), 500)


# POST /similar
@app.route("/similar", methods=["POST", "OPTIONS"])
def similar():
    if request.method == "OPTIONS":
        return ("", 204)

    err = auth_check()
    if err:
        return err

    try:
        d         = request.get_json(silent=True) or {}
        food_name = str(d.get("food_name", "")).strip()
        top_n     = parse_top_n(d.get("top_n", 5))

        if not food_name:
            return fail("food_name is required", 400)

        result = get_recommender().recommend(query_text=food_name, top_n=top_n)

        if result is None or len(result) == 0:
            return success([], count=0, message="No similar foods found")

        items = [
            {
                "food":          clean(r.get("Food")),
                "calories":      clean(r.get("Caloric_Value")),
                "protein":       clean(r.get("Protein")),
                "fat":           clean(r.get("Fat")),
                "carbohydrates": clean(r.get("Carbohydrates")),
                "similarity":    clean(r.get("similarity")),
            }
            for _, r in result.iterrows()
        ]
        return success(items, count=len(items), query=food_name)

    except ValueError as e:
        return fail(str(e), 400)
    except Exception as e:
        return fail(str(e), 500)


if __name__ == "__main__":
    app.run(debug=True, host=API_HOST, port=API_PORT)