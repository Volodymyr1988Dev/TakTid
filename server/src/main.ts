import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger, ValidationPipe } from '@nestjs/common';
import cookieParser from 'cookie-parser';
import { NestExpressApplication } from '@nestjs/platform-express';
//import * as cookieParser from 'cookie-parser';
import express from 'express';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
//import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bodyParser: false,
  });
  const logger = new Logger('Bootstrap');
  app.set('trust proxy', 1);
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
  // eslint-disable-next-line @typescript-eslint/no-unsafe-call
  app.use(cookieParser());
  app.use(express.json());
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
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  const port = process.env.PORT ? Number(process.env.PORT) : 8080;
  await app.listen(port, '0.0.0.0');
  //await app.listen(port);
  logger.log(`
    Application is running on: http://localhost:${process.env.PORT ?? 8080}`);
  logger.log(`
    📚 Swagger: http://localhost:${process.env.PORT ?? 8080}/api-docs`);
}
void bootstrap();
