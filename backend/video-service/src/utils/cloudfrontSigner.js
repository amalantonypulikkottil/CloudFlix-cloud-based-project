const fs = require("fs");
const cf = require("aws-cloudfront-sign");

const PRIVATE_KEY = fs.readFileSync("src/keys/private_key.pem", "utf8");

const KEY_PAIR_ID = process.env.CLOUDFRONT_KEY_PAIR_ID;

exports.getSignedUrl = (url) => {
  return cf.getSignedUrl(url, {
    keypairId: KEY_PAIR_ID,
    privateKeyString: PRIVATE_KEY,
    expireTime: Date.now() + 5 * 60 * 1000, // 5 minutes
  });
};