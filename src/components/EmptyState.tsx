interface EmptyStateProps {
  message: string;
  actionLabel: string;
  onAction: () => void;
}

export default function EmptyState({ message, actionLabel, onAction }: EmptyStateProps) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '64px 32px',
      gap: 16,
    }}>
      <p style={{ color: 'var(--color-text-secondary)', fontSize: 15, margin: 0, textAlign: 'center' }}>
        {message}
      </p>
      <button className="btn-primary" onClick={onAction} style={{ fontSize: 15 }}>
        {actionLabel}
      </button>
    </div>
  );
}
