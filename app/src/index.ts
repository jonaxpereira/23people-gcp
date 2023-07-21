import express, { Express, Request, Response } from 'express';
import { sequelize } from './db/Connection';
import { Heroes } from './models/heroes';

(async () => {
    sequelize.authenticate();
    const app: Express = express();
    app.use(express.json());
    const port = process.env.PORT || 3000;

    app.get('/heroes', async (req: Request, res: Response) => {
        const result = await Heroes.findAll();
        return res.json(result);
    });

    app.get('/heroes/:id', async (req: Request, res: Response) => {
        const { id } = req.params;
        const result = await Heroes.findByPk(id);
        return res.json(result);
    });

    app.listen(port, () => console.log(`Example app listening on port ${port}!`));
})()


