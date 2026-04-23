import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { CreateProjectDto, UpdateProjectDto } from '../types/index';
import { ProjectImagesService } from './ProjectImages.service';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries'
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
    return this.projectRepo.find({
      relations: ['assignments', 'timeEntries'],
      order: { createdAt: 'DESC' },
    });
  }

  async getProjectDetails(projectId: string) {
    const project = await this.projectRepo.findOneBy({ id: projectId })

    if (!project) {
      throw new NotFoundException('Project not found')
    }

    const timeEntries = await this.timeRepo.find({
      where: { project: { id: projectId } },
      relations: ['user'],
      order: { date: 'ASC' },
    })

    const extraEntries = await this.assignmentRepo.find({
      where: { project: { id: projectId } },
      relations: ['user'],
      order: { date: 'ASC' },
    })

    const mappedTime = timeEntries.map(e => ({
      id: e.id,
      date: e.date,
      hours: e.hours,
      type: e.type, // WORK / MEETING
      comment: e.comment,
      user: {
        id: e.user.id,
        email: e.user.email,
        name: e.user.name,
      }
    }))

    const mappedExtra = extraEntries.map(e => ({
      id: e.id,
      date: e.date,
      hours: e.hours,
      type: 'EXTRA', // 🔥 ключове
      comment: e.comment,
      user: {
        id: e.user.id,
        email: e.user.email,
        name: e.user.name,
      }
    }))

    return [...mappedTime, ...mappedExtra].sort(
      (a, b) => a.date.localeCompare(b.date)
    )
  }

  async getProjectSummary(projectId: string) {
    const project = await this.projectRepo.findOneBy({ id: projectId })

    if (!project) {
      throw new NotFoundException('Project not found')
    }

    const timeEntries = await this.timeRepo.find({
      where: { project: { id: projectId } },
    })

    const extraEntries = await this.assignmentRepo.find({
      where: { project: { id: projectId } },
    })

    const totalWork = timeEntries.reduce((sum, e) => sum + e.hours, 0)
    const totalExtra = extraEntries.reduce((sum, e) => sum + e.hours, 0)

    return {
      project: {
        id: project.id,
        city: project.city,
        address: project.address,
      },
      total: {
        work: totalWork,
        extra: totalExtra,
        all: totalWork + totalExtra,
      }
    }
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
}
