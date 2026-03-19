const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Video = sequelize.define("Video", {

  title: {
    type: DataTypes.STRING
  },

  description: {
    type: DataTypes.TEXT
  },

  file: {
    type: DataTypes.STRING
  },

  url: {
    type: DataTypes.TEXT
  },

  thumbnail: {
    type: DataTypes.TEXT
  },

  views: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }

});

module.exports = Video;