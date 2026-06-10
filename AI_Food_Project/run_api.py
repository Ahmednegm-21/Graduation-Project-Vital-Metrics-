from src.api import API_HOST, API_PORT, app


if __name__ == "__main__":
    app.run(debug=True, host=API_HOST, port=API_PORT)
