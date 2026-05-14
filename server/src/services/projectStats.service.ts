import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { Projects } from '../entities/Project/Project';
import { ProjectUserStat } from '../types/project/projectUserStat.dto';

@Injectable()
export class ProjectStatsService {
  constructor(
    @InjectRepository(TimeEntry)
    private readonly timeRepo: Repository<TimeEntry>,

    @InjectRepository(ProjectAssignment)
    private readonly assignmentRepo: Repository<ProjectAssignment>,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  async getProjectStats(projectId: string) {
    const project = await this.projectRepo.findOne({
      where: { id: projectId },
    });
    if (!project) throw new NotFoundException('Project not found');

    const workEntries = await this.timeRepo.find({
      where: {
        project: { id: projectId },
        type: In(['WORK', 'MEETING']),
      },
      relations: ['user'],
    });

    const extraEntries = await this.assignmentRepo.find({
      where: { project: { id: projectId } },
      relations: ['user'],
    });

    return this.aggregate(project, workEntries, extraEntries);
  }

  private aggregate(
    project: Projects,
    workEntries: TimeEntry[],
    extraEntries: ProjectAssignment[],
  ) {
    const users = new Map<string, ProjectUserStat>();

    for (const e of workEntries) {
      const userId = e.user.id;

      if (!users.has(userId)) {
        users.set(userId, {
          id: userId,
          name: e.user.name,
          email: e.user.email,
          workHours: 0,
          extraHours: 0,
          totalHours: 0,

          currentSalary: e.user.currentSalary ?? 0,
        });
      }

      const user = users.get(userId);
      if (user) {
        user.workHours += Number(e.hours);
      }
    }

    for (const e of extraEntries) {
      const userId = e.user.id;

      if (!users.has(userId)) {
        users.set(userId, {
          id: userId,
          name: e.user.name,
          email: e.user.email,
          workHours: 0,
          extraHours: 0,
          totalHours: 0,

          currentSalary: e.user.currentSalary ?? 0,
        });
      }

      const user = users.get(userId);
      if (user) {
        user.extraHours += Number(e.hours);
      }
    }

    const usersArray: ProjectUserStat[] = [...users.values()].map((u) => ({
      ...u,
      totalHours: u.workHours + u.extraHours,
    }));

    const totalWork = usersArray.reduce((sum, u) => sum + u.workHours, 0);
    const totalExtra = usersArray.reduce((sum, u) => sum + u.extraHours, 0);

    const totalProjectPrice = Number(project.pricePerM2 ?? 0) * Number(project.areaM2 ?? 0)
    return {
      project: {
        id: project.id,
        city: project.city,
        address: project.address,
        areaM2: project.areaM2,
        pricePerM2: project.pricePerM2,
      },
      users: usersArray,
      total: {
        work: totalWork,
        extra: totalExtra,
        all: totalWork + totalExtra,
      },
      totalProjectPrice,
    };
  }
}
