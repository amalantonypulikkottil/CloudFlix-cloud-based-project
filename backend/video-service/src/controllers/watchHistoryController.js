const dynamoDB = require("../config/dynamo");
const { UpdateCommand, QueryCommand } = require("@aws-sdk/lib-dynamodb");

exports.saveWatchProgress = async (req, res) => {
  console.log("📥 Incoming Request");
  const userId =1;

  //const userId = req.user?.id;
  const { videoId, progress, durationWatched } = req.body;

  // ✅ Validation
  if (!userId) return res.status(401).json({ error: "Unauthorized" });

  if (!videoId || progress == null || durationWatched == null) {
    return res.status(400).json({ error: "Missing fields" });
  }

  try {
    console.log("🔥 Watch Progress:", { userId, videoId, progress, durationWatched });

    const result = await dynamoDB.send(
      new UpdateCommand({
        TableName: "WatchHistory",
        Key: {
          userId: userId.toString(),
          videoId: videoId.toString(),
        },
        UpdateExpression:
          "SET progress = :p, durationWatched = :d, watchedAt = :t",
        ExpressionAttributeValues: {
          ":p": progress,
          ":d": durationWatched,
          ":t": new Date().toISOString(),
        },
        ReturnValues: "ALL_NEW",
      })
    );

    console.log("✅ Updated Item:", result.Attributes);

    res.json({
      message: "Progress saved",
      updatedItem: result.Attributes,
    });
  } catch (error) {
    console.error("❌ Error:", error);
    res.status(500).json({
      error: "Failed to save progress",
      details: error.message,
    });
  }
};


exports.getWatchHistory = async (req, res) => {
  const userId = req.user?.id;

  if (!userId) {
    return res.status(401).json({ error: "Unauthorized" });
  }

  try {
    console.log("📥 Fetching history for:", userId);

    const result = await dynamoDB.send(
      new QueryCommand({
        TableName: "WatchHistory",
        KeyConditionExpression: "userId = :uid",
        ExpressionAttributeValues: {
          ":uid": userId.toString(),
        },
        ScanIndexForward: false, // 🔥 latest first
      })
    );

    console.log("✅ History:", result.Items);

    res.json({
      message: "Watch history fetched",
      data: result.Items,
    });
  } catch (error) {
    console.error("❌ Error fetching history:", error);
    res.status(500).json({
      error: "Failed to fetch watch history",
      details: error.message,
    });
  }
};