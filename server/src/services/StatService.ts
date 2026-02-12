import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { timeKind } from '../types/enums/enum';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { AdminUserMonthStats } from '../types/stats/adminUserMonthStats.dto';

@Injectable()
export class StatsService {
  constructor(
    @InjectRepository(TimeEntry)
    private readonly timeRepo: Repository<TimeEntry>,

    @InjectRepository(ProjectAssignment)
    private readonly assignmentRepo: Repository<ProjectAssignment>,
  ) {}

  async getMonthStats(year: number, month: number) {
    const from = new Date(year, month - 1, 1);
    const to = new Date(year, month, 0, 23, 59, 59);
    const fromStr = from.toISOString().slice(0, 10);
    const toStr = to.toISOString().slice(0, 10);

    const timeEntries = await this.timeRepo.find({
      where: {
        date: Between(fromStr, toStr),
      },
      relations: ['user'],
    });

    const extraEntries = await this.assignmentRepo.find({
      where: {
        date: Between(fromStr, toStr),
      },
      relations: ['user'],
    });

    return this.aggregate(timeEntries, extraEntries);
  }

  private aggregate(
    timeEntries: TimeEntry[],
    extraEntries: ProjectAssignment[],
  ): AdminUserMonthStats[] {
    const users = new Map<string, AdminUserMonthStats>();

    for (const e of timeEntries) {
      const userId = e.user.id;

      if (!users.has(userId)) {
        users.set(userId, {
          user: {
            id: userId,
            email: e.user.email,
            name: e.user.name,
          },

          workHours: 0,
          extraHours: 0,

          sickHours: 0,
          sickDays: 0,

          vabHours: 0,
          vabDays: 0,

          vacationHours: 0,
          vacationDays: 0,

          totalHours: 0,
        });
      }

      const u = users.get(userId)!;
      const hours = Number(e.hours);

      switch (e.type) {
        case timeKind.WORK:
          u.workHours += hours;
          break;

        case timeKind.SICK:
          u.sickHours += hours;
          u.sickDays = Math.ceil(u.sickHours / 8);
          break;

        case timeKind.VAB:
          u.vabHours += hours;
          u.vabDays = Math.ceil(u.vabHours / 8);
          break;

        case timeKind.VACATION:
          u.vacationHours += hours;
          u.vacationDays = Math.ceil(u.vacationHours / 8);
          break;
      }
    }

    for (const e of extraEntries) {
      const userId = e.user.id;

      if (!users.has(userId)) {
        users.set(userId, {
          user: {
            id: userId,
            email: e.user.email,
            name: e.user.name,
          },

          workHours: 0,
          extraHours: 0,

          sickHours: 0,
          sickDays: 0,

          vabHours: 0,
          vabDays: 0,

          vacationHours: 0,
          vacationDays: 0,

          totalHours: 0,
        });
      }

      const u = users.get(userId)!;
      u.extraHours += Number(e.hours);
    }

    return [...users.values()].map((u) => ({
      ...u,
      totalHours:
        u.workHours + u.extraHours + u.sickHours + u.vabHours + u.vacationHours,
    }));
  }
}
