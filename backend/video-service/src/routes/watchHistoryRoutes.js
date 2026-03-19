const express = require("express");
const router = express.Router();

const { saveWatchProgress, getWatchHistory } = require("../controllers/watchHistoryController");
const authMiddleware = require("../../../auth-service/src/middleware/authMiddleware");

// ✅ Route
router.post("/progress", authMiddleware, saveWatchProgress);
router.get("/history", authMiddleware, getWatchHistory);

module.exports = router;