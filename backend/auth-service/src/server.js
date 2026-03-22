require("dotenv").config();

const express = require("express");
const cors = require("cors");

const sequelize = require("./models/db");
const authRoutes = require("./routes/authRoutes");

const app = express();

// ✅ Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Logging middleware (FIXED with next())
app.use((req, res, next) => {
  console.log(
    JSON.stringify({
      level: "INFO",
      service: "auth-service",
      method: req.method,
      url: req.url,
      timestamp: new Date().toISOString(),
    })
  );

  next(); // ✅ important
});

// ✅ Routes
app.use("/auth", authRoutes);

// ✅ Health check (optional but useful)
app.get("/", (req, res) => {
  res.send("Auth Service is running...");
});

// ✅ Port
const PORT = process.env.PORT || 4001;

// ✅ DB + Server start
sequelize
  .sync()
  .then(() => {
    console.log("Database connected");

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Auth Service running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("DB connection failed:", err);
  });