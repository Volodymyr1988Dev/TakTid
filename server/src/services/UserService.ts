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
  /*
  async findByEmail(email: string) {
    return this.userRepository.findOne({ where: { email } });
  }*/
  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository
      .createQueryBuilder('user')
      .where('LOWER(user.email) = LOWER(:email)', {
        email: email.trim(),
      })
      .getOne();
  }
  /*
  async createUserOnly(createUserDto: CreateUserDto) {
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }*/
 async createUserOnly(createUserDto: CreateUserDto) {
    const user = this.userRepository.create({
      ...createUserDto,
      email: createUserDto.email.trim().toLowerCase(),
    });

    return this.userRepository.save(user);
  }

  async update(id: string, updateData: UpdateUserDto) {
    const user = await this.findOne(id);
    if (!user) throw new Error('User not found');
    if (updateData.email) {
      updateData.email = updateData.email.trim().toLowerCase();
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

  async findAllWithDeleted(requestedByUserId: string): Promise<User[]> {
    const admin = await this.userRepository.findOne({
      where: { id: requestedByUserId },
    });

    if (!admin || !admin.isAdmin) {
      throw new HttpException('Forbidden', HttpStatus.FORBIDDEN);
    }

    return this.userRepository.find({
      withDeleted: true,
      order: { createdAt: 'DESC' },
    });
  }

  async remove(
    id: string,
    deletedByUserId: string,
  ): Promise<{ message: string }> {
    /*
    const admin = await this.userRepository.findOne({
      where: { id: deletedByUserId },
    });

    if (!admin || !admin.isAdmin) {
      throw new HttpException('Forbidden', HttpStatus.FORBIDDEN);
    }

    const user = await this.userRepository.findOne({
      where: { id },
    });

    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }

    if (user.id === admin.id) {
      throw new HttpException(
        'Admin cannot delete himself',
        HttpStatus.BAD_REQUEST,
      );
    }

    user.deletedByUserId = deletedByUserId;
    await this.userRepository.save(user);

    await this.userRepository.softDelete(id);

    return { message: `User ${id} soft deleted successfully` };
    */
   return this.userRepository.manager.transaction(
    async (manager) => {
      const repository = manager.getRepository(User);

      const admin = await repository.findOne({
        where: { id: deletedByUserId },
      });

      if (!admin || !admin.isAdmin) {
        throw new HttpException(
          'Forbidden',
          HttpStatus.FORBIDDEN,
        );
      }

      if (id === deletedByUserId) {
        throw new HttpException(
          'Admin cannot delete himself',
          HttpStatus.BAD_REQUEST,
        );
      }

      const user = await repository.findOne({
        where: { id },
        withDeleted: true,
        lock: { mode: 'pessimistic_write' },
      });

      if (!user) {
        throw new HttpException(
          'User not found',
          HttpStatus.NOT_FOUND,
        );
      }

      if (user.deletedAt) {
        throw new HttpException(
          'User is already deleted',
          HttpStatus.CONFLICT,
        );
      }

      user.deletedByUserId = deletedByUserId;
      await repository.save(user);

      await repository.softDelete({ id });

      return {
        message: `User ${id} soft deleted successfully`,
      };
    },
    );
  }

  async softDelete(id: string, deletedByUserId: string) {
    const user = await this.findOne(id);
    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }

    user.deletedByUserId = deletedByUserId;
    await this.userRepository.save(user);
    await this.userRepository.softDelete(id);
  }

  async restore(
    id: string,
    restoredByUserId: string,
  ): Promise<{ message: string }> {
    const admin = await this.userRepository.findOne({
      where: { id: restoredByUserId },
    });

    if (!admin || !admin.isAdmin) {
      throw new HttpException('Forbidden', HttpStatus.FORBIDDEN);
    }

    const user = await this.userRepository.findOne({
      where: { id },
      withDeleted: true,
    });

    if (!user) {
      throw new HttpException('User not found', HttpStatus.NOT_FOUND);
    }

    if (!user.deletedAt) {
      throw new HttpException('User is not deleted', HttpStatus.BAD_REQUEST);
    }

    await this.userRepository.restore(id);

    return { message: `User ${id} restored successfully` };
  }
}
