import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserController } from '../controllers/user.controller';
import { User } from '../entities';
import { UserService } from '../services/UserService';
import { UserSalaryHistory } from '../entities/User/SallaryHistory';

@Module({
  imports: [TypeOrmModule.forFeature([User, UserSalaryHistory])],
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}
