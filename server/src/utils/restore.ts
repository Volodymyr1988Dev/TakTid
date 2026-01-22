import { Logger } from '@nestjs/common';
import { exec } from 'child_process';
import 'dotenv/config';
import fs from 'fs';
import path from 'path';

const logger = new Logger('DatabaseRestore');
const backupDir = path.resolve(__dirname, '../../backups');

const backupFileName = process.argv[2];

if (!backupFileName) {
  logger.error('❌ Please provide backup file name');
  logger.log('Usage: npm run restore -- backup_2025-11-06.sql');
  logger.log('Available backups:');

  if (fs.existsSync(backupDir)) {
    const files = fs.readdirSync(backupDir).filter((f) => f.endsWith('.sql'));
    files.forEach((file) => logger.log(`  - ${file}`));
  }

  process.exit(1);
}

const backupFile = path.join(backupDir, backupFileName);

if (!fs.existsSync(backupFile)) {
  logger.error(`❌ Backup file not found: ${backupFile}`);
  logger.log('Available backups:');

  if (fs.existsSync(backupDir)) {
    const files = fs.readdirSync(backupDir).filter((f) => f.endsWith('.sql'));
    files.forEach((file) => logger.log(`  - ${file}`));
  }

  process.exit(1);
}

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  logger.error('❌ DATABASE_URL is not defined in .env');
  process.exit(1);
}

logger.warn(
  '⚠️  WARNING: This will restore the database and overwrite existing data!',
);
logger.log(`📂 Restoring from: ${backupFile}`);

const command = `psql "${databaseUrl}" < "${backupFile}"`;

exec(command, (error, stdout, stderr) => {
  if (error) {
    logger.error('❌ Restore failed:', error.message);
    process.exit(1);
  }

  if (stderr) {
    logger.warn('⚠️ psql warning:', stderr);
  }

  if (stdout) {
    logger.log(stdout);
  }

  logger.log('✅ Database restored successfully from:', backupFileName);
  process.exit(0);
});
