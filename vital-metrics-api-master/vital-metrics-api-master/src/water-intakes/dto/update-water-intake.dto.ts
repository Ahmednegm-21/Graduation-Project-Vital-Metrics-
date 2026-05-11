import { PartialType } from '@nestjs/swagger';
import { CreateWaterIntakeDto } from './create-water-intake.dto';

export class UpdateWaterIntakeDto extends PartialType(CreateWaterIntakeDto) {}
