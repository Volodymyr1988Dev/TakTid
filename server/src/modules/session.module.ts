import 'dotenv/config';
import { JwtModule, JwtSignOptions } from '@nestjs/jwt';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Session } from '../entities';
import { SessionService } from '../services';
import { SessionController } from '../controllers/session.controller';
//import { CleanupService } from '../services/CleanupService';

@Module({
  imports: [
    TypeOrmModule.forFeature([Session]),
    JwtModule.register({
      secret: process.env.SECRET,
      signOptions: {
        expiresIn: process.env.EXPIRES_AT as JwtSignOptions['expiresIn'],
      },
    }),
  ],
  controllers: [SessionController],
  providers: [SessionService /*, CleanupService*/],
  exports: [SessionService, JwtModule],
})
export class SessionModule {}
