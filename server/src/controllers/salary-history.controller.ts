import {
  Body,
  Controller,
  Get,
  Param,
  Post,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { SalaryHistoryService } from '../services/salary-history.service';
import { CreateSalaryDto } from '../types/user/createSalary.dto';

@ApiTags('Salary History')
@Controller('users')
export class SalaryHistoryController {
  constructor(
    private readonly salaryService: SalaryHistoryService,
  ) {}

  @Post(':id/salary')
  addSalary(
    @Param('id') id: string,
    @Body() dto: CreateSalaryDto,
  ) {
    return this.salaryService.addSalary(
      id,
      dto.salary,
    );
  }

  @Get(':id/salary')
  getHistory(@Param('id') id: string) {
    return this.salaryService.getHistory(id);
  }
}