import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto, UpdateUserDto } from '../types/index';
import { User } from '../entities/User/User';
import * as bcrypt from 'bcrypt';
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}
  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }
  async findOne(id: string) {
    return this.userRepository.findOne({ where: { id } });
  }

  async findByEmail(email: string) {
    return this.userRepository.findOne({ where: { email } });
  }

  async createUserOnly(createUserDto: CreateUserDto) {
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }

  async update(id: string, updateData: UpdateUserDto) {
    const user = await this.findOne(id);
    if (!user) throw new Error('User not found');
    if (updateData.email) {
      const existing = await this.findByEmail(updateData.email);

      if (existing && existing.id !== id) {
        throw new HttpException('Email already in use', HttpStatus.CONFLICT);
      }
    }

    if (updateData.password) {
      updateData.password = await bcrypt.hash(updateData.password, 10);
    }
    Object.assign(user, updateData);
    return this.userRepository.save(user);
  }

  //async remove(id: string) {
  //  return this.userRepository.delete(id);
  //}
  async remove(id: string, deletedByUserId?: string) {
    const user = await this.userRepository.findOne({
      where: { id },
    });

    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }

    if (deletedByUserId) {
      user.deletedByUserId = deletedByUserId;
      await this.userRepository.save(user);
    }

    await this.userRepository.softDelete(id);

    return { message: `User ${id} soft deleted successfully` };
  }
}
