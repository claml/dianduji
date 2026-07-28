interface ProgressBarProps {
  progress: number;
  onChange?: (progress: number) => void;
  visible?: boolean;
  disabled?: boolean;
}

export default function ProgressBar({ progress, onChange, visible = true, disabled = false }: ProgressBarProps) {
  if (!visible) return null;

  return (
    <div
      style={{
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        height: 4,
        background: 'var(--color-bg-secondary)',
        cursor: disabled ? 'default' : 'pointer',
        pointerEvents: disabled ? 'none' : 'auto',
        opacity: disabled ? 0.4 : 1,
        transition: 'opacity 200ms',
      }}
      onClick={(e) => {
        if (disabled || !onChange) return;
        const rect = e.currentTarget.getBoundingClientRect();
        const x = e.clientX - rect.left;
        onChange(x / rect.width);
      }}
    >
      <div
        style={{
          height: '100%',
          width: `${Math.min(100, Math.max(0, progress * 100))}%`,
          background: 'var(--color-accent)',
          transition: 'width 150ms',
        }}
      />
    </div>
  );
}
