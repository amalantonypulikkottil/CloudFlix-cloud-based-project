const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(
  "cloudflix",
  "root",
  "yourpassword",
  {
    host: "localhost",
    dialect: "mysql"
  }
);

module.exports = sequelize;