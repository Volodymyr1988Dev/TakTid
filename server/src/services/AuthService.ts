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
  async refreshByRefreshToken(refreshToken: string) {
    const session =
      await this.sessionService.refreshByRefreshToken(refreshToken);

    if (!session) return null;

    return {
      token: session.token,
      refreshToken: session.refresh_token,
      user: this.sessionService.toAuthUser(session.user),
    };
  }
  async getMe(userId: string) {
    const user = await this.userService.findById(userId);

    if (!user) {
      throw new HttpException('User not found', HttpStatus.UNAUTHORIZED);
    }

    return user;
  }

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

  async adminSoftDeleteUser(userId: string, adminId: string) {
    const admin = await this.userService.findById(adminId);

    if (!admin || !admin.isAdmin) {
      throw new HttpException('Forbidden', HttpStatus.FORBIDDEN);
    }

    const user = await this.userService.findById(userId);

    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }

    if (user.id === admin.id) {
      throw new HttpException(
        'Admin cannot delete himself',
        HttpStatus.BAD_REQUEST,
      );
    }

    await this.userService.softDelete(userId, adminId);

    await this.sessionService.removeAllByUser(userId);

    return { message: 'User deleted and sessions removed' };
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
    if (user.deletedAt) {
      throw new HttpException('User deleted', HttpStatus.FORBIDDEN);
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
