const SIZE_CLASSES: Record<string, string> = {
  sm: 'h-8 w-8',
  md: 'h-14 w-14',
  lg: 'h-20 w-20',
};

const FILE_MAP: Record<string, string> = {
  sleep: 'meo-sleep',
  stand: 'meo-chat',
  right: 'meo-right',
  left: 'meo-left',
};

export function CatMascot({
  variant,
  size = 'md',
  className = '',
}: {
  variant: 'sleep' | 'stand' | 'right' | 'left';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}) {
  return (
    <img
      alt=""
      aria-hidden
      className={`${SIZE_CLASSES[size]} object-contain ${className}`}
      draggable={false}
      src={`/mascot/${FILE_MAP[variant]}.gif`}
    />
  );
}
