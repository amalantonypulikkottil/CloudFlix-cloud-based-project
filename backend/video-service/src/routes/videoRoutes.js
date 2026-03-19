const express = require("express");
const router = express.Router();

const {
  uploadVideo,
  getVideos,
  playVideo
} = require("../controllers/videoController");

const upload = require("../middleware/upload");
const authMiddleware = require("../../../auth-service/src/middleware/authMiddleware");

router.post("/upload", authMiddleware, upload.single("video"), uploadVideo);

router.get("/",authMiddleware, getVideos);

router.get("/play/:id",authMiddleware, playVideo);

module.exports = router;