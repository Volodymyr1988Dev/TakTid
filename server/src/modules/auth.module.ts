import { Module } from '@nestjs/common';
import { AuthService } from '../services/AuthService';
import { AuthController } from '../controllers/auth.controller';
import { UserModule } from './user.module';
import { SessionModule } from './session.module';
//import { AuthGuard } from '../types/auth/guard';

@Module({
  imports: [UserModule, SessionModule],
  providers: [AuthService],
  controllers: [AuthController],
  exports: [AuthService],
})
export class AuthModule {}
