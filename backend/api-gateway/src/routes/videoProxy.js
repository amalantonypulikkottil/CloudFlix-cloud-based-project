const { createProxyMiddleware } = require("http-proxy-middleware");

const VIDEO_SERVICE_URL = process.env.VIDEO_SERVICE_URL;

const videoProxy = createProxyMiddleware({
  target: VIDEO_SERVICE_URL,
  changeOrigin: true,

  pathRewrite: (path) => {
    console.log("➡️ Incoming Path:", path);
    return path.replace(/^\/videos/, ""); // remove /videos
  },

  onProxyReq: (proxyReq, req, res) => {
    console.log("🚀 Proxying:", VIDEO_SERVICE_URL + proxyReq.path);

    // 🔥 FIX: Re-send JSON body
    if (req.body && Object.keys(req.body).length) {
      const bodyData = JSON.stringify(req.body);

      proxyReq.setHeader("Content-Type", "application/json");
      proxyReq.setHeader("Content-Length", Buffer.byteLength(bodyData));

      proxyReq.write(bodyData);
    }
  },

  onError: (err, req, res) => {
    console.error("❌ Proxy Error:", err.message);
    res.status(500).json({ error: "Proxy failed" });
  }
});

module.exports = videoProxy;