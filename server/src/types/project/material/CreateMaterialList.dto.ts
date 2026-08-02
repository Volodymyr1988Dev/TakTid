import { MaterialItemDto } from './MaterialItem.dto';

export class CreateMaterialListDto {
  projectId!: string;

  title?: string;

  other?: string;

  items!: MaterialItemDto[];
}
