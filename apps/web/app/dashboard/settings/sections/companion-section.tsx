'use client';

import { useState, useEffect } from 'react';
import { Save, WandSparkles } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { PremiumGate } from '@/components/dashboard/premium-gate';
import { Field, StatusMiniCard } from '../components/ui-cards';
import { CompanionAssetCard, SafeCompanionImage } from '../components/companion-cards';
import { modeLabel, companionOptionLabel } from '../settings-utils';
import type { CompanionState, CompanionOptionGroup, CompanionAsset } from '../settings-types';

interface CompanionSectionProps {
  copy: any;
  locale: 'vi' | 'en';
  companion: CompanionState | null;
  companionOptions: CompanionOptionGroup[];
  customAssets: CompanionAsset[];
  accountRole: string | undefined;
  planName: string;
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function CompanionSection({
  copy,
  locale,
  companion,
  companionOptions,
  customAssets,
  accountRole,
  planName,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: CompanionSectionProps) {
  const [companionNameDraft, setCompanionNameDraft] = useState('');
  const [companionState, setCompanionState] = useState<'idle' | 'saving'>('idle');

  useEffect(() => {
    if (companion?.name) {
      setCompanionNameDraft(companion.name);
    }
  }, [companion?.name]);

  if (!companion) {
    return (
      <Card>
        <SectionTitle
          title={copy.companionTitle}
          copy={copy.companionCopy}
          action={<WandSparkles className="h-5 w-5 text-violet" />}
        />
        <div className="mt-5 rounded-xl border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
          {copy.companionLoading}
        </div>
      </Card>
    );
  }

  return (
    <Card>
      <SectionTitle
        title={copy.companionTitle}
        copy={copy.companionCopy}
        action={<WandSparkles className="h-5 w-5 text-violet" />}
      />
      <div className="mt-5 space-y-5">
        <div className="grid gap-4 sm:grid-cols-[180px_minmax(0,1fr)]">
          <div
            className="overflow-hidden rounded-2xl border border-lilac/70 bg-white/75"
            style={{
              background:
                companion.asset?.secondaryColor || 'rgba(255,255,255,0.72)',
            }}
          >
            {companion.asset?.previewImageUrl ? (
              <SafeCompanionImage
                alt={companion.asset.name}
                className="h-44 w-full object-cover"
                src={companion.asset.previewImageUrl}
              />
            ) : (
              <div className="flex h-44 items-center justify-center text-sm font-semibold text-slate">
                {copy.noPreview}
              </div>
            )}
          </div>
          <div className="space-y-3">
            <Field
              label={copy.companionName}
              value={companionNameDraft}
              onChange={setCompanionNameDraft}
            />
            <div className="grid gap-3 sm:grid-cols-3">
              <StatusMiniCard
                note={copy.currentLevel}
                title="Level"
                value={String(companion.level)}
              />
              <StatusMiniCard
                note={copy.affection}
                title="Affection"
                value={`${companion.affection}%`}
              />
              <StatusMiniCard
                note={copy.energy}
                title="Energy"
                value={`${companion.energy}%`}
              />
            </div>
            <div className="flex flex-wrap gap-2">
              <Button
                disabled={companionState === 'saving'}
                onClick={async () => {
                  setCompanionState('saving');
                  try {
                    await apiFetch('/user-companions/me', {
                      method: 'PATCH',
                      body: JSON.stringify({ name: companionNameDraft }),
                    });
                    setRefreshKey((current) => current + 1);
                    triggerRefresh();
                    pushToast({
                      tone: 'success',
                      title: copy.renamedCompanion,
                    });
                  } catch {
                    pushToast({
                      tone: 'error',
                      title: copy.renameCompanionFailed,
                    });
                  } finally {
                    setCompanionState('idle');
                  }
                }}
              >
                <Save className="h-4 w-4" />
                {copy.saveName}
              </Button>
              {(['PET', 'FEED', 'PLAY'] as const).map((action) => (
                <Button
                  key={action}
                  onClick={async () => {
                    try {
                      await apiFetch('/user-companions/me/interactions', {
                        method: 'POST',
                        body: JSON.stringify({ type: action }),
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title:
                          action === 'PET'
                            ? copy.petted
                            : action === 'FEED'
                              ? copy.fed
                              : copy.played,
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: copy.interactFailed,
                      });
                    }
                  }}
                  variant="secondary"
                >
                  {action === 'PET'
                    ? copy.pet
                    : action === 'FEED'
                      ? copy.feed
                      : copy.play}
                </Button>
              ))}
            </div>
          </div>
        </div>

        <div className="grid gap-3 sm:grid-cols-3">
          <StatusMiniCard
            note={copy.currentMode}
            title="Personalization"
            value={modeLabel(companion.personalizationMode, copy)}
          />
          <StatusMiniCard
            note={copy.currentMood}
            title="Mood"
            value={companion.mood}
          />
          <StatusMiniCard
            note={copy.currentAction}
            title="Action"
            value={companion.action}
          />
        </div>

        <div className="space-y-3">
          {companionOptions.map((option) => {
            const card = (
              <div
                className="rounded-xl border border-lilac/70 bg-white/75 p-4"
                key={option.mode}
              >
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div>
                    <p className="text-lg font-extrabold text-ink">
                      {companionOptionLabel(option, copy)}
                    </p>
                    <p className="mt-1 text-sm text-slate">
                      {option.key
                        ? copy.mappedBy(option.key)
                        : option.mode === 'CUSTOM'
                          ? copy.customMode
                          : copy.defaultMode}
                    </p>
                  </div>
                  <Button
                    disabled={!option.available || companionState === 'saving' || option.mode === 'CUSTOM'}
                    onClick={async () => {
                      setCompanionState('saving');
                      try {
                        await apiFetch('/user-companions/me/personalization-mode', {
                          method: 'PATCH',
                          body: JSON.stringify({
                            personalizationMode: option.mode,
                            preserveProgress: true,
                            resetVisualState: true,
                          }),
                        });
                        setRefreshKey((current) => current + 1);
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: copy.changedMode(
                            companionOptionLabel(option, copy).toLowerCase(),
                          ),
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: copy.changeModeFailed,
                        });
                      } finally {
                        setCompanionState('idle');
                      }
                    }}
                    variant={
                      companion.personalizationMode === option.mode &&
                      option.mode !== 'CUSTOM'
                        ? 'secondary'
                        : 'primary'
                    }
                  >
                    {option.mode === 'CUSTOM'
                      ? copy.selectAssetBelow
                      : companion.personalizationMode === option.mode
                        ? copy.inUse
                        : copy.apply}
                  </Button>
                </div>

                {option.assets.length > 0 ? (
                  <div className="mt-4 grid gap-3 sm:grid-cols-2">
                    {option.assets.slice(0, 2).map((asset) => (
                      <CompanionAssetCard
                        asset={asset}
                        key={asset.id}
                        onSelect={async () => {
                          setCompanionState('saving');
                          try {
                            await apiFetch('/user-companions/me/personalization-mode', {
                              method: 'PATCH',
                              body: JSON.stringify({
                                personalizationMode: option.mode,
                                preserveProgress: true,
                                resetVisualState: true,
                              }),
                            });
                            setRefreshKey((current) => current + 1);
                            triggerRefresh();
                            pushToast({
                              tone: 'success',
                              title: copy.syncedMode(
                                companionOptionLabel(option, copy).toLowerCase(),
                              ),
                            });
                          } catch {
                            pushToast({
                              tone: 'error',
                              title: copy.syncModeFailed,
                            });
                          } finally {
                            setCompanionState('idle');
                          }
                        }}
                        selected={companion.assetId === asset.id}
                      />
                    ))}
                  </div>
                ) : null}
              </div>
            );
            if (option.mode === 'DEFAULT') return card;
            return (
              <PremiumGate
                key={option.mode}
                planName={planName}
                role={accountRole}
                title={copy.companionPremiumTitle}
                body={copy.companionPremiumBody}
              >
                {card}
              </PremiumGate>
            );
          })}
        </div>

        <PremiumGate
          planName={planName}
          role={accountRole}
          title={copy.companionPremiumTitle}
          body={copy.companionPremiumBody}
        >
          <div className="rounded-xl border border-lilac/70 bg-white/75 p-4">
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <p className="text-lg font-extrabold text-ink">{copy.customLibrary}</p>
                <p className="mt-1 text-sm text-slate">
                  {copy.customLibraryCopy}
                </p>
              </div>
            </div>
            <div className="mt-4 grid gap-3 sm:grid-cols-2">
              {customAssets.map((asset) => (
                <CompanionAssetCard
                  asset={asset}
                  key={asset.id}
                  onSelect={async () => {
                    setCompanionState('saving');
                    try {
                      await apiFetch('/user-companions/me/personalization-mode', {
                        method: 'PATCH',
                        body: JSON.stringify({
                          personalizationMode: 'CUSTOM',
                          assetId: asset.id,
                          preserveProgress: true,
                          resetVisualState: true,
                        }),
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: copy.loadedAsset(asset.name),
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: copy.loadAssetFailed,
                      });
                    } finally {
                      setCompanionState('idle');
                    }
                  }}
                  selected={
                    companion.personalizationMode === 'CUSTOM' &&
                    companion.assetId === asset.id
                  }
                />
              ))}
            </div>
          </div>
        </PremiumGate>
      </div>
    </Card>
  );
}
