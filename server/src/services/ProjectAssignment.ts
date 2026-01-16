import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';
import {
  UpdateProjectAssignmentDto,
  CreateProjectAssignmentDto,
} from '../types/index';

@Injectable()
export class ProjectAssignmentService {
  constructor(
    @InjectRepository(ProjectAssignment)
    private readonly assignmentRepo: Repository<ProjectAssignment>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  async create(dto: CreateProjectAssignmentDto): Promise<ProjectAssignment> {
    const user = await this.userRepo.findOne({ where: { id: dto.userId } });
    if (!user) throw new NotFoundException('User not found');

    const project = await this.projectRepo.findOne({
      where: { id: dto.projectId },
    });
    if (!project) throw new NotFoundException('Project not found');

    const assignment = this.assignmentRepo.create({
      user,
      project,
      comment: dto.comment,
    });

    return this.assignmentRepo.save(assignment);
  }

  async update(
    id: string,
    dto: UpdateProjectAssignmentDto,
  ): Promise<ProjectAssignment> {
    const assignment = await this.assignmentRepo.findOne({ where: { id } });
    if (!assignment) throw new NotFoundException('Assignment not found');

    Object.assign(assignment, dto);
    return this.assignmentRepo.save(assignment);
  }

  async updateExtraWork(
    id: string,
    comment: string,
  ): Promise<ProjectAssignment> {
    const assignment = await this.assignmentRepo.findOne({ where: { id } });
    if (!assignment) throw new NotFoundException('Assignment not found');

    assignment.comment = comment;
    return this.assignmentRepo.save(assignment);
  }

  async findByProject(projectId: string): Promise<ProjectAssignment[]> {
    return this.assignmentRepo.find({
      where: { project: { id: projectId } },
      relations: ['user'],
    });
  }

  async remove(id: string): Promise<void> {
    const result = await this.assignmentRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Assignment not found');
    }
  }
}
