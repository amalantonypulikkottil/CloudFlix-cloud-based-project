const express = require("express");
const axios = require("axios");

const router = express.Router();

const USER_SERVICE_URL = process.env.USER_SERVICE_URL;

router.get("/profile", async (req, res) => {

  try {

    const response = await axios.get(
      `${USER_SERVICE_URL}/users/profile`,
      { headers: req.headers }
    );

    res.json(response.data);

  } catch (error) {

    res.status(500).json({ message: "User service error" });

  }

});

module.exports = router;