import express, { Express, Request, Response } from 'express';
import { sequelize } from './db/Connection';
import { Materiales } from './models/materiales';
import { Sucursales } from './models/sucuarsales';
import { Movimientos } from './models/movimientos_inventario';

(async () => {
    sequelize.authenticate();
    const app: Express = express();
    app.use(express.json());
    const port = process.env.PORT || 3000;

    app.get('/materiales', async (req: Request, res: Response) => {
        const result = await Materiales.findAll();
        return res.json(result);
    });

    app.get('/materiales/:id', async (req: Request, res: Response) => {
        const { id } = req.params;
        const result = await Materiales.findByPk(id);
        return res.json(result);
    });

    app.get('/sucursales', async (req: Request, res: Response) => {
        const result = await Sucursales.findAll();
        return res.json(result);
    });

    app.get('/sucursales/:id', async (req: Request, res: Response) => {
        const { id } = req.params;
        const result = await Sucursales.findByPk(id);
        return res.json(result);
    });

    app.post('/sucursales/:id/materiales/movimientos', async (req: Request, res: Response) => {
        const body = req.body;
        const {id} = req.params;
        var currentdate = new Date();
        body.inventario.forEach(async(e: {id_material: number; cantidad: number; operacion: string; id_centro: string; usuario: string; fecha: string; hora: string; }) => {
            e.id_centro = id;
            e.usuario = body.usuario;
            e.fecha =  currentdate.getFullYear() + "" + (currentdate.getMonth()+1) + "" + currentdate.getDate();
            e.hora = currentdate.getHours() + "" + currentdate.getMinutes() + "" + currentdate.getSeconds();
            await Movimientos.create(e);
        });

        
        return res.status(200).json({msg: 'ok'});
    });

    app.listen(port, () => console.log(`Example app listening on port ${port}!`));
})()


