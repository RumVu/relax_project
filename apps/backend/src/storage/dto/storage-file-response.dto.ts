import { ApiProperty } from '@nestjs/swagger';

export class StorageFileResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty({ nullable: true }) userId!: string | null;
  @ApiProperty() filename!: string;
  @ApiProperty() mimetype!: string;
  @ApiProperty({ type: 'integer' }) size!: number;
  @ApiProperty() provider!: string;
  @ApiProperty({ nullable: true }) path!: string | null;
  @ApiProperty() url!: string;
  @ApiProperty({ nullable: true }) publicUrl!: string | null;
  @ApiProperty({ nullable: true }) bucket!: string | null;
  @ApiProperty() isPublic!: boolean;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  expiresAt!: Date | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
}
