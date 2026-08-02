import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Projects } from '../entities/Project/Project';
import { ProjectMaterialItem } from '../entities/Project/ProjectMaterialItem';
import { ProjectMaterial } from '../entities/Project/ProjectMaterial';
import { CreateMaterialListDto } from '../types/project/material/CreateMaterialList.dto';
import { UpdateMaterialListDto } from '../types/project/material/UpdateMaterialList.dto';

@Injectable()
export class ProjectMaterialService {
  constructor(
    @InjectRepository(ProjectMaterial)
    private readonly listRepo: Repository<ProjectMaterial>,

    @InjectRepository(ProjectMaterialItem)
    private readonly itemRepo: Repository<ProjectMaterialItem>,

    @InjectRepository(Projects)
    private readonly projectRepo: Repository<Projects>,
  ) {}

  async create(dto: CreateMaterialListDto) {
    return this.listRepo.manager.transaction(async manager => {
      const project = await manager.findOne(Projects, {
        where: {
          id: dto.projectId,
        },
      });

      if (!project) {
        throw new NotFoundException('Project not found');
      }

      const exists = await manager.findOne(ProjectMaterial, {
        where: {
          projectId: dto.projectId,
        },
      });

      if (exists) {
        throw new BadRequestException(
          'Material list already exists',
        );
      }

      const list = manager.create(ProjectMaterial, {
        project,
        projectId: dto.projectId,
        title: dto.title ?? null,
        other: dto.other ?? null,
        items: dto.items.map((item, index) =>
          manager.create(ProjectMaterialItem, {
            label: item.label,
            quantity: item.quantity,
            price: item.price,
            unit: item.unit ?? 'pcs',
            sortOrder: index,
          }),
        ),
      });

      await manager.save(list);

      return manager.findOne(ProjectMaterial, {
        where: {
          projectId: dto.projectId,
        },
        relations: {
          items: true,
        },
        order: {
          items: {
            sortOrder: 'ASC',
          },
        },
      });
    });
  }
  async update(
    id: string,
    dto: UpdateMaterialListDto,
  ) {
    return this.listRepo.manager.transaction(async manager => {
      const list = await manager.findOne(ProjectMaterial, {
        where: { id },
        relations: {
          items: true,
        },
      });

      if (!list) {
        throw new NotFoundException(
          'Material list not found',
        );
      }

      list.title = dto.title ?? list.title;
      list.other = dto.other ?? list.other;

      list.items = dto.items.map((item, index) =>
        manager.create(ProjectMaterialItem, {
          label: item.label,
          quantity: item.quantity,
          price: item.price,
          unit: item.unit ?? 'pcs',
          sortOrder: index,
        }),
      );

      await manager.save(list);

      return manager.findOne(ProjectMaterial, {
        where: {
          projectId: list.projectId,
        },
        relations: {
          items: true,
        },
        order: {
          items: {
            sortOrder: 'ASC',
          },
        },
      });
    });
  }

  async findByProject(projectId: string) {
    return this.listRepo.findOne({
      where: {
        projectId,
      },
      relations: {
        items: true,
      },
      order: {
        items: {
          sortOrder: 'ASC',
        },
      },
    });
  }

  async remove(id: string): Promise<void> {
    const result = await this.listRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Material list not found');
    }
  }
}
