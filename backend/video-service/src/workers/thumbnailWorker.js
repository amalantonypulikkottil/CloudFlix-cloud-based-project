const {
  SQSClient,
  ReceiveMessageCommand,
  DeleteMessageCommand,
} = require("@aws-sdk/client-sqs");

const {
  S3Client,
  GetObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const sqs = new SQSClient({ region: "ap-south-2" });
const s3 = new S3Client({ region: "ap-south-2" });

const QUEUE_URL = process.env.THUMBNAIL_QUEUE_URL;

const pollMessages = async () => {
  console.log("🖼️ Thumbnail Worker Started...");

  while (true) {
    try {
      const data = await sqs.send(
        new ReceiveMessageCommand({
          QueueUrl: QUEUE_URL,
          MaxNumberOfMessages: 1,
          WaitTimeSeconds: 10,
        })
      );

      if (!data.Messages) continue;

      for (const message of data.Messages) {
        try {
          const body = JSON.parse(message.Body);
          const event = JSON.parse(body.Message);

          if (event.eventType === "VIDEO_UPLOADED") {
            const { bucket, key, videoName } = event.data;

            console.log("🖼️ Generating thumbnail:", videoName);

            // ✅ Create tmp folder
            const dir = path.join(__dirname, "../../tmp");

            if (!fs.existsSync(dir)) {
              fs.mkdirSync(dir, { recursive: true });
            }

            const videoPath = path.join(dir, `${videoName}.mp4`);
            const thumbnailPath = path.join(dir, `${videoName}.jpg`);

            // ✅ Download video from S3
            const video = await s3.send(
              new GetObjectCommand({ Bucket: bucket, Key: key })
            );

            const stream = await video.Body.transformToByteArray();
            fs.writeFileSync(videoPath, Buffer.from(stream));

            // ✅ Generate thumbnail
            execSync(
              `ffmpeg -i "${videoPath}" -ss 00:00:01 -vframes 1 "${thumbnailPath}"`
            );

            // ✅ Upload thumbnail to S3
            const thumbnailKey = `thumbnails/${videoName}.jpg`;

            await s3.send(
              new PutObjectCommand({
                Bucket: bucket,
                Key: thumbnailKey,
                Body: fs.readFileSync(thumbnailPath),
                ContentType: "image/jpeg",
              })
            );

            console.log("✅ Thumbnail uploaded:", thumbnailKey);

            // ✅ Optional cleanup
            fs.unlinkSync(videoPath);
            fs.unlinkSync(thumbnailPath);
          }

          // ✅ Delete message ONLY after success
          await sqs.send(
            new DeleteMessageCommand({
              QueueUrl: QUEUE_URL,
              ReceiptHandle: message.ReceiptHandle,
            })
          );

        } catch (innerErr) {
          console.error("❌ Processing Error:", innerErr);
          // ❌ DO NOT delete message → SQS will retry
        }
      }
    } catch (err) {
      console.error("❌ Worker Error:", err);
    }
  }
};

module.exports = pollMessages;