const express = require("express");
const router = express.Router();

const { getProfile, updateProfile,createUser } = require("../controllers/userController");

const { verifyToken } = require("../middleware/authMiddleware");

router.post("/create", createUser);
router.get("/profile", verifyToken, getProfile);
router.put("/profile", verifyToken, updateProfile);

module.exports = router;