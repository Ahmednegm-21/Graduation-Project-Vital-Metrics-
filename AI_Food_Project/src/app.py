import os
import re
import json
from pathlib import Path

import streamlit as st
import pandas as pd

st.set_page_config(page_title="AI Food Assistant", page_icon="🍽️", layout="wide")

from db import load_foods
from ai_module import suggest_meal
from recommender_model import FoodRecommender
from chat_ollama import chat_messages  
def to_number(x):
    if x is None:
        return None
    return pd.to_numeric(
        str(x).replace("g", "").replace("kcal", "").replace(",", ".").strip(),
        errors="coerce"
    )
def prepare_food_df(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = (
        df.columns.astype(str)
        .str.strip()
        .str.replace("\ufeff", "", regex=False)
        .str.replace(" ", "_", regex=False)
        .str.replace("-", "_", regex=False)
    )

    if "Unnamed:_0" in df.columns:
        df = df.drop(columns=["Unnamed:_0"])

    df = df.rename(columns={
        "name": "Food",
        "calories": "Caloric_Value",
        "total_fat": "Fat",
        "protein": "Protein",
        "carbohydrate": "Carbohydrates",
    })

    for col in ["Protein", "Fat", "Carbohydrates", "Caloric_Value"]:
        if col in df.columns:
            df[col] = df[col].apply(to_number)

    return df
def is_english_text(text: str) -> bool:
    latin = len(re.findall(r"[A-Za-z]", text))
    arabic = len(re.findall(r"[\u0600-\u06FF]", text))
    return latin >= arabic

def make_english_search_query(user_msg: str, model_name: str = "phi3:mini") -> str:
    """
    (موجودة زي ما هي) Convert Arabic/English user message into a compact English query for searching English-only dataset.
    Returns ONLY the query.
    NOTE: بعد التعديل الجديد، صفحة الشات مش بتستخدمها عشان بقينا نطلع search_en من نفس نداء Ollama.
    """
    user_msg = str(user_msg).strip()
    if not user_msg:
        return "high protein low calorie meal"

    # If already English: keep it short (fast, no LLM call)
    if is_english_text(user_msg):
        q = " ".join(user_msg.split())
        return q[:140]

    # Arabic -> English query via Ollama (لو هتستخدمها في مكان تاني)
    prompt = f"""
Convert this Arabic food request into a SHORT English search query for a food recommender.

Rules:
- Output ONLY the English query (no extra text).
- Max 10 words.
- Use nutrition keywords when relevant: high protein, low calorie, low fat, low carb, etc.
- If user asks for a meal, include a food category (chicken, fish, salad, soup, beef, eggs, yogurt, oats...).

Arabic request:
{user_msg}
"""
    # هنا محتاج chat() القديمة لو هتستخدم الدالة دي
    # فسيبها مش مستخدمة في الشات الجديد
    return "high protein low calorie meal"


# ------------------------------------------
# Load data (SAFE)
# ------------------------------------------
APP_DIR = Path(__file__).resolve().parent
BASE_DIR = APP_DIR.parent  # <-- assumes src/app.py
csv_path = BASE_DIR / "dataset" / "food.csv"

try:
    df = load_foods(str(csv_path))
    df = prepare_food_df(df)
except Exception as e:
    st.error(f"❌ مش قادر أقرأ ملف البيانات:\n\nPath: {csv_path}\n\nError: {e}")
    st.stop()


# ------------------------------------------
# Load trained recommender once (SAFE)
# ------------------------------------------
@st.cache_resource
def get_recommender():
    return FoodRecommender()


try:
    rec = get_recommender()
except Exception as e:
    st.error(f"❌ مشكلة في تحميل موديل الـ Similarity:\n\n{e}")
    st.info("تأكد إن فولدر models موجود وفيه الملفات المطلوبة.")
    st.stop()


# ------------------------------------------
# CSS (clean modern)
# ------------------------------------------
st.markdown("""
<style>
.big-title{
    font-size:34px !important;
    font-weight:800;
    text-align:center;
    margin-top:6px;
    margin-bottom:0px;
}
.sub-title{
    text-align:center;
    color:#6b7280;
    margin-top:2px;
    margin-bottom:18px;
}
.section-title{
    font-size:22px !important;
    font-weight:800;
    margin: 10px 0 14px 0;
}
.card{
    background: white;
    padding: 18px;
    border-radius: 16px;
    border: 1px solid rgba(0,0,0,0.06);
    box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}
.hr{
    height:1px;
    background: rgba(0,0,0,0.08);
    margin: 10px 0 14px 0;
}
.small-muted{
    color:#6b7280;
    font-size: 13px;
}
</style>
""", unsafe_allow_html=True)


# ------------------------------------------
# Header
# ------------------------------------------
st.markdown('<div class="big-title">🍽️ AI Food Assistant</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-title">Meal suggestion + Similarity (Trained model) + Chat (Ollama)</div>', unsafe_allow_html=True)


# ------------------------------------------
# Sidebar Navigation
# ------------------------------------------
with st.sidebar:
    st.markdown("## 🍽️ Navigation")
    st.caption("Choose a tool")
    choice = st.radio(
        " ",
        ["🏠 Home", "🔥 Meal Suggestion", "🔍 Similarity Analysis", "💬 Chat (Ollama)"],
        index=1
    )
    st.markdown('<div class="hr"></div>', unsafe_allow_html=True)
    st.markdown("### ⚙️ Tips")
    st.markdown(
        "<div class='small-muted'>"
        "• Meal Suggestion: اختر السعرات والوزن.<br>"
        "• Similarity: اكتب اسم أكلة أو وصف (high protein / low calorie).<br>"
        "• Chat: اكتب عربي أو إنجليزي — البحث هيشتغل بدقة على الداتا الإنجليزي."
        "</div>",
        unsafe_allow_html=True
    )


# =========================================================
# Home
# =========================================================
if choice == "🏠 Home":
    st.markdown('<div class="section-title">🏠 Home</div>', unsafe_allow_html=True)

    st.markdown('<div class="card">', unsafe_allow_html=True)
    st.write("👋 Welcome! This app helps you:")
    st.write("✅ Suggest meals based on calories")
    st.write("✅ Find similar foods using **trained embedding model**")
    st.write("✅ Chat locally using **Ollama (phi3:mini)** + show recommendations")
    st.write("✅ Arabic/English input supported (search uses English query for accuracy)")
    st.markdown("</div>", unsafe_allow_html=True)


# =========================================================
# Meal Suggestion
# =========================================================
elif choice == "🔥 Meal Suggestion":
    st.markdown('<div class="section-title">🔥 Meal Suggestion</div>', unsafe_allow_html=True)

    st.markdown('<div class="card">', unsafe_allow_html=True)
    col1, col2 = st.columns(2)

    with col1:
        calories = st.number_input("Enter calories (kcal):", min_value=50, max_value=2000, step=10)

    with col2:
        weight_g = st.number_input("Enter weight (g):", min_value=1, max_value=2000, value=100, step=10)

    if st.button("🍽️ Suggest Meal"):
        meal = suggest_meal(df, calories)

        if meal is None:
            st.error("❌ No meal found within this range.")
        else:
            st.success("🎯 Best matching meal found!")

            food_name = meal.get("Food", "Unknown")
            cal = meal.get("Caloric_Value", None)
            prot = meal.get("Protein", None)
            fat = meal.get("Fat", None)
            carbs = meal.get("Carbohydrates", None)

            factor = weight_g / 100.0

            st.write(f"🍽 **Meal:** {food_name}")
            st.write(f"⚖️ **Weight:** {weight_g} g")

            if pd.notna(cal):
                st.write(f"🔥 **Calories:** {(cal * factor):.1f} kcal")
            if pd.notna(prot):
                st.write(f"💪 **Protein:** {(prot * factor):.1f} g")
            if pd.notna(fat):
                st.write(f"🥑 **Fat:** {(fat * factor):.1f} g")
            if pd.notna(carbs):
                st.write(f"🍞 **Carbohydrates:** {(carbs * factor):.1f} g")

    st.markdown("</div>", unsafe_allow_html=True)


# =========================================================
# Similarity Analysis (Trained Model)
# =========================================================
elif choice == "🔍 Similarity Analysis":
    st.markdown('<div class="section-title">🔍 Similarity Analysis (Trained model)</div>', unsafe_allow_html=True)

    st.markdown('<div class="card">', unsafe_allow_html=True)

    query_text = st.text_input(
        "Enter food name / description:",
        placeholder="e.g., soup | high protein beef | low calorie chicken"
    )

    top_n = st.slider("Number of results:", min_value=3, max_value=30, value=5, step=1)

    st.markdown("### Optional nutrition targets (leave 0 to ignore)")
    c1, c2, c3, c4 = st.columns(4)
    with c1:
        calories = st.number_input("Calories", min_value=0.0, value=0.0, step=10.0)
    with c2:
        protein = st.number_input("Protein", min_value=0.0, value=0.0, step=1.0)
    with c3:
        fat = st.number_input("Fat", min_value=0.0, value=0.0, step=1.0)
    with c4:
        carbs = st.number_input("Carbs", min_value=0.0, value=0.0, step=1.0)

    if st.button("🔍 Start Analysis"):
        if not query_text.strip():
            st.warning("اكتب اسم الأكلة أو وصف (مثال: high protein chicken).")
        else:
            try:
                res = rec.recommend(
                    query_text,
                    top_n=top_n,
                    calories=(calories if calories > 0 else None),
                    protein=(protein if protein > 0 else None),
                    fat=(fat if fat > 0 else None),
                    carbs=(carbs if carbs > 0 else None),
                )

                if res is None or len(res) == 0:
                    st.error("❌ No similar foods found.")
                else:
                    st.success("✅ Similar foods found!")
                    show_cols = ["Food", "Caloric_Value", "Protein", "Fat", "Carbohydrates"]
                    if "similarity" in res.columns:
                        show_cols.append("similarity")
                    st.dataframe(res[show_cols], use_container_width=True)

            except Exception as e:
                st.error(f"❌ Similarity error: {e}")

    st.markdown("</div>", unsafe_allow_html=True)


# =========================================================
# Chat (Ollama) + Recommendations (ONE CALL + REAL HISTORY)
# =========================================================
elif choice == "💬 Chat (Ollama)":
    st.markdown('<div class="section-title">💬 Chat (Ollama phi3:mini)</div>', unsafe_allow_html=True)
    st.markdown('<div class="card">', unsafe_allow_html=True)

    # Warm-up مرة واحدة لتقليل 500
    if "ollama_warmed" not in st.session_state:
        st.session_state.ollama_warmed = True
        try:
            _ = chat_messages(
                [
                    {"role": "system", "content": "Say ready in one word."},
                    {"role": "user", "content": "ready?"}
                ],
                model="phi3:mini",
                retries=0
            )
        except Exception:
            pass

    SYSTEM = """You are a nutrition assistant.

IMPORTANT:
You MUST output ONLY valid JSON.
No explanations.
No text before or after.
No markdown.

Format EXACTLY like this:

{
  "reply_ar": "Arabic reply here",
  "search_en": "short english search query here"
}

Rules:
- reply_ar: natural Egyptian Arabic answer.
- search_en: max 10 English words.
- ALWAYS include a food category word like:
  chicken, beef, fish, eggs, yogurt, oats, salad, rice, soup.
"""

    def _safe_json(text: str) -> dict:
        text = str(text or "")
        m = re.search(r"\{.*\}", text, flags=re.S)
        if not m:
            return {}
        try:
            return json.loads(m.group(0))
        except Exception:
            return {}

    if "chat" not in st.session_state:
        st.session_state.chat = []  # [("user","..."), ("assistant","...")]

    # Show history (UI)
    for role, msg in st.session_state.chat:
        with st.chat_message(role):
            st.write(str(msg))

    user_msg = st.chat_input("اكتب سؤالك هنا… (مثال: عايز وجبة قليلة السعرات وعالية البروتين)")
    if user_msg:
        # 1) Save + show user message
        st.session_state.chat.append(("user", user_msg))
        with st.chat_message("user"):
            st.write(user_msg)

        # 2) Build model history from UI history (last 10 messages)
        history_msgs = []
        for role, msg in st.session_state.chat[-10:]:
            history_msgs.append({
                "role": "assistant" if role == "assistant" else "user",
                "content": str(msg)
            })

        # IMPORTANT: history already includes the latest user message, so no need to add it again.
        messages = [{"role": "system", "content": SYSTEM}] + history_msgs

        with st.chat_message("assistant"):
            reply = ""
            search_q = ""

            try:
                raw = chat_messages(messages, model="phi3:mini")
                raw = raw if isinstance(raw, str) else str(raw)

                obj = _safe_json(raw)

                reply = obj.get("reply_ar", "")
                reply = reply if isinstance(reply, str) else str(reply or "")
                reply = reply.strip() or raw.strip()

                search_q = obj.get("search_en", "")
                search_q = search_q if isinstance(search_q, str) else str(search_q or "")
                search_q = search_q.strip()

                st.write(reply)

                if search_q:
                    st.caption(f"🔎 Search used: `{search_q}`")
                    st.markdown("**🍽️ اقتراحات أكلات قريبة من كلامك:**")

                    rec_df = rec.recommend(search_q, top_n=8)
                    show_cols = ["Food", "Caloric_Value", "Protein", "Fat", "Carbohydrates"]
                    if rec_df is not None and len(rec_df) > 0:
                        if "similarity" in rec_df.columns:
                            show_cols.append("similarity")
                        st.dataframe(rec_df[show_cols], use_container_width=True)
                    else:
                        st.info("مفيش اقتراحات كفاية من الريكوميندر.")
                else:
                    st.info("مفيش search query رجعت من الموديل.")

            except Exception as e:
                st.error(f"❌ Chat error: {e}")

        # 4) Save assistant reply
        if reply:
            st.session_state.chat.append(("assistant", reply))

    st.markdown("</div>", unsafe_allow_html=True)