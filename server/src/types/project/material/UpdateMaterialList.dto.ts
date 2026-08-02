import { MaterialItemDto } from './MaterialItem.dto';

export class UpdateMaterialListDto {
  title?: string;

  other?: string;

  items!: MaterialItemDto[];
}
