# api.py  —  AI Food API v2  (FastAPI)
# تشغيل: uvicorn api:app --host 0.0.0.0 --port 8502 --reload

import os
from functools import lru_cache
from typing import Optional

import pandas as pd
from fastapi import FastAPI, Header, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

try:
    from recommender_model import FoodRecommender
    from ai_module import suggest_meal
except ImportError:
    from src.recommender_model import FoodRecommender
    from src.ai_module import suggest_meal


# ─────────────────────────────────────────
# App & Config
# ─────────────────────────────────────────

app = FastAPI(
    title="AI Food API",
    version="2.0.0",
    description="Food recommendation API powered by AI",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type", "X-API-Key"],
)

API_KEY = os.getenv("API_KEY", "")


# ─────────────────────────────────────────
# Request / Response Models
# ─────────────────────────────────────────

class RecommendRequest(BaseModel):
    query:    str             = Field(default="meal", description="Search query")
    calories: Optional[float] = Field(default=None)
    protein:  Optional[float] = Field(default=None)
    fat:      Optional[float] = Field(default=None)
    carbs:    Optional[float] = Field(default=None)
    top_n:    int             = Field(default=5, ge=1, le=10000)


class SuggestRequest(BaseModel):
    calories:  float = Field(..., description="Target calories (required)")
    weight:    float = Field(default=100.0)
    tolerance: float = Field(default=50.0)


class SimilarRequest(BaseModel):
    food_name: str = Field(..., description="Food name to find similar items for")
    top_n:     int = Field(default=5, ge=1, le=10000)


# ─────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────

def success(data, **kwargs):
    return {"success": True, "data": data, **kwargs}


def clean(val, default=0.0):
    if val is None:
        return default
    try:
        if pd.isna(val):
            return default
    except Exception:
        pass
    if isinstance(val, (int, float)):
        return round(float(val), 2)
    try:
        cleaned = (
            str(val)
            .replace("g", "")
            .replace("kcal", "")
            .replace(",", ".")
            .strip()
        )
        return round(float(cleaned), 2)
    except Exception:
        return default


def clean_str(val) -> str:
    if val is None:
        return ""
    try:
        if pd.isna(val):
            return ""
    except Exception:
        pass
    return str(val).strip()


def auth_check(x_api_key: Optional[str]):
    if not API_KEY:
        return
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid or missing API Key")


def _get(row: dict, *keys):
    for k in keys:
        v = row.get(k)
        if v is not None:
            return v
    return None


# ─────────────────────────────────────────
# Lazy loader
# ─────────────────────────────────────────

@lru_cache(maxsize=1)
def get_recommender() -> FoodRecommender:
    return FoodRecommender()


# ─────────────────────────────────────────
# Row serializers
# ─────────────────────────────────────────

def food_row_to_dict(r: dict) -> dict:
    return {
        "food":          clean_str(_get(r, "Food", "food")),
        "calories":      clean(_get(r, "Caloric_Value", "calories", "Calories")),
        "protein":       clean(_get(r, "Protein", "protein")),
        "fat":           clean(_get(r, "Fat", "fat")),
        "carbohydrates": clean(_get(r, "Carbohydrates", "carbohydrates", "carbs")),
    }


def food_row_with_similarity(r: dict) -> dict:
    return {**food_row_to_dict(r), "similarity": clean(r.get("similarity"))}


# ─────────────────────────────────────────
# Global error handler
# ─────────────────────────────────────────

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"success": False, "error": str(exc)},
    )


# ─────────────────────────────────────────
# Routes
# ─────────────────────────────────────────

@app.get("/")
def home():
    return success({
        "message": "AI Food API v2",
        "endpoints": {
            "health":    "GET  /health",
            "foods":     "GET  /foods?search=chicken",
            "recommend": "POST /recommend",
            "suggest":   "POST /suggest",
            "similar":   "POST /similar",
        }
    })


@app.get("/health")
def health():
    return success({"status": "ok"})


@app.get("/foods")
def get_foods(
    search:    Optional[str] = Query(default=None),
    limit:     Optional[int] = Query(default=None, ge=1),
    x_api_key: Optional[str] = Header(default=None),
):
    auth_check(x_api_key)
    try:
        # نقرأ من الـ pickle مباشرة عشان الـ columns صح
        df = get_recommender().df.copy()

        if search:
            mask = df["Food"].astype(str).str.lower().str.contains(
                search.strip().lower(), na=False
            )
            df = df[mask]

        if limit is not None:
            df = df.head(limit)

        items = [food_row_to_dict(r) for _, r in df.iterrows()]
        return success(items, count=len(items))

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/recommend")
def recommend(
    body: RecommendRequest,
    x_api_key: Optional[str] = Header(default=None),
):
    auth_check(x_api_key)
    try:
        query = body.query.strip() or "meal"

        result = get_recommender().recommend(
            query_text=query,
            calories=body.calories,
            protein=body.protein,
            fat=body.fat,
            carbs=body.carbs,
            top_n=body.top_n,
        )

        if result is None or len(result) == 0:
            return success([], count=0, message="No results found")

        items = [food_row_with_similarity(r) for _, r in result.iterrows()]
        return success(items, count=len(items), query=query)

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/suggest")
def suggest(
    body: SuggestRequest,
    x_api_key: Optional[str] = Header(default=None),
):
    auth_check(x_api_key)
    try:
        # نستخدم الـ pickle هنا كمان
        df = get_recommender().df.copy()
        meal = suggest_meal(df, body.calories, tolerance=body.tolerance)

        if meal is None:
            return success(None, message="No meal found in this calorie range")

        factor = body.weight / 100.0

        def scale(*keys):
            v = _get(meal, *keys)
            if v is None:
                return 0.0
            try:
                if pd.isna(v):
                    return 0.0
            except Exception:
                pass
            return round(float(v) * factor, 2)

        return success({
            "food":          clean_str(_get(meal, "Food", "food")),
            "weight_g":      body.weight,
            "calories":      scale("Caloric_Value", "calories", "Calories"),
            "protein":       scale("Protein", "protein"),
            "fat":           scale("Fat", "fat"),
            "carbohydrates": scale("Carbohydrates", "carbohydrates", "carbs"),
        })

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/similar")
def similar(
    body: SimilarRequest,
    x_api_key: Optional[str] = Header(default=None),
):
    auth_check(x_api_key)
    try:
        result = get_recommender().recommend(
            query_text=body.food_name,
            top_n=body.top_n,
        )

        if result is None or len(result) == 0:
            return success([], count=0, message="No similar foods found")

        items = [food_row_with_similarity(r) for _, r in result.iterrows()]
        return success(items, count=len(items), query=body.food_name)

    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ─────────────────────────────────────────
# Entry point
# ─────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    host = os.getenv("API_HOST", "0.0.0.0")
    port = int(os.getenv("API_PORT", "8502"))
    uvicorn.run("api:app", host=host, port=port, reload=True)