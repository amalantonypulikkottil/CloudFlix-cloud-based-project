const express = require("express");
const cors = require("cors");
require("dotenv").config();
const sequelize = require("./config/database");
const { connectRedis } = require("./config/redis");

const videoRoutes = require("./routes/videoRoutes");
const watchHistoryRoutes = require("./routes/watchHistoryRoutes");

const startTranscodeWorker = require("./workers/transcodeWorker");
const startThumbnailWorker = require("./workers/thumbnailWorker");
const { sendMetric } = require("./utils/cloudwatch");

const app = express();
express.urlencoded();
app.use(express.json());

// app.use(cors({
//      origin: '*', // Allow all origins
//      methods: ['GET', 'POST', 'PUT', 'DELETE'],
//      allowedHeaders: ['Content-Type', 'Authorization']
// }));

app.use(
  cors({
    origin: true,
    credentials: true,
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use((req, res, next) => {
  const start = Date.now();

  console.log(
    JSON.stringify({
      level: "INFO",
      service: "video-service",
      method: req.method,
      url: req.url,
      timestamp: new Date().toISOString(),
    })
  );

  res.on("finish", async () => {
    const latency = Date.now() - start;

    // 🔥 Send metrics
    await sendMetric("RequestCount", 1);
    await sendMetric("Latency", latency, "Milliseconds");

    console.log(
      JSON.stringify({
        level: "INFO",
        message: "Request completed",
        statusCode: res.statusCode,
        latency,
        timestamp: new Date().toISOString(),
      })
    );
  });

  next();
});

app.use("/watch", watchHistoryRoutes);
app.use("/s", videoRoutes);

const PORT = process.env.PORT || 4003;

sequelize.sync();
connectRedis();

// Start workers
startTranscodeWorker();
startThumbnailWorker();

app.listen(PORT, () => {
  console.log(`Video Service running on port ${PORT}`);
});