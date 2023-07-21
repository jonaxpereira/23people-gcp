import { sequelize } from '../db/Connection';
const { DataTypes } = require('sequelize');

export const Heroes = sequelize.define('heroes', {
  // Model attributes are defined here
  hero_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {
    timestamps: false
});