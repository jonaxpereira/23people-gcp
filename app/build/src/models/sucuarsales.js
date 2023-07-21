"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Sucursales = void 0;
const Connection_1 = require("../db/Connection");
const { DataTypes } = require('sequelize');
exports.Sucursales = Connection_1.sequelize.define('sucursales', {
    // Model attributes are defined here
    centro: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true
    },
    nombre: {
        type: DataTypes.STRING,
        allowNull: false
    }
}, {
    timestamps: false
});
