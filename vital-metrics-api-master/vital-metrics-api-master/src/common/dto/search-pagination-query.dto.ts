import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';
import { PaginationQueryDto } from './pagination-query.dto';

export class SearchPaginationQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Optional search term to filter results',
    example: 'search_term',
  })
  @IsOptional()
  @IsString()
  search?: string;
}
