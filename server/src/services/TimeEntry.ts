import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';
import { CreateTimeEntryDto, UpdateTimeEntryDto } from '../types/index';

@Injectable()
export class TimeEntryService {
  constructor(
    @InjectRepository(TimeEntry)
    private readonly timeRepo: Repository<TimeEntry>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  async create(dto: CreateTimeEntryDto): Promise<TimeEntry> {
    const user = await this.userRepo.findOne({ where: { id: dto.userId } });
    if (!user) throw new NotFoundException('User not found');

    let project: Projects | null = null;
    if (dto.projectId) {
      project = await this.projectRepo.findOne({
        where: { id: dto.projectId },
      });
      if (!project) throw new NotFoundException('Project not found');
    }

    const entry = this.timeRepo.create({
      user,
      project,
      date: dto.date,
      hours: dto.hours,
      type: dto.type,
      comment: dto.comment,
    });

    return this.timeRepo.save(entry);
  }

  async update(id: string, dto: UpdateTimeEntryDto): Promise<TimeEntry> {
    const entry = await this.timeRepo.findOne({ where: { id } });
    if (!entry) throw new NotFoundException('Time entry not found');

    Object.assign(entry, dto);
    return this.timeRepo.save(entry);
  }

  async findByUser(userId: string): Promise<TimeEntry[]> {
    return this.timeRepo.find({
      where: { user: { id: userId } },
      relations: ['project'],
      order: { date: 'DESC' },
    });
  }

  async findByPeriod(
    userId: string,
    from: string,
    to: string,
  ): Promise<TimeEntry[]> {
    return this.timeRepo
      .createQueryBuilder('t')
      .where('t.userId = :userId', { userId })
      .andWhere('t.date BETWEEN :from AND :to', { from, to })
      .orderBy('t.date', 'ASC')
      .getMany();
  }

  async remove(id: string): Promise<void> {
    const result = await this.timeRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Time entry not found');
    }
  }
}
