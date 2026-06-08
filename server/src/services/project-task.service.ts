import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectTask } from '../entities/Project/ProjectTask';
import { User } from '../entities/User/User';
import { CreateProjectTaskDto } from '../types/project/create-project-task.dto';
import { UpdateProjectTaskDto } from '../types/project/update-project-task.dto';
import { OcrService } from './OCR.sevice';
import { TaskExtractionService } from './task-extraction.service';
import pdfParse from 'pdf-parse'
//import * as pdfParse from 'pdf-parse'
import { ExtractedTask } from '../types/project/extractedTask.dto';

@Injectable()
export class ProjectTaskService {

  constructor(
    @InjectRepository(ProjectTask)
    private repo: Repository<ProjectTask>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
    private readonly ocrService: OcrService,
    private readonly taskExtractionService:
    TaskExtractionService,
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
        attentionNote: dto.attentionNote || null,
        note: dto.note || null,
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
    'application/pdf',
  ]

  //const allTasks: string[] = []


const allTasks: ExtractedTask[] = []
  /*const allTasks: {
    title: string
    note: string
    attentionNote: string
    }[] = []*/
     let fullText = ''
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

    let text = ''
    if (file.mimetype === 'application/pdf') {

    const pdf = await pdfParse(file.buffer)

    if (pdf.text.trim()) {
        text = pdf.text
    } else {
        text =
        await this.ocrService.recognizePdf(
        file.buffer,
        )
    }

    } else {

    text =
        await this.ocrService.recognize(
        file.buffer,
        )
    }
    fullText += '\n' + text
    }
    const MAX_TEXT_LENGTH = 100000

    if (
    fullText.length >
    MAX_TEXT_LENGTH
    ) {
    fullText =
        fullText.slice(
        0,
        MAX_TEXT_LENGTH,
        )
    }
    const tasks =
      await this.taskExtractionService.extractTasks(
        fullText, //text,
      )
      //console.log(tasks, 'extracted tasks')
      if (
        Array.isArray(tasks)
        ) { allTasks.push(...tasks)}
  

  //const uniqueTasks = [...new Set(allTasks)]

  const uniqueTasks =
  allTasks.filter(
    (task, index, array) =>
      index ===
      array.findIndex(
        x =>
          x.title
            .trim()
            .toLowerCase() ===
          task.title
            .trim()
            .toLowerCase(),
      ),
  )
  const existing =
    await this.repo.find({
      where: {
        project: {
          id: projectId,
        },
      },
    })

  const existingTitles =
    new Set(
      existing.map(
        x =>
          x.title
            .trim()
            .toLowerCase(),
      ),
    )

  const newTasks =
    uniqueTasks.filter(
      task =>
        !existingTitles.has(
          task.title
            .trim()
            .toLowerCase(),
        ),
    )

  if (!newTasks.length) {

    return {
      imported: 0,
      skipped: uniqueTasks.length,
    }
  }

  const entities =
    newTasks.map(
      task =>
        this.repo.create({
          title: task.title,
          attentionNote: task.attentionNote || null,
          note: task.note || null,

          project: {
            id: projectId,
          },
        }),
    )

  await this.repo.save(
    entities,
  )

  return {
    imported:
      entities.length,

    skipped:
      uniqueTasks.length -
      entities.length,
  }
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