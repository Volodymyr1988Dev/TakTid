import { Module } from '@nestjs/common';
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
import { PasswordResetToken } from '../entities/Auth/PasswordResetToken';
import { PasswordResetService } from '../services/PasswordReset.service';
import { PasswordResetController } from '../controllers/PasswordReset.controller';
import { MailModule } from './mail.module';

@Module({
  imports: [UserModule, SessionModule, MailModule,  TypeOrmModule.forFeature([
      RegistrationApproval, 
      User,
      PasswordResetToken,
    ]),],
  providers: [AuthService, RegistrationApprovalService, PasswordResetService],
  controllers: [AuthController, RegistrationApprovalController, PasswordResetController],
  exports: [AuthService, RegistrationApprovalService, PasswordResetService],
})
export class AuthModule {}
