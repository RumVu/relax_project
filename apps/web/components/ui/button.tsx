import { ButtonHTMLAttributes } from 'react';
import { cn } from '@/lib/utils';

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'primary' | 'secondary' | 'ghost';
};

export function Button({ className, variant = 'primary', ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-full px-4 py-2 text-sm font-semibold transition',
        variant === 'primary' && 'bg-ink text-mist hover:bg-moss',
        variant === 'secondary' && 'bg-clay/70 text-ink hover:bg-clay',
        variant === 'ghost' && 'bg-white/50 text-ink hover:bg-white/80',
        className,
      )}
      {...props}
    />
  );
}
