import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CreateUserDto, LoginDto, RegisterDto } from '../types/index';
import { UserService } from './UserService';
import { SessionService } from './SessionService';
import { RegistrationApprovalService } from './RegistrationApproval.service';
import { RegistrationApprovalStatus } from '../entities/Auth/RegistrationApproval';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly sessionService: SessionService,
    private readonly registrationApprovalService: RegistrationApprovalService,
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
     const normalizedEmail = email.trim().toLowerCase();
    const existingUser = await this.userService.findByEmail(/*email*/ normalizedEmail);
    if (existingUser) {
      throw new HttpException('Email already in use', HttpStatus.CONFLICT);
    }

    if (!name || !name.trim()) {
      throw new HttpException('Name is required', HttpStatus.BAD_REQUEST);
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    /*const createUserDto: CreateUserDto = {
      email: normalizedEmail,
      password: hashedPassword,
      name: name.trim(),
    };*/
    //const user = await this.userService.createUserOnly(createUserDto);
    //await this.registrationApprovalService.createAndSend(user);
    //const hashedPassword = await bcrypt.hash(password, 10);

    await this.registrationApprovalService.createAndSend(
      normalizedEmail,
      name.trim(),
      hashedPassword,
    );
    //const session = await this.sessionService.createForUser(user);
    return {
      //message: 'User registered successfully',
      message: //'User registered successfully. Please check your email for approval.',
      'Registration request sent. Please wait for approval.',
      //user: this.sessionService.toAuthUser(user),
      //token: session.token,
      //refreshToken: session.refresh_token,
      //expiresAt: session.expires_at,
      //expiresAt: session.access_token_expires_at,
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

  async logout(refreshToken?: string) {
    if (refreshToken) {
      await this.sessionService.removeByRefreshToken(refreshToken);
    }

    return { message: 'Logout successful' };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;
    const normalizedEmail = email.trim().toLowerCase();
    const user = await this.userService.findByEmail(/*email*/ normalizedEmail);
    if (!user) {
      throw new HttpException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }
    if (user.deletedAt) {
      throw new HttpException('User deleted', HttpStatus.FORBIDDEN);
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new HttpException('Invalid credentials', HttpStatus.UNAUTHORIZED);
    }
    const canLogin =
      await this.registrationApprovalService
        .canLogin(user.id);

    if (!canLogin) {
      const approval =
        await this.registrationApprovalService
          .getLatestForUser(user.id);
      if (
        approval?.status === RegistrationApprovalStatus.REJECTED
        //'rejected'
      ) {
        throw new HttpException(
          'Registration request was rejected',
          HttpStatus.FORBIDDEN,
        );
      }

      throw new HttpException(
        'Registration is awaiting approval',
        HttpStatus.FORBIDDEN,
      );
      }
    const session = await this.sessionService.createForUser(user);

    return {
      message: 'Login successful',
      token: session.token,
      refreshToken: session.refresh_token,
      //expiresAt: session.expires_at,
      expiresAt: session.access_token_expires_at,
      user: this.sessionService.toAuthUser(user),
    };
  }
}
