import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { CreateProjectDto, UpdateProjectDto } from '../types/index';
import { ProjectImagesService } from './ProjectImages.service';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { ProjectAssignment } from '../entities';

@Injectable()
export class ProjectsService {
  constructor(
    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
    private readonly imagesService: ProjectImagesService,

    @InjectRepository(TimeEntry)
    private readonly timeRepo: Repository<TimeEntry>,
    @InjectRepository(ProjectAssignment)
    private readonly assignmentRepo: Repository<ProjectAssignment>,
  ) {}
  async create(dto: CreateProjectDto): Promise<Projects> {
    const project = this.projectRepo.create(dto);
    return this.projectRepo.save(project);
  }

  async findAll(): Promise<Projects[]> {
    /*return this.projectRepo.find({
      relations: ['assignments', 'timeEntries'],
      order: { createdAt: 'DESC' },
    });*/
    const projects = await this.projectRepo.find({
      relations: ['assignments', 'timeEntries'],
      order: { createdAt: 'DESC' },
    });

    return projects.map(project => ({
      ...project,
      ...this.getProjectDates(project.timeEntries ?? []),
    }));

  }

  async getProjectDetails(projectId: string) {
    const project = await this.projectRepo.findOneBy({ id: projectId });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const timeEntries = await this.timeRepo.find({
      where: { project: { id: projectId } },
      relations: ['user'],
      order: { date: 'DESC' },
    });

    const extraEntries = await this.assignmentRepo.find({
      where: { project: { id: projectId } },
      relations: ['user'],
      order: { date: 'DESC' },
    });

    const mappedTime = timeEntries.map((e) => ({
      id: e.id,
      date: e.date,
      hours: e.hours,
      type: e.type, // WORK / MEETING
      comment: e.comment,
      user: {
        id: e.user.id,
        email: e.user.email,
        name: e.user.name,
      },
    }));

    const mappedExtra = extraEntries.map((e) => ({
      id: e.id,
      date: e.date,
      hours: e.hours,
      type: 'EXTRA', // 🔥 ключове
      comment: e.comment,
      user: {
        id: e.user.id,
        email: e.user.email,
        name: e.user.name,
      },
    }));

    return [...mappedTime, ...mappedExtra].sort((a, b) =>
      b.date.localeCompare(a.date),
    );
  }

  async getProjectSummary(projectId: string) {
    const project = await this.projectRepo.findOneBy({ id: projectId });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const timeEntries = await this.timeRepo.find({
      where: { project: { id: projectId } },
    });

    const extraEntries = await this.assignmentRepo.find({
      where: { project: { id: projectId } },
    });

    const totalWork = timeEntries.reduce((sum, e) => sum + Number(e.hours), 0);
    const totalExtra = extraEntries.reduce(
      (sum, e) => sum + Number(e.hours),
      0,
    );

    const baseProjectPrice =
      Number(project.pricePerM2 ?? 0) * Number(project.areaM2 ?? 0);

    const extraHoursPrice = totalExtra * Number(project.pricePerExtraH ?? 0);

    const totalProjectPrice = baseProjectPrice + extraHoursPrice;
    
    console.log('[ProjectSummary]', {
      projectId,
      entriesCount: timeEntries.length,
      workEntries: timeEntries
        .filter(e => String(e.type).toUpperCase() === 'WORK')
        .map(e => e.date),
      dates: this.getProjectDates(timeEntries),
    });
    
    return {
      project: {
        id: project.id,
        city: project.city,
        address: project.address,
        areaM2: project.areaM2,
        pricePerM2: project.pricePerM2,
        pricePerExtraH: project.pricePerExtraH,
        ...this.getProjectDates(timeEntries),
      },
      total: {
        work: totalWork,
        extra: totalExtra,
        all: totalWork + totalExtra,
      },
      baseProjectPrice,
      extraHoursPrice,
      totalProjectPrice,
    };
  }

  async findOne(id: string): Promise<Projects> {
    const project = await this.projectRepo.findOne({
      where: { id },
      relations: ['assignments', 'assignments.user', 'timeEntries'],
    });

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    return project;
  }

  async update(id: string, dto: UpdateProjectDto): Promise<Projects> {
    const project = await this.findOne(id);
    Object.assign(project, dto);
    return this.projectRepo.save(project);
  }

  async remove(id: string): Promise<void> {
    const project = await this.projectRepo.findOneBy({ id });
    if (!project) {
      throw new NotFoundException('Project not found');
    }
    await this.imagesService.removeByProject(id);
    await this.projectRepo.remove(project);
  }
  private getTodayInSweden(): string {
    const parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Europe/Stockholm',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(new Date());

    const values = Object.fromEntries(
      parts.map(part => [part.type, part.value]),
    );

    return `${values.year}-${values.month}-${values.day}`;
  }

  private getProjectDates(
    entries: TimeEntry[],
  ): {
    startDate: string | null;
    lastWorkDate: string | null;
    endDate: string | null;
    durationDays: number | null;
    isCompleted: boolean;
  } {
    const workDates = entries
      .filter(entry => entry.type === 'WORK')
      .map(entry => {
        if (!entry.date) return null;
        return String(entry.date).slice(0, 10);
      })
      .filter((date): date is string =>
        date !== null && /^\d{4}-\d{2}-\d{2}$/.test(date),
      )
      .sort();

    if (workDates.length === 0) {
      return {
        startDate: null,
        lastWorkDate: null,
        endDate: null,
        durationDays: null,
        isCompleted: false,
      };
    }

    const startDate = workDates[0];
    const lastWorkDate = workDates[workDates.length - 1];

    const start = new Date(`${startDate}T00:00:00Z`);
    const last = new Date(`${lastWorkDate}T00:00:00Z`);
    const today = new Date(
      `${this.getTodayInSweden()}T00:00:00Z`,
    );

    const daysSinceLastWork = Math.floor(
      (today.getTime() - last.getTime()) / 86_400_000,
    );

    const durationDays =
      Math.floor(
        (last.getTime() - start.getTime()) / 86_400_000,
      ) + 1;

    const isCompleted = daysSinceLastWork >= 7;

    return {
      startDate,
      lastWorkDate,
      endDate: isCompleted ? lastWorkDate : null,
      durationDays,
      isCompleted,
    };
  }
}
