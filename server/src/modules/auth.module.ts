import { Module } from '@nestjs/common';
import { JwtModule, JwtModuleOptions } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthService } from '../services/AuthService';
import { AuthController } from '../controllers/auth.controller';
import { UserModule } from './user.module';
import { SessionModule } from './session.module';
import { RegistrationApproval } from '../entities/Auth/RegistrationApproval';
//import { TypeOrmModule } from '@nestjs/typeorm/dist/typeorm.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RegistrationApprovalController } from '../controllers/RegistrationApprovalController';
import { RegistrationApprovalService } from '../services/RegistrationApproval.service';
//import { User } from '../entities';
import { User } from '../entities/User/User';

@Module({
  imports: [UserModule, SessionModule, TypeOrmModule.forFeature([
      RegistrationApproval, 
      User,
    ]),],
  providers: [AuthService, RegistrationApprovalService],
  controllers: [AuthController, RegistrationApprovalController],
  exports: [AuthService, RegistrationApprovalService],
})
export class AuthModule {}
