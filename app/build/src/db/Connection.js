"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sequelize = void 0;
const { Sequelize } = require('sequelize');
exports.sequelize = new Sequelize('postgres://jonaxpereira:changeme@34.134.174.176:5432/23people');
