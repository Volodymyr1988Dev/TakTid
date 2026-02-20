import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';
import { join } from 'path';
//import { Request, Response, NextFunction } from 'express';

@Controller()
export class SpaController {
  @Get('*')
  serveSpa(@Res() res: Response) {
    //res.sendFile(join(__dirname, '..', 'public', 'index.html'));
    const req = res.req;

    if (req.path.startsWith('/api')) {
      return res.status(404).end();
    }

    return res.sendFile(join(process.cwd(), 'public', 'index.html'));
  }
}
