import {
  Controller,
  Get,
  Param,
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import { ProjectStatsService } from '../services/projectStats.service';
import { ApiTags } from '@nestjs/swagger';
import type { AuthRequest } from '../types/index';
import { ProjectsService } from '../services/Project';
//import { UseGuards } from '@nestjs/common';
//import { AdminGuard } from '../types/auth/admin.guard';

@ApiTags('Project stats')
@Controller('projects')
export class ProjectStatsController {
  constructor(
    private readonly statsService: ProjectStatsService,
    private readonly projectsService: ProjectsService,
  ) {}

  //@UseGuards(AdminGuard)
  @Get(':id/stats')
  getStats(@Param('id') id: string, @Req() req: AuthRequest) {
    if (!req.user) {
      throw new UnauthorizedException();
    }
    if (req.user.isAdmin) {
      return this.statsService.getProjectStats(id);
    }

    return this.projectsService.getProjectSummary(id);
  }
}
