"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Movimientos = void 0;
const Connection_1 = require("../db/Connection");
const { DataTypes } = require('sequelize');
exports.Movimientos = Connection_1.sequelize.define('movimientos_inventarios', {
    // Model attributes are defined here
    id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true,
        autoIncrement: true,
    },
    id_centro: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    id_material: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    cantidad: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    operacion: {
        type: DataTypes.STRING,
        allowNull: false
    },
    fecha: {
        type: DataTypes.STRING,
        allowNull: false
    },
    hora: {
        type: DataTypes.STRING,
        allowNull: false
    },
    usuario: {
        type: DataTypes.STRING,
        allowNull: false
    }
}, {
    timestamps: false
});
