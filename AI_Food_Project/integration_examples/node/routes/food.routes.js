const express = require('express');

const router = express.Router();
const PYTHON_FOOD_API_BASE_URL =
  process.env.PYTHON_FOOD_API_BASE_URL || 'http://127.0.0.1:5000';

router.get('/health', async (_req, res) => {
  try {
    const response = await fetch(`${PYTHON_FOOD_API_BASE_URL}/health`);
    const data = await response.json();
    return res.status(response.status).json(data);
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

router.post('/recommend', async (req, res) => {
  try {
    const response = await fetch(`${PYTHON_FOOD_API_BASE_URL}/recommend`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        query: req.body.query,
        calories: req.body.calories,
        protein: req.body.protein,
        fat: req.body.fat,
        carbs: req.body.carbs,
        top_n: req.body.top_n ?? req.body.topN ?? 5,
      }),
    });

    const data = await response.json();
    return res.status(response.status).json(data);
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

module.exports = router;
