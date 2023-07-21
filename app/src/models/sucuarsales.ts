import { sequelize } from '../db/Connection';
const { DataTypes } = require('sequelize');

export const Sucursales = sequelize.define('sucursales', {
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