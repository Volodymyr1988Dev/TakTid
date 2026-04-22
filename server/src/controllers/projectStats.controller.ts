import { Controller, Get, Param } from '@nestjs/common';
import { ProjectStatsService } from '../services/projectStats.service';
import { ApiTags } from '@nestjs/swagger';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from '../types/auth/admin.guard';

@ApiTags('Project stats')
@Controller('projects')
export class ProjectStatsController {
  constructor(private readonly statsService: ProjectStatsService) {}

  //@UseGuards(AdminGuard)
  @Get(':id/stats')
  getStats(@Param('id') id: string) {
    return this.statsService.getProjectStats(id);
  }
}
