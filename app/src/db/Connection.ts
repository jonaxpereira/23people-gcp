const { Sequelize } = require('sequelize');

export const sequelize = new Sequelize('postgres://jonaxpereira:changeme@127.0.0.1:5432/23people');