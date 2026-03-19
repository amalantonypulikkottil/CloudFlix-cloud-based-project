const {
    SQSClient,
    ReceiveMessageCommand,
    DeleteMessageCommand,
} = require("@aws-sdk/client-sqs");

const {
    MediaConvertClient,
    CreateJobCommand,
} = require("@aws-sdk/client-mediaconvert");

const sqs = new SQSClient({ region: "ap-south-2" });

const mediaconvert = new MediaConvertClient({
    region: "ap-south-1",
    endpoint: process.env.MEDIACONVERT_ENDPOINT,
});

const QUEUE_URL = process.env.TRANSCODE_QUEUE_URL;

const pollMessages = async () => {
    console.log("🎬 Transcode Worker Started...");

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
                const body = JSON.parse(message.Body);
                const event = JSON.parse(body.Message);

                if (event.eventType === "VIDEO_UPLOADED") {
                    const { bucket, key, videoName } = event.data;

                    console.log("🎬 Processing:", videoName);

                    const params = {
                        Role: process.env.MEDIACONVERT_ROLE,
                        Settings: {
                            TimecodeConfig: { Source: "ZEROBASED" },
                            Inputs: [
                                {
                                    FileInput: `s3://${bucket}/${key}`,
                                    AudioSelectors: {
                                        "Audio Selector 1": { DefaultSelection: "DEFAULT" },
                                    },
                                    VideoSelector: {},
                                },
                            ],
                            OutputGroups: [
                                {
                                    Name: "HLS Group",
                                    OutputGroupSettings: {
                                        Type: "HLS_GROUP_SETTINGS",
                                        HlsGroupSettings: {
                                            Destination: `s3://${bucket}/hls-output/${videoName}/`,
                                            SegmentLength: 10,
                                            MinSegmentLength: 0,   // ✅ REQUIRED (capital M)
                                            DirectoryStructure: "SINGLE_DIRECTORY"
                                        }
                                    },
                                    Outputs: [
                                        {
                                            NameModifier: "_360p",
                                            ContainerSettings: { Container: "M3U8" },
                                            VideoDescription: {
                                                Width: 640,
                                                Height: 360,
                                                CodecSettings: {
                                                    Codec: "H_264",
                                                    H264Settings: {
                                                        RateControlMode: "QVBR",
                                                        QvbrQualityLevel: 7,
                                                        MaxBitrate: 1000000,
                                                    },
                                                },
                                            },
                                            AudioDescriptions: [
                                                {
                                                    AudioSourceName: "Audio Selector 1",
                                                    CodecSettings: {
                                                        Codec: "AAC",
                                                        AacSettings: {
                                                            Bitrate: 96000,
                                                            CodingMode: "CODING_MODE_2_0",
                                                            SampleRate: 48000,
                                                        },
                                                    },
                                                },
                                            ],
                                        },
                                    ],
                                },
                            ],
                        },
                    };

                    const command = new CreateJobCommand(params);
                    const response = await mediaconvert.send(command);

                    console.log("✅ MediaConvert Job:", response.Job.Id);
                }

                // ✅ Delete message after success
                await sqs.send(
                    new DeleteMessageCommand({
                        QueueUrl: QUEUE_URL,
                        ReceiptHandle: message.ReceiptHandle,
                    })
                );
            }
        } catch (err) {
            console.error("❌ Transcode Worker Error:", err);
        }
    }
};

module.exports = pollMessages;