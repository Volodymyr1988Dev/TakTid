import {
  Body,
  Controller,
  Delete,
  Get,
  HttpException,
  HttpStatus,
  Logger,
  Param,
  Post,
} from '@nestjs/common';
import {
  ApiBody,
  ApiExtraModels,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Session } from '../entities/index';
import { SessionService } from '../services/SessionService';
import {
  CreateSessionDto,
  ValidateTokenDto,
  ValidateTokenResult,
} from '../types';

@ApiTags('sessions')
@ApiExtraModels(
  Session,
  CreateSessionDto,
  ValidateTokenDto,
  ValidateTokenResult,
)
@Controller('sessions')
export class SessionController {
  private readonly logger = new Logger(SessionController.name);
  constructor(private readonly sessionService: SessionService) {}

  @Post()
  @ApiOperation({ summary: 'Створити нову сесію користувача' })
  @ApiBody({ type: CreateSessionDto })
  @ApiResponse({ status: 201, description: 'Session created', type: Session })
  @ApiResponse({ status: 500, description: 'Error creating session' })
  async createSession(@Body() body: CreateSessionDto) {
    try {
      return await this.sessionService.createForUser(body.user);
    } catch (error) {
      this.logger.error('Error creating session', error);
      throw new HttpException(
        'Error creating session',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get()
  @ApiOperation({ summary: 'Отримати всі активні сесії' })
  @ApiResponse({
    status: 200,
    description: 'List of sessions',
    type: [Session],
  })
  async getAll() {
    return await this.sessionService.findAll();
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Видалити сесію' })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({ status: 200, description: 'Session deleted', type: [Session] })
  async removeSession(@Param('id') id: string) {
    await this.sessionService.remove(id);
    return { message: `Session ${id} deleted successfully` };
  }
}
