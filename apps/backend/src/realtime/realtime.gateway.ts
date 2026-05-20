import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import type { UserRole } from '@prisma/client';
import type { Server, Socket } from 'socket.io';
import type { JwtPayload } from '../auth/auth.types';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from './realtime.service';

interface RealtimeSocketData {
  user?: {
    id: string;
    email: string;
    role: UserRole;
  };
}

@WebSocketGateway({
  namespace: '/realtime',
})
export class RealtimeGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  private server!: Server;

  private readonly logger = new Logger(RealtimeGateway.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
    private readonly realtimeService: RealtimeService,
  ) {}

  afterInit(server: Server) {
    this.realtimeService.attachServer(server);
  }

  async handleConnection(client: Socket) {
    const authUser = await this.resolveAuthUser(client);

    if (!authUser) {
      client.emit('realtime.auth_failed', {
        code: 'AUTH_TOKEN_INVALID',
        message:
          'Socket.IO realtime requires a valid Bearer token in auth.token or Authorization header.',
      });
      client.disconnect(true);
      return;
    }

    (client.data as RealtimeSocketData).user = authUser;
    await client.join(this.realtimeService.userRoom(authUser.id));
    await client.join(this.realtimeService.roleRoom(authUser.role));

    this.realtimeService.trackClient({
      socketId: client.id,
      userId: authUser.id,
      email: authUser.email,
      role: authUser.role,
      connectedAt: new Date().toISOString(),
    });

    client.emit('realtime.ready', {
      socketId: client.id,
      userId: authUser.id,
      rooms: [
        this.realtimeService.userRoom(authUser.id),
        this.realtimeService.roleRoom(authUser.role),
      ],
    });
  }

  handleDisconnect(client: Socket) {
    this.realtimeService.untrackClient(client.id);
  }

  @SubscribeMessage('ping')
  handlePing(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: unknown,
  ) {
    const user = (client.data as RealtimeSocketData).user;
    return {
      event: 'pong',
      data: {
        ok: true,
        socketId: client.id,
        userId: user?.id ?? null,
        payload: payload ?? null,
        observedAt: new Date().toISOString(),
      },
    };
  }

  private async resolveAuthUser(client: Socket) {
    const token = this.extractToken(client);
    if (!token) {
      return null;
    }

    try {
      const payload = await this.jwtService.verifyAsync<JwtPayload>(token);
      if (payload.typ !== 'access' || !payload.sub) {
        return null;
      }

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
        select: { id: true, email: true, role: true, isActive: true },
      });

      if (!user?.isActive) {
        return null;
      }

      return {
        id: user.id,
        email: user.email,
        role: user.role,
      };
    } catch (error) {
      this.logger.debug(
        `Realtime auth failed for ${client.id}: ${this.errorMessage(error)}`,
      );
      return null;
    }
  }

  private extractToken(client: Socket) {
    const auth = client.handshake.auth as Record<string, unknown> | undefined;
    const authToken = auth?.token;
    if (typeof authToken === 'string' && authToken.length > 0) {
      return authToken;
    }

    const authorization = client.handshake.headers.authorization;
    if (typeof authorization !== 'string') {
      return undefined;
    }

    const [type, token] = authorization.split(' ');
    return type === 'Bearer' ? token : undefined;
  }

  private errorMessage(error: unknown) {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }
}
