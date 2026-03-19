const Video = require("../models/Videos");
require("dotenv").config();
const { client: redis } = require("../config/redis");
const { getSignedUrl } = require("../utils/cloudfrontSigner");
const { getSignedCookies } = require("../utils/cloudfrontCookies");
const { sendMetric } = require("../utils/cloudwatch");

/* ==============================
   Upload Video (S3 + HLS Setup)
================================ */

exports.uploadVideo = async (req, res) => {
    const CLOUDFRONT_URL = process.env.AWS_CLOUDFRONT_URL;

    try {
        const { title, description } = req.body;

        const videoKey = req.file.key;
        const videoName = videoKey.split("/").pop().split(".")[0];

        const videoUrl = `${CLOUDFRONT_URL}/hls-output/${videoName}/${videoName}.m3u8`;
        const thumbnailKey = `thumbnails/${videoName}.jpg`;
        const thumbnailUrl = `${CLOUDFRONT_URL}/${thumbnailKey}`;

        const video = await Video.create({
            title,
            description,
            file: videoKey,
            url: videoUrl,
            thumbnail: thumbnailUrl,
            views: 0,
        });

        // 🔥 Invalidate cache
        await redis.del("videos");

        console.log(
            JSON.stringify({
                level: "INFO",
                message: "Video uploaded",
                videoId: video.id,
                timestamp: new Date().toISOString(),
            })
        );

        await sendMetric("VideoUploadSuccess", 1);

        res.json({
            message: "Video uploaded successfully",
            video,
        });
    } catch (error) {
        console.error(
            JSON.stringify({
                level: "ERROR",
                message: "Upload failed",
                error: error.message,
                timestamp: new Date().toISOString(),
            })
        );
        await sendMetric("VideoUploadError", 1);

        res.status(500).json({
            message: "Upload failed",
            error: error.message,
        });
    }
};



/* ==============================
   Get All Videos
================================ */

exports.getVideos = async (req, res) => {
    const cacheKey = "videos";

    try {
        // 🔥 1. Check cache
        const cached = await redis.get(cacheKey);

        if (cached) {
            cconsole.log(
                JSON.stringify({
                    level: "INFO",
                    message: "Cache HIT",
                    timestamp: new Date().toISOString(),
                })
            );
            return res.json(JSON.parse(cached));
        }

        console.log(
            JSON.stringify({
                level: "INFO",
                message: "Cache MISS",
                timestamp: new Date().toISOString(),
            })
        );

        // 🔥 2. DB call
        const videos = await Video.findAll({
            order: [["createdAt", "DESC"]],
        });

        const formattedVideos = videos.map((video) => ({
            id: video.id,
            title: video.title,
            description: video.description,
            videoUrl: video.url,
            thumbnailUrl: video.thumbnail,
            uploadedAt: video.createdAt,
            views: video.views,
        }));

        // 🔥 3. Store in Redis (TTL 60 sec)
        await redis.setEx(cacheKey, 60, JSON.stringify(formattedVideos));

        console.log(
            JSON.stringify({
                level: "INFO",
                message: "Fetching videos",
                timestamp: new Date().toISOString(),
            })
        );
        await sendMetric("GetVideosSuccess", 1);

        res.json(formattedVideos);
    } catch (error) {
        console.error(
            JSON.stringify({
                level: "ERROR",
                message: "Get videos failed",
                error: error.message,
                timestamp: new Date().toISOString(),
            })
        );
        await sendMetric("GetVideosError", 1);
        res.status(500).json({
            message: "Failed to fetch videos",
            error: error.message,
        });
    }
};



/* ==============================
   Play Video (Increase Views)
================================ */

exports.playVideo = async (req, res) => {
    try {
        const id = req.params.id;

        const video = await Video.findByPk(id);

        if (!video) {
            return res.status(404).json({ message: "Video not found" });
        }

        // 🔥 Generate signed cookies
        const cookies = getSignedCookies(video.url);

        res.cookie("CloudFront-Policy", cookies["CloudFront-Policy"], {
            httpOnly: true,
            secure: false,        // 🔥 changed
            sameSite: "lax",      // 🔥 added
        });

        res.cookie("CloudFront-Signature", cookies["CloudFront-Signature"], {
            httpOnly: true,
            secure: false,        // 🔥 changed
            sameSite: "lax",
        });

        res.cookie("CloudFront-Key-Pair-Id", cookies["CloudFront-Key-Pair-Id"], {
            httpOnly: true,
            secure: false,        // 🔥 changed
            sameSite: "lax",
        });

        // Increase views
        video.views += 1;
        await video.save();

        console.log(
            JSON.stringify({
                level: "INFO",
                message: "Video played",
                videoId: id,
                timestamp: new Date().toISOString(),
            })
        );

        await sendMetric("VideoPlay", 1);

        res.json({
            videoUrl: video.url, // 🔥 NORMAL URL (no signing here)
            thumbnailUrl: video.thumbnail,
        });
    } catch (error) {
        console.error(
            JSON.stringify({
                level: "ERROR",
                message: "Play video failed",
                error: error.message,
                timestamp: new Date().toISOString(),
            })
        );

        await sendMetric("VideoPlayError", 1);
        res.status(500).json({
            message: "Play video failed",
            error: error.message,
        });
    }
};

exports.getWatchHistory = async (req, res) => {
    const userId = req.user?.id;
    const cacheKey = `history:${userId}`;

    if (!userId) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    try {
        // 🔥 Check cache
        const cached = await redis.get(cacheKey);

        if (cached) {
            console.log(
                JSON.stringify({
                    level: "INFO",
                    message: "History Cache HIT",
                    timestamp: new Date().toISOString(),
                })
            );
            await sendMetric("WatchHistoryRequest", 1);
            return res.json({
                message: "Watch history fetched",
                data: JSON.parse(cached),
            });
        }

        const result = await dynamoDB.send(
            new QueryCommand({
                TableName: "WatchHistory",
                KeyConditionExpression: "userId = :uid",
                ExpressionAttributeValues: {
                    ":uid": userId.toString(),
                },
                ScanIndexForward: false,
            })
        );

        // 🔥 Store cache
        await redis.setEx(cacheKey, 60, JSON.stringify(result.Items));

        res.json({
            message: "Watch history fetched",
            data: result.Items,
        });
    } catch (error) {
        console.error(
            JSON.stringify({
                level: "ERROR",
                message: "Watch history failed",
                error: error.message,
                timestamp: new Date().toISOString(),
            })
        );

        await sendMetric("WatchHistoryError", 1);
        res.status(500).json({
            error: "Failed to fetch watch history",
            details: error.message,
        });
    }
};