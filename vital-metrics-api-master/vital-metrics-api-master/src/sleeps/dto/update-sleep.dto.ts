import { PartialType } from '@nestjs/swagger';
import { CreateSleepDto } from './create-sleep.dto';

export class UpdateSleepDto extends PartialType(CreateSleepDto) {}
