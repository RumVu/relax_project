/**
 * Content inventory aggregator — per-section live/draft/total counts.
 * Each row matches a CRUD endpoint in the admin UI.
 */
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

type PublishableModel =
  | 'cozyQuote'
  | 'ambientSound'
  | 'breathingExercise'
  | 'appTheme'
  | 'onboardingSlide'
  | 'companionAsset'
  | 'companionMessage'
  | 'meditationGuide';

@Injectable()
export class ContentAggregator {
  constructor(private readonly prisma: PrismaService) {}

  async getContentInventory() {
    const [
      quotes,
      sounds,
      podcasts,
      exercises,
      meditations,
      themes,
      onboarding,
      companionAssets,
      companionMessages,
    ] = await Promise.all([
      this.countPublishState('cozyQuote'),
      this.countPublishState('ambientSound', {
        category: { notIn: ['PODCAST', 'MEDITATION', 'BUDDHA'] },
      }),
      this.countPublishState('ambientSound', { category: 'PODCAST' }),
      this.countPublishState('breathingExercise'),
      this.countPublishState('meditationGuide'),
      this.countPublishState('appTheme'),
      this.countPublishState('onboardingSlide'),
      this.countPublishState('companionAsset'),
      this.countPublishState('companionMessage'),
    ]);

    return [
      { area: 'Quotes', endpoint: '/cozy-quotes', ...quotes },
      { area: 'Sounds', endpoint: '/ambient-sounds', ...sounds },
      {
        area: 'Podcasts',
        endpoint: '/ambient-sounds/category/PODCAST',
        ...podcasts,
      },
      { area: 'Exercises', endpoint: '/breathing-exercises', ...exercises },
      { area: 'Meditations', endpoint: '/meditations/guides', ...meditations },
      { area: 'Themes', endpoint: '/app-themes', ...themes },
      { area: 'Onboarding', endpoint: '/onboarding-slides', ...onboarding },
      {
        area: 'Companion Assets',
        endpoint: '/companion-assets',
        ...companionAssets,
      },
      {
        area: 'Companion Messages',
        endpoint: '/companion-messages',
        ...companionMessages,
      },
    ];
  }

  /**
   * Generic `isActive=true` vs total count. Typed delegate cast so we
   * don't repeat 7 nearly-identical Promise.all entries.
   */
  private async countPublishState(
    model: PublishableModel,
    filter?: Record<string, any>,
  ) {
    const delegate = this.prisma[model] as {
      count: (args?: { where?: Record<string, any> }) => Promise<number>;
    };
    const [live, total] = await Promise.all([
      delegate.count({ where: { isActive: true, ...filter } }),
      delegate.count({ where: filter }),
    ]);

    return { live, drafts: Math.max(0, total - live), total };
  }
}
