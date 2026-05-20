import { Injectable } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import type { Server } from 'socket.io';
import type { RealtimeAdapterStatus } from './redis-io.adapter';

export type RealtimeEventName =
  | 'mood.updated'
  | 'relax-session.updated'
  | 'journal.created'
  | 'notification.created'
  | 'companion.updated'
  | 'analytics.updated';

export interface RealtimeClientSummary {
  socketId: string;
  userId: string;
  email: string;
  role: UserRole;
  connectedAt: string;
}

@Injectable()
export class RealtimeService {
  private server: Server | null = null;
  private clients = new Map<string, RealtimeClientSummary>();
  private adapterStatus: RealtimeAdapterStatus = {
    provider: 'socket.io',
    namespace: '/realtime',
    mode: 'memory',
    redisConfigured: false,
    redisConnected: false,
  };

  attachServer(server: Server) {
    this.server = server;
  }

  setAdapterStatus(status: RealtimeAdapterStatus) {
    this.adapterStatus = status;
  }

  trackClient(summary: RealtimeClientSummary) {
    this.clients.set(summary.socketId, summary);
  }

  untrackClient(socketId: string) {
    this.clients.delete(socketId);
  }

  getStatus() {
    return {
      configured: true,
      provider: 'socket.io',
      namespace: '/realtime',
      adapter: this.adapterStatus,
      connectedClients: this.clients.size,
    };
  }

  emitToUser(userId: string, event: RealtimeEventName, payload: unknown) {
    this.server?.to(this.userRoom(userId)).emit(event, payload);
  }

  emitToRole(role: UserRole, event: RealtimeEventName, payload: unknown) {
    this.server?.to(this.roleRoom(role)).emit(event, payload);
  }

  emitGlobal(event: RealtimeEventName, payload: unknown) {
    this.server?.emit(event, payload);
  }

  userRoom(userId: string) {
    return `user:${userId}`;
  }

  roleRoom(role: UserRole) {
    return `role:${role}`;
  }
}
