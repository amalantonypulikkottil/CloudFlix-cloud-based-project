const express = require("express");
const axios = require("axios");

const router = express.Router();

const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL;

router.post("/register", async (req, res) => {

  try {

    const response = await axios.post(
      `${AUTH_SERVICE_URL}/auth/register`,
      req.body
    );

    res.json(response.data);

  } catch (error) {

    res.status(500).json({
      message: "Auth service error"
    });

  }

});

router.post("/login", async (req, res) => {

  try {

    const response = await axios.post(
      `${AUTH_SERVICE_URL}/auth/login`,
      req.body
    );

    res.json(response.data);

  } catch (error) {

    res.status(500).json({
      message: "Auth service error"
    });

  }

});

module.exports = router;