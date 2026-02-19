import { Module } from '@nestjs/common';
import { JwtModule, JwtModuleOptions } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthService } from '../services/AuthService';
import { AuthController } from '../controllers/auth.controller';
import { UserModule } from './user.module';
import { SessionModule } from './session.module';
//import { AuthGuard } from '../types/auth/guard';

@Module({
  imports: [
    ConfigModule,
    UserModule,
    SessionModule,

    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService): JwtModuleOptions => {
        const secret = configService.get<string>('SECRET');

        if (!secret) {
          throw new Error('SECRET is not defined');
        }

        return {
          secret,
          signOptions: {
            expiresIn: configService.get('EXPIRES_AT') ?? '30d',
          },
        };
      },
    }),
  ],
  providers: [AuthService],
  controllers: [AuthController],
  exports: [AuthService],
})
export class AuthModule {}
