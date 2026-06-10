"""
wsgi.py — Production entry point
يُستخدم مع Gunicorn:
    gunicorn wsgi:app
"""
from src.api import app  # noqa: F401

if __name__ == "__main__":
    app.run()