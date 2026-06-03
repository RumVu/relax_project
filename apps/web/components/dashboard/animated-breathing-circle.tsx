'use client';

import { useEffect, useState } from 'react';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type Phase = 'inhale' | 'hold-in' | 'exhale' | 'hold-out';

const phaseDurations = {
  inhale: 4000,
  'hold-in': 4000,
  exhale: 4000,
  'hold-out': 4000,
};

export function AnimatedBreathingCircle() {
  const { t } = useTranslation();
  const [phase, setPhase] = useState<Phase>('inhale');
  const [countdown, setCountdown] = useState(4);

  useEffect(() => {
    const timer = setTimeout(() => {
      setPhase((prev) => {
        if (prev === 'inhale') return 'hold-in';
        if (prev === 'hold-in') return 'exhale';
        if (prev === 'exhale') return 'hold-out';
        return 'inhale';
      });
      setCountdown(4);
    }, phaseDurations[phase]);
    return () => clearTimeout(timer);
  }, [phase]);

  useEffect(() => {
    const timer = setInterval(() => {
      setCountdown((prev) => (prev > 1 ? prev - 1 : 1));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const scale = phase === 'inhale' || phase === 'hold-in' ? 'scale-[1.8]' : 'scale-100';
  const opacity = phase === 'inhale' || phase === 'hold-in' ? 'opacity-100' : 'opacity-70';
  
  const phaseLabel = {
    inhale: t('breaks.breathing.inhale'),
    'hold-in': t('breaks.breathing.hold'),
    exhale: t('breaks.breathing.exhale'),
    'hold-out': t('breaks.breathing.hold'),
  };

  return (
    <div className="flex h-[320px] w-full flex-col items-center justify-center relative overflow-hidden rounded-lg bg-black/20">
      {/* Outer ripple */}
      <div
        className={`absolute h-48 w-48 rounded-full bg-mint/10 mix-blend-screen transition-all ease-in-out duration-[4000ms] ${scale} ${opacity}`}
      />
      {/* Inner ripple */}
      <div
        className={`absolute h-36 w-36 rounded-full bg-mint/20 mix-blend-screen transition-all ease-in-out duration-[4000ms] ${scale} ${opacity}`}
      />
      {/* Core circle */}
      <div
        className="relative z-10 flex h-28 w-28 flex-col items-center justify-center rounded-full bg-mint shadow-lg shadow-mint/20 text-night transition-transform duration-[4000ms]"
      >
        <span className="text-[10px] font-black uppercase tracking-widest opacity-80">{phaseLabel[phase]}</span>
        <span className="mt-1 text-4xl font-extrabold">{countdown}</span>
      </div>
    </div>
  );
}
