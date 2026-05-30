/**
 * Billing aggregators — revenue, payment status, subscription status,
 * subscription plans. Each method returns shape ready for the dashboard.
 */
import { Injectable } from '@nestjs/common';
import { PaymentStatus, SubscriptionStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { DateRange } from '../helpers/date-range.helper';
import { fillEnumCounts, round2 } from '../helpers/admin-math.helper';

@Injectable()
export class BillingAggregator {
  constructor(private readonly prisma: PrismaService) {}

  async getRevenue(range: DateRange) {
    const result = await this.prisma.payment.aggregate({
      where: {
        status: PaymentStatus.COMPLETED,
        createdAt: { gte: range.from, lte: range.to },
      },
      _sum: { amount: true },
      _count: { _all: true },
    });

    return {
      amount: round2(result._sum.amount ?? 0),
      currency: 'VND',
      completedPayments: result._count._all,
    };
  }

  async getPaymentStatus(range: DateRange) {
    const rows = await this.prisma.payment.groupBy({
      by: ['status'],
      where: { createdAt: { gte: range.from, lte: range.to } },
      _count: { _all: true },
      _sum: { amount: true },
      orderBy: { status: 'asc' },
    });

    return rows.map((row) => ({
      status: row.status,
      count: row._count._all,
      amount: round2(row._sum.amount ?? 0),
    }));
  }

  async getSubscriptionStatus() {
    const rows = await this.prisma.subscription.groupBy({
      by: ['status'],
      _count: { _all: true },
      orderBy: { status: 'asc' },
    });

    return fillEnumCounts(rows, Object.values(SubscriptionStatus), 'status');
  }

  async getSubscriptionPlans() {
    const rows = await this.prisma.subscription.groupBy({
      by: ['planName'],
      _count: { _all: true },
      _sum: { price: true },
      orderBy: { planName: 'asc' },
    });

    return rows.map((row) => ({
      planName: row.planName,
      count: row._count._all,
      value: round2(row._sum.price ?? 0),
    }));
  }
}
