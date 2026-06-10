import time
import requests
from typing import List, Dict, Optional

OLLAMA_URL = "http://localhost:11434/api/chat"

# Session واحدة عشان الأداء يكون أحسن
_session = requests.Session()


def chat_messages(
    messages: List[Dict[str, str]],
    model: str = "phi3:mini",
    timeout: int = 120,
    retries: int = 2,
    options: Optional[dict] = None,
) -> str:
    """
    Send chat-style messages to Ollama and return assistant reply text.

    - Stable on 8GB RAM
    - Tuned for better JSON compliance
    - Includes retry mechanism
    """

    payload = {
        "model": model,
        "messages": messages,
        "stream": False,
        "keep_alive": "10m",  # يخلي الموديل محمل لتقليل 500 errors
        "options": options or {
            # أقل حرارة عشان يلتزم بالـ JSON وما يهبدش
            "temperature": 0.6,

            # يقلل العشوائية
            "top_p": 0.85,

            # يقلل التكرار
            "repeat_penalty": 1.2,

            # كفاية لرد طبيعي + JSON
            "num_predict": 200,

            # مناسب لـ 8GB RAM
            "num_ctx": 1536,

            # يقلل الهبد أكتر
            "top_k": 40,
        },
    }

    last_err = None

    for attempt in range(retries + 1):
        try:
            r = _session.post(OLLAMA_URL, json=payload, timeout=timeout)
            r.raise_for_status()
            data = r.json()
            return data.get("message", {}).get("content", "").strip()

        except requests.exceptions.RequestException as e:
            last_err = e

            # Retry بسيط لو حصل 500 أو timeout
            if attempt < retries:
                time.sleep(0.8 * (attempt + 1))
                continue

    raise RuntimeError(f"Ollama request failed: {last_err}")