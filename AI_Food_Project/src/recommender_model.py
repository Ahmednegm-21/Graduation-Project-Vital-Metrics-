import os
import joblib
import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer

_THIS = os.path.dirname(os.path.abspath(__file__))

for _candidate in [
    os.path.join(_THIS, "..", "models"),
    os.path.join(_THIS, "models"),
]:
    if os.path.isdir(_candidate):
        MODEL_DIR = os.path.abspath(_candidate)
        break
else:
    MODEL_DIR = os.path.abspath(os.path.join(_THIS, "..", "models"))


class FoodRecommender:
    def __init__(self):
        self._load_models()

    def _load_models(self):
        foods_path      = os.path.join(MODEL_DIR, "foods.pkl")
        scaler_path     = os.path.join(MODEL_DIR, "scaler.joblib")
        nn_path         = os.path.join(MODEL_DIR, "nn.joblib")
        text_model_path = os.path.join(MODEL_DIR, "text_model.txt")
        num_cols_path   = os.path.join(MODEL_DIR, "num_cols.txt")

        for p in [foods_path, scaler_path, nn_path, text_model_path, num_cols_path]:
            if not os.path.exists(p):
                raise FileNotFoundError(
                    f"❌ ملف الموديل مش موجود: {p}\n"
                    f"شغّل train_similarity_model.py الأول."
                )

        self.df     = pd.read_pickle(foods_path)
        self.scaler = joblib.load(scaler_path)
        self.nn     = joblib.load(nn_path)

        # ── DEBUG: print real column names from pickle ──────────────────────
        print("=== PKL COLUMNS ===", self.df.columns.tolist())
        print("=== PKL FIRST ROW ===", self.df.iloc[0].to_dict())
        # ────────────────────────────────────────────────────────────────────

        with open(text_model_path, "r") as f:
            model_name = f.read().strip()
        self.text_model = SentenceTransformer(model_name)

        with open(num_cols_path, "r") as f:
            self.num_cols = f.read().strip().split(",")

    def recommend(
        self,
        query_text: str,
        calories: float = None,
        protein: float = None,
        fat: float = None,
        carbs: float = None,
        top_n: int = 5,
    ) -> pd.DataFrame:

        emb = self.text_model.encode(
            [query_text], normalize_embeddings=True
        )

        nums = np.array([[
            calories or 0.0,
            protein  or 0.0,
            fat      or 0.0,
            carbs    or 0.0,
        ]], dtype=np.float32)

        nums_scaled = self.scaler.transform(nums) * 0.3
        X_query     = np.hstack([emb, nums_scaled])

        k = min(top_n + 10, len(self.df))
        distances, indices = self.nn.kneighbors(X_query, n_neighbors=k)

        results = self.df.iloc[indices[0]].copy()
        results["similarity"] = (1 - distances[0]).round(4)

        return results.head(top_n).reset_index(drop=True)