# AI Food API Integration

## 1. Files already prepared in this project

- `F:\AI_Food_Project\src\api.py`
- `F:\AI_Food_Project\run_api.py`
- `F:\AI_Food_Project\requirements-api.txt`
- `F:\AI_Food_Project\.env.example`
- `F:\AI_Food_Project\integration_examples\flutter\lib\services\food_api_service.dart`
- `F:\AI_Food_Project\integration_examples\node\routes\food.routes.js`

## 2. Install dependencies

Use the virtual environment that you want to run the API with, then install:

```powershell
F:\AI_Food_Project\venv\Scripts\python.exe -m pip install -r F:\AI_Food_Project\requirements-api.txt
```

## 3. Run the Python API

```powershell
F:\AI_Food_Project\venv\Scripts\python.exe F:\AI_Food_Project\run_api.py
```

The API will run on:

```text
http://127.0.0.1:5000
```

## 4. Available endpoints

### Health check

```http
GET /health
```

### Recommendation endpoint

```http
POST /recommend
Content-Type: application/json
```

Body:

```json
{
  "query": "high protein chicken meal",
  "calories": 400,
  "protein": 30,
  "fat": 10,
  "carbs": 20,
  "top_n": 5
}
```

Response:

```json
{
  "success": true,
  "count": 5,
  "query": "high protein chicken meal",
  "filters": {
    "calories": 400.0,
    "protein": 30.0,
    "fat": 10.0,
    "carbs": 20.0
  },
  "results": [
    {
      "food": "Example Food",
      "calories": 120.0,
      "protein": 20.0,
      "fat": 5.0,
      "carbohydrates": 10.0,
      "similarity": 0.88
    }
  ]
}
```

## 5. Add it to Flutter

Copy this file:

```text
F:\AI_Food_Project\integration_examples\flutter\lib\services\food_api_service.dart
```

Into your Flutter project at:

```text
<your_flutter_project>\lib\services\food_api_service.dart
```

Then add the package to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.1
```

If you test on Android emulator, use:

```text
http://10.0.2.2:5000
```

If you test on real device or web, use your computer local IP:

```text
http://192.168.x.x:5000
```

## 6. Add it to Node.js backend

Copy this file:

```text
F:\AI_Food_Project\integration_examples\node\routes\food.routes.js
```

Into your Node.js project at:

```text
<your_node_project>\routes\food.routes.js
```

Then mount it in your main server file:

```js
const foodRoutes = require('./routes/food.routes');
app.use('/api/food', foodRoutes);
```

Set this environment variable in Node.js:

```text
PYTHON_FOOD_API_BASE_URL=http://127.0.0.1:5000
```

## 7. Suggested frontend flow

### Direct from Flutter

Flutter -> Python API `/recommend`

### Through Node.js backend

Flutter -> Node.js `/api/food/recommend` -> Python API `/recommend`

Using Node.js as a middle layer is better if you want:

- auth later
- logging
- rate limit
- one backend entry point

## 8. Important note

The saved sklearn model files were created with a different sklearn version than the one currently installed in one of your environments. If you see warnings, install the version required by `requirements-api.txt` or retrain/save the model with the version you actually use in production.