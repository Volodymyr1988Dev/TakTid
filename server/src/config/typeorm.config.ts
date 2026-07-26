import 'dotenv/config';
import { DataSource, DataSourceOptions } from 'typeorm';
import { User } from '../entities/User/User';
import { Projects } from '../entities/Project/Project';
import { ProjectAssignment } from '../entities/Project/ProjectAssignment';
import { Session } from '../entities/Sessions/Sessions';
import { TimeEntry } from '../entities/TimeEntries/TimeEntries';
import { ProjectImage } from '../entities/Project/ProjectImages';
import { UserSalaryHistory } from '../entities/User/SallaryHistory';
import { ProjectTask } from '../entities/Project/ProjectTask';
import { ProjectReceipt } from '../entities/Project/ProjectReceipt';

const useSSL = process.env.DATABASE_URL?.includes('neon.tech') ?? false;

export const baseConfig: DataSourceOptions = {
  type: 'postgres',
  url: process.env.DATABASE_URL,
  ssl: useSSL ? { rejectUnauthorized: false } : false,
  entities: [
    User,
    Projects,
    ProjectAssignment,
    Session,
    TimeEntry,
    ProjectImage,
    UserSalaryHistory,
    ProjectTask,
    ProjectReceipt,
  ],
  migrations: ['dist/migrations/*.js'],

  synchronize: false,
  //logging: true,
  logging: process.env.NODE_ENV !== 'production',
};

export const AppDataSource = new DataSource({
  ...baseConfig,
  migrations: ['src/migrations/*.ts'],
});
