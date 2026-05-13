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
    try{
        const user = await this.userRepo.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const TAX_RATE = 0.3
    const item = this.salaryRepo.create({
      user,
      salary,
      salaryNetto: salary * (1 - TAX_RATE),
    });

    //user.currentSalary = salary
    //return this.salaryRepo.save(item);
    await this.salaryRepo.save(item);

    user.currentSalary = salary;

    await this.userRepo.save(user);

    return item;
    } catch(e){
      console.error(e);
      throw e;
    }
    
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