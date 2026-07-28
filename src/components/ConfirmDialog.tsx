interface ConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  danger?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

export default function ConfirmDialog({
  open,
  title,
  message,
  confirmText = '确认',
  cancelText = '取消',
  danger = false,
  onConfirm,
  onCancel,
}: ConfirmDialogProps) {
  if (!open) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        background: 'rgba(0,0,0,0.4)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
      }}
      onClick={onCancel}
    >
      <div
        style={{
          background: 'var(--color-bg)',
          border: '1px solid var(--color-border)',
          maxWidth: 320,
          width: 'calc(100% - 48px)',
          padding: 0,
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ padding: '24px 24px 16px' }}>
          <h3 style={{ fontSize: 18, fontWeight: 600, margin: '0 0 8px', color: 'var(--color-primary)' }}>{title}</h3>
          <p style={{ fontSize: 14, color: 'var(--color-text-secondary)', margin: 0 }}>{message}</p>
        </div>
        <div style={{ display: 'flex', borderTop: '1px solid var(--color-border)' }}>
          <button
            onClick={onCancel}
            className="btn-secondary"
            style={{ flex: 1, border: 'none', borderRight: '1px solid var(--color-border)' }}
          >
            {cancelText}
          </button>
          <button
            onClick={onConfirm}
            className={danger ? 'btn-danger' : 'btn-primary'}
            style={{ flex: 1, border: 'none' }}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
}
