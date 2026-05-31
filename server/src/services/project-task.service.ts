import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectTask } from '../entities/Project/ProjectTask';
import { User } from '../entities/User/User';
import { CreateProjectTaskDto } from '../types/project/create-project-task.dto';
import { UpdateProjectTaskDto } from '../types/project/update-project-task.dto';
import { OcrService } from './OCR.sevice';

@Injectable()
export class ProjectTaskService {

  constructor(
    @InjectRepository(ProjectTask)
    private repo: Repository<ProjectTask>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
    private readonly ocrService: OcrService,
    ) {}

  async getProjectTasks(projectId: string) {
    return this.repo.find({
      where: {
        project: { id: projectId }
      },
    })
  }

  async createTask(
    projectId: string,
    dto: CreateProjectTaskDto,
    ) {

    const task = this.repo.create({
        title: dto.title,
        project: {
        id: projectId,
        },
    })

    return this.repo.save(task)
    }

    async importTasks(
  projectId: string,
  files: Express.Multer.File[],
) {

  const allowed = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ]

  const allTasks: string[] = []

  for (const file of files) {

    if (
      !allowed.includes(
        file.mimetype,
      )
    ) {
      throw new BadRequestException(
        `Unsupported file type: ${file.originalname}`,
      )
    }

    try {

      const text =
        await this.ocrService.recognize(
          file.buffer,
        )

      const tasks = text
        .split('\n')
        .map(x => x.trim())
        .filter(Boolean)
        .filter(
          x => x.length > 3,
        )

      allTasks.push(...tasks)

    } catch (error) {

      console.error(
        `OCR failed for ${file.originalname}`,
        error,
      )
    }
  }

  const uniqueTasks =
    [...new Set(allTasks)]

  if (!uniqueTasks.length) {

    throw new BadRequestException(
      'No tasks detected',
    )
  }

  const entities =
    uniqueTasks.map(title =>
      this.repo.create({
        title,

        project: {
          id: projectId,
        },
      }),
    )

  return this.repo.save(
    entities,
  )
}

    async deleteTask(taskId: string) {
    const task = await this.repo.findOne({
        where: { id: taskId }
    })

    if (!task) {
        throw new NotFoundException('Task not found')
    }

    await this.repo.remove(task)

    return {
        success: true,
    }
    }

    async updateTaskData(
    taskId: string,
    dto: UpdateProjectTaskDto,
    ) {

    const task = await this.repo.findOne({
        where: { id: taskId }
    })

    if (!task) {
        throw new NotFoundException()
    }

    Object.assign(task, dto)

    return this.repo.save(task)
    }

  async updateTask(
    taskId: string,
    userId: string
  ) {

    const user = await this.userRepo.findOne({
        where: {
        id: userId,
        },
    })

    if (!user) {
        throw new NotFoundException(
        'User not found'
        )
    }

    const task = await this.repo.findOne({
      where: { id: taskId }
    })

    if (!task) {
      throw new NotFoundException()
    }

    task.done = !task.done

    if (task.done) {
      task.completedBy = user
      task.completedByName = user.name
      task.completedAt = new Date()
    } else {
      task.completedBy = null
      task.completedByName = null
      task.completedAt = null
    }

    return this.repo.save(task)
  }
}