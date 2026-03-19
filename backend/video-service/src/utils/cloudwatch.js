const { CloudWatchClient, PutMetricDataCommand } = require("@aws-sdk/client-cloudwatch");

const client = new CloudWatchClient({
  region: process.env.AWS_REGION || "ap-south-1",
});

const NAMESPACE = "CloudFlixApp";

const sendMetric = async (metricName, value, unit = "Count") => {
  try {
    const params = {
      Namespace: NAMESPACE,
      MetricData: [
        {
          MetricName: metricName,
          Value: value,
          Unit: unit,
        },
      ],
    };

    await client.send(new PutMetricDataCommand(params));
  } catch (err) {
    console.error(
      JSON.stringify({
        level: "ERROR",
        message: "CloudWatch metric failed",
        error: err.message,
        timestamp: new Date().toISOString(),
      })
    );
  }
};

module.exports = { sendMetric };