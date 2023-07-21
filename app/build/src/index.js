"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const Connection_1 = require("./db/Connection");
const materiales_1 = require("./models/materiales");
const sucuarsales_1 = require("./models/sucuarsales");
const movimientos_inventario_1 = require("./models/movimientos_inventario");
(async () => {
    Connection_1.sequelize.authenticate();
    const app = (0, express_1.default)();
    app.use(express_1.default.json());
    const port = process.env.PORT || 3000;
    app.get('/materiales', async (req, res) => {
        const result = await materiales_1.Materiales.findAll();
        return res.json(result);
    });
    app.get('/materiales/:id', async (req, res) => {
        const { id } = req.params;
        const result = await materiales_1.Materiales.findByPk(id);
        return res.json(result);
    });
    app.get('/sucursales', async (req, res) => {
        const result = await sucuarsales_1.Sucursales.findAll();
        return res.json(result);
    });
    app.get('/sucursales/:id', async (req, res) => {
        const { id } = req.params;
        const result = await sucuarsales_1.Sucursales.findByPk(id);
        return res.json(result);
    });
    app.post('/sucursales/:id/materiales/movimientos', async (req, res) => {
        const body = req.body;
        const { id } = req.params;
        var currentdate = new Date();
        body.inventario.forEach(async (e) => {
            e.id_centro = id;
            e.usuario = body.usuario;
            e.fecha = currentdate.getFullYear() + "" + (currentdate.getMonth() + 1) + "" + currentdate.getDate();
            e.hora = currentdate.getHours() + "" + currentdate.getMinutes() + "" + currentdate.getSeconds();
            await movimientos_inventario_1.Movimientos.create(e);
        });
        return res.status(200).json({ msg: 'ok' });
    });
    app.listen(port, () => console.log(`Example app listening on port ${port}!`));
})();
