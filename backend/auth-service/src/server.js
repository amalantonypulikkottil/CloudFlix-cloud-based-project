require("dotenv").config();

const express = require("express");
const cors = require("cors");

const sequelize = require("./models/db");
const authRoutes = require("./routes/authRoutes");

const app = express();

app.use(cors());
app.use(express.json());
express.urlencoded()

app.use("/auth", authRoutes);

const PORT = process.env.PORT || 4001;

sequelize.sync()
  .then(() => {
    console.log("Database connected");
    app.listen(PORT, () =>
      console.log(`Auth Service running on port ${PORT}`)
    );
  });

