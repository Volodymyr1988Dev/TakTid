import { Controller, Get, Param } from '@nestjs/common';
import { ProjectStatsService } from '../services/projectStats.service';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('Project stats')
@Controller('projects')
export class ProjectStatsController {
  constructor(private readonly statsService: ProjectStatsService) {}

  @Get(':id/stats')
  getStats(@Param('id') id: string) {
    return this.statsService.getProjectStats(id);
  }
}
