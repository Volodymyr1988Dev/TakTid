import { Module, Logger } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
//import { TypeOrmModule } from '@nestjs/typeorm';
import { baseConfig } from './config/typeorm.config';
import { AuthGuard } from './types/auth/guard';
import { AppService } from './app.service';
import { UserModule } from './modules/user.module';
import { AuthModule } from './modules/auth.module';
import { SessionModule } from './modules/session.module';
import { ProjectAssignmentModule } from './modules/project.assignment.module';
import { ProjectsModule } from './modules/project.module';
import { TimeEntryModule } from './modules/timeEntry.module';
import { ScheduleModule } from '@nestjs/schedule';
import { ProjectImagesModule } from './modules/projectImage.module';
import { ProjectStatsModule } from './modules/projectStats.module';
import { StatsModule } from './modules/stat.module';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

@Module({
  imports: [
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'public'),
      //exclude: ['/api*'],
      //serveRoot: '/',
      exclude: ['/api*'],
      //renderPath: '*',
    }),
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot(baseConfig),
    ScheduleModule.forRoot(),
    UserModule,
    AuthModule,
    SessionModule,
    ProjectAssignmentModule,
    ProjectsModule,
    TimeEntryModule,
    ProjectImagesModule,
    ProjectStatsModule,
    StatsModule,
  ],

  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
  ],
})
export class AppModule {
  private readonly logger = new Logger(AppModule.name);
}
