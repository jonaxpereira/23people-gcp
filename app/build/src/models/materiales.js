"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Materiales = void 0;
const Connection_1 = require("../db/Connection");
const { DataTypes } = require('sequelize');
exports.Materiales = Connection_1.sequelize.define('materiales', {
    // Model attributes are defined here
    nro_material: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true
    },
    unidad_medida_base: {
        type: DataTypes.STRING,
        allowNull: false
    },
    nombre: {
        type: DataTypes.STRING,
        allowNull: false
    }
}, {
    timestamps: false
});
