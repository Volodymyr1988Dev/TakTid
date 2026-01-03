import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { CreateProjectDto, UpdateProjectDto } from '../types/index';

@Injectable()
export class ProjectsService {
  constructor(
    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
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
    const result = await this.projectRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Project not found');
    }
  }
}
