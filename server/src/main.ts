import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger, ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { Request, Response } from 'express';
import { NextFunction } from 'express';
import cookieParser from 'cookie-parser';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const logger = new Logger('Bootstrap');
  app.set('trust proxy', 1);
  app.enableCors({
    origin: process.env.CLIENT_URL || true,
    credentials: true,
  });
  /*
  app.enableCors({
    origin: [
      'http://localhost:5173',
      'http://localhost:8000',
      'http://localhost:8080',
      'https://tidtak-git-main-volodymyr1988devs-projects.vercel.app',
      'https://tidtak.vercel.app',
      'https://tak-tid.vercel.app',
      'https://tak-tid-el9s.vercel.app',
      'https://taktiddev.vercel.app',
    ],
    credentials: true,
  });
  */
  // eslint-disable-next-line @typescript-eslint/no-unsafe-call
  app.use(cookieParser());

  app.setGlobalPrefix('api');
  //app.use(express.json());
  /*
  const config = new DocumentBuilder()
    .setTitle('TakTid API')
    .setDescription('Time tracking system API')
    .setVersion('1.0.0')
    .addBearerAuth()
    .addTag('Auth')
    .addTag('Users')
    .addTag('Sessions')
    .addTag('TimeEntries')
    .build();
*/
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('TakTid API')
      .setDescription('Time tracking system API')
      .setVersion('1.0.0')
      .addBearerAuth()
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api-docs', app, document);
  }
  //const document = SwaggerModule.createDocument(app, config);
  //SwaggerModule.setup('api-docs', app, document);
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.useStaticAssets(join(__dirname, '..', 'public'));
  app.use((req: Request, res: Response, next: NextFunction) => {
    if (req.method === 'GET' && !req.url.startsWith('/api')) {
      res.sendFile(join(__dirname, '..', 'public', 'index.html'));
    } else {
      next();
    }
  });
  const port = process.env.PORT ? Number(process.env.PORT) : 8080;
  await app.listen(port, '0.0.0.0');
  //await app.listen(port);
  logger.log('Serving static files from:', join(process.cwd(), 'public'));
  logger.log(`
    Application is running on: http://localhost:${process.env.PORT ?? 8080}`);
  //logger.log(`
  //  📚 Swagger: http://localhost:${process.env.PORT ?? 8080}/api-docs`);
}
void bootstrap();
