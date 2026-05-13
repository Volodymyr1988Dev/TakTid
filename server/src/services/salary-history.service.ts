import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { UserSalaryHistory } from '../entities/User/SallaryHistory';
import { Repository } from 'typeorm';
import { User } from '../entities';

@Injectable()
export class SalaryHistoryService {
  constructor(
    @InjectRepository(UserSalaryHistory)
    private salaryRepo: Repository<UserSalaryHistory>,

    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  async addSalary(userId: string, salary: number) {
    const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const item = this.salaryRepo.create({
      user,
      salary,
      salaryNetto: salary * 0.7,
    });

    return this.salaryRepo.save(item);
  }

  async getHistory(userId: string) {
    return this.salaryRepo.find({
      where: {
        user: { id: userId },
      },
      order: {
        fromDate: 'DESC',
      },
    });
  }
}