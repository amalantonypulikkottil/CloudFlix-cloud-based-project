const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authProxy = require("./routes/authProxy");
const userProxy = require("./routes/userProxy");
const videoProxy = require("./routes/videoProxy");
const app = express();

app.use(cors({
     origin: '*', // Allow all origins
     methods: ['GET', 'POST', 'PUT', 'DELETE'],
     allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use((req,res,next)=>{
  console.log("Gateway:", req.method, req.url);
  next();
});

app.use("/auth", authProxy);
app.use("/users", userProxy);
app.use("/videos", videoProxy);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});