import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { User } from '../entities/User/User';
import { UserSalaryHistory } from '../entities/User/SallaryHistory';

import { SalaryHistoryService } from '../services/salary-history.service';
import { SalaryHistoryController } from '../controllers/salary-history.controller';

@Module({
  imports: [TypeOrmModule.forFeature([User, UserSalaryHistory])],
  providers: [SalaryHistoryService],
  controllers: [SalaryHistoryController],
  exports: [SalaryHistoryService],
})
export class SalaryHistoryModule {}
