import { sequelize } from '../db/Connection';
const { DataTypes } = require('sequelize');

export const Materiales = sequelize.define('materiales', {
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