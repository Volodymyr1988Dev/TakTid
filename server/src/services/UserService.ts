import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto, UpdateUserDto } from '../types/index';
import { User } from '../entities/User/User';

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
    Object.assign(user, updateData);
    return this.userRepository.save(user);
  }

  async remove(id: string) {
    return this.userRepository.delete(id);
  }
}
