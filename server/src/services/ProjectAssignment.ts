import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';
import { Between } from 'typeorm';
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

  async create(
    dto: CreateProjectAssignmentDto,
    user: User,
  ): Promise<ProjectAssignment> {
    //const user = await this.userRepo.findOne({ where: { id: dto.userId } });
    //if (!user) throw new NotFoundException('User not found');

    const project = await this.projectRepo.findOne({
      where: { id: dto.projectId },
    });
    if (!project) throw new NotFoundException('Project not found');
    const hours = this.calculateHours(
      dto.startTime,
      dto.endTime,
      dto.breakMinutes,
    );
    const assignment = this.assignmentRepo.create({
      user,
      project,
      date: dto.date,
      comment: dto.comment,
      startTime: dto.startTime,
      endTime: dto.endTime,
      breakMinutes: dto.breakMinutes,
      hours,
    });
    if (!dto.projectId) {
      throw new BadRequestException('WORK entry requires projectId');
    }

    return this.assignmentRepo.save(assignment);
  }

  async update(
    id: string,
    dto: UpdateProjectAssignmentDto,
  ): Promise<ProjectAssignment> {
    const assignment = await this.assignmentRepo.findOne({ where: { id } });
    if (!assignment) throw new NotFoundException('Assignment not found');

    const start = dto.startTime ?? assignment.startTime;
    const end = dto.endTime ?? assignment.endTime;
    const breakMinutes = dto.breakMinutes ?? assignment.breakMinutes;

    assignment.hours = this.calculateHours(start, end, breakMinutes);
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
  async findByPeriod(userId: string, from: string, to: string) {
    return this.assignmentRepo.find({
      where: {
        user: { id: userId },
        date: Between(from, to),
      },
      relations: ['project'],
      order: {
        date: 'ASC',
      },
    });
  }
  private calculateHours(
    startTime: string,
    endTime: string,
    breakMinutes: number,
  ): number {
    const [sh, sm] = startTime.split(':').map(Number);
    const [eh, em] = endTime.split(':').map(Number);

    const start = sh * 60 + sm;
    let end = eh * 60 + em;

    if (end <= start) {
      end += 24 * 60;
    }

    const workedMinutes = end - start - breakMinutes;
    return workedMinutes > 0 ? Number((workedMinutes / 60).toFixed(2)) : 0;
  }
}
