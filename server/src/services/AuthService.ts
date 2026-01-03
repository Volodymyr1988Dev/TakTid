import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CreateUserDto, LoginDto, RegisterDto } from '../types/index';
import { UserService } from './UserService';
import { SessionService } from './SessionService';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly sessionService: SessionService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, password, name } = registerDto;
    const existingUser = await this.userService.findByEmail(email);
    if (existingUser) {
      throw new HttpException('Email already in use', HttpStatus.CONFLICT);
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const createUserDto: CreateUserDto = {
      email,
      password: hashedPassword,
      name,
    };
    const user = await this.userService.createUserOnly(createUserDto);

    const session = await this.sessionService.createForUser(user);
    return {
      message: 'User registered successfully',
      user,
      token: session.token,
      refreshToken: session.refresh_token,
      expiresAt: session.expires_at,
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;
    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new HttpException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new HttpException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }

    const session = await this.sessionService.createForUser(user);

    return {
      message: 'Login successful',
      token: session.token,
      refreshToken: session.refresh_token,
      expiresAt: session.expires_at,
      user,
    };
  }
}
