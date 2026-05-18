import { IsString } from 'class-validator';

export class GetPublicUrlQueryDto {
  @IsString()
  path!: string;
}
