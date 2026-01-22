import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';
import { CreateTimeEntryDto, UpdateTimeEntryDto } from '../types/index';
import { timeKind } from '../types/enums/enum';
import { UserMonthStats } from '../types/stats/UserMonthStats';

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

  async create(dto: CreateTimeEntryDto, userId: string): Promise<TimeEntry> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    this.forbidProjectForAbsence(dto.type, dto.projectId);

    let project: Projects | null = null;
    if (dto.projectId) {
      project = await this.projectRepo.findOne({
        where: { id: dto.projectId },
      });
      if (!project) throw new NotFoundException('Project not found');
    }
    //const start = this.timeToMinutes(dto.startTime);
    //const end = this.timeToMinutes(dto.endTime);
    //const breakMinutes = dto.breakMinutes ?? 0;

    const workedMinutes = this.getWorkedMinutes(
      dto.startTime,
      dto.endTime,
      dto.breakMinutes,
    );
    if (workedMinutes <= 0) {
      throw new BadRequestException('Break time incorrect');
    }
    const hours = Number((workedMinutes / 60).toFixed(2));

    //const hours = Number((workedMinutes / 60).toFixed(2));
    const entry = this.timeRepo.create({
      user,
      project,
      projectId: dto.projectId,
      date: dto.date,
      hours,
      //hours: dto.hours,
      type: dto.type,
      breakMinutes: dto.breakMinutes,
      comment: dto.comment,
      startTime: dto.startTime,
      endTime: dto.endTime,
      //...dto,
    });
    const saved = await this.timeRepo.save(entry);

    const withProject = await this.timeRepo.findOne({
      where: { id: saved.id },
      relations: ['project'],
    });

    if (!withProject) {
      throw new NotFoundException('Saved time entry not found');
    }

    //return this.timeRepo.save(entry);
    return withProject;
  }

  async update(id: string, dto: UpdateTimeEntryDto): Promise<TimeEntry> {
    const entry = await this.timeRepo.findOne({
      where: { id },
      relations: ['project'],
    });
    if (!entry) throw new NotFoundException('Time entry not found');
    const startTime = dto.startTime ?? entry.startTime;
    const endTime = dto.endTime ?? entry.endTime;
    const breakMinutes = dto.breakMinutes ?? entry.breakMinutes;

    const workedMinutes = this.getWorkedMinutes(
      startTime,
      endTime,
      breakMinutes,
    );

    entry.hours = Number((workedMinutes / 60).toFixed(2));
    if (workedMinutes <= 0) {
      throw new BadRequestException('Invalid time range');
    }

    if (dto.projectId !== undefined) {
      entry.projectId = dto.projectId;
      entry.project = dto.projectId
        ? await this.projectRepo.findOne({ where: { id: dto.projectId } })
        : null;
    }
    const effectiveType = dto.type ?? entry.type;
    const effectiveProjectId =
      dto.projectId !== undefined ? dto.projectId : entry.projectId;

    this.forbidProjectForAbsence(effectiveType, effectiveProjectId);
    entry.hours = Number((workedMinutes / 60).toFixed(2));
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { projectId: _projectId, ...rest } = dto;

    //Object.assign(entry, dto);
    Object.assign(entry, rest);
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
      .leftJoin('t.user', 'user')
      .leftJoinAndSelect('t.project', 'project')
      .where('user.id = :userId', { userId })
      .andWhere('t.date BETWEEN :from AND :to', { from, to })
      .orderBy('t.date', 'ASC')
      .getMany();
  }

  async getSuggestions(userId: string) {
    const entries = await this.timeRepo.find({
      where: { user: { id: userId } },
      relations: ['project'],
      order: { date: 'DESC' },
      take: 5,
    });

    return entries.map((e) => ({
      type: e.type,
      title: e.project ? `${e.project.city} – ${e.project.address}` : 'Work',
      projectId: e.project?.id,
      breakMinutes: e.breakMinutes ?? 0,
    }));
  }

  async remove(id: string): Promise<void> {
    const result = await this.timeRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Time entry not found');
    }
  }

  async getAdminMonthStats(year: number, month: number) {
    const from = `${year}-${String(month).padStart(2, '0')}-01`;
    const to = `${year}-${String(month).padStart(2, '0')}-31`;

    const entries = await this.timeRepo.find({
      where: { date: Between(from, to) },
      relations: ['user'],
    });

    const result: Record<string, UserMonthStats> = {};

    for (const e of entries) {
      const userId = e.user.id;

      if (!result[userId]) {
        result[userId] = {
          user: e.user,
          workHours: 0,
          extraHours: 0,
          meetingHours: 0,
          sickDays: new Set<string>(),
          vabDays: new Set<string>(),
          vacationDays: new Set<string>(),
        };
      }

      const stats = result[userId];

      switch (e.type) {
        case timeKind.WORK:
          stats.workHours += e.hours;
          break;
        case timeKind.MEETING:
          stats.meetingHours += e.hours;
          break;
        case timeKind.SICK:
          stats.sickDays.add(e.date);
          break;
        case timeKind.VAB:
          stats.vabDays.add(e.date);
          break;
        case timeKind.VACATION:
          stats.vacationDays.add(e.date);
          break;
      }
    }

    return Object.values(result).map((u) => ({
      user: u.user,
      workHours: u.workHours,
      extraHours: u.extraHours,
      meetingHours: u.meetingHours,
      sickDays: u.sickDays.size,
      vabDays: u.vabDays.size,
      vacationDays: u.vacationDays.size,
    }));
  }
  private timeToMinutes(time: string): number {
    const [h, m] = time.split(':').map(Number);
    return h * 60 + m;
  }
  private forbidProjectForAbsence(type: timeKind, projectId?: string) {
    const forbidden = [timeKind.SICK, timeKind.VACATION, timeKind.VAB];

    if (forbidden.includes(type) && projectId) {
      throw new BadRequestException(
        `projectId is not allowed for ${type} entries`,
      );
    }
  }
  private getWorkedMinutes(
    startTime: string,
    endTime: string,
    breakMinutes: number = 0,
  ): number {
    const [sh, sm] = startTime.split(':').map(Number);
    const [eh, em] = endTime.split(':').map(Number);

    const start = sh * 60 + sm;
    let end = eh * 60 + em;

    if (end <= start) {
      end += 24 * 60;
    }

    const worked = end - start - breakMinutes;

    if (worked <= 0) {
      throw new BadRequestException('Invalid time range');
    }

    return worked;
  }
}
