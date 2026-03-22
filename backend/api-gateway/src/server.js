const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authProxy = require("./routes/authProxy");
const userProxy = require("./routes/userProxy");
const videoProxy = require("./routes/videoProxy");

const app = express();

// ✅ FIRST → parse body
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ CORS
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// ✅ Logger
app.use((req, res, next) => {
  console.log("Gateway:", req.method, req.url);
  console.log("Gateway Body:", req.body); // 🔥 debug
  next();
});

// ✅ Routes AFTER middleware
app.use("/auth", authProxy);
app.use("/users", userProxy);
app.use("/videos", videoProxy);

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});