import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppService } from './app.service';

@ApiTags('Health')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @ApiOperation({ summary: 'Get API index and exposed module map' })
  @ApiOkResponse({
    description:
      'Returns the backend entrypoint, docs links, health links, and exposed API groups.',
  })
  @Get()
  getApiIndex() {
    return this.appService.getApiIndex();
  }

  @ApiOperation({ summary: 'Get API index alias' })
  @ApiOkResponse({
    description:
      'Alias of GET / for clients that prefer an explicit API discovery path.',
  })
  @Get('api')
  getApiIndexAlias() {
    return this.appService.getApiIndex();
  }

  @ApiOperation({ summary: 'Get API health status' })
  @ApiOkResponse({
    description: 'Returns app, database, and storage configuration health.',
  })
  @Get('health')
  getHealth() {
    return this.appService.getHealth();
  }
}
