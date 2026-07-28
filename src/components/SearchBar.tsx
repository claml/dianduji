interface SearchBarProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  onAction?: () => void;
  actionLabel?: string;
}

export default function SearchBar({ value, onChange, placeholder = '搜索...', onAction, actionLabel }: SearchBarProps) {
  return (
    <div style={{ display: 'flex', gap: 8, alignItems: 'center', padding: '8px 16px' }}>
      <div style={{ flex: 1, position: 'relative' }}>
        <input
          className="input"
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          style={{ paddingLeft: 36 }}
        />
        <span style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: 'var(--color-text-placeholder)', fontSize: 16, pointerEvents: 'none' }}>
          🔍
        </span>
      </div>
      {onAction && (
        <button className="btn-primary" onClick={onAction} style={{ padding: '10px 16px', fontSize: 14, whiteSpace: 'nowrap' }}>
          {actionLabel || '+'}
        </button>
      )}
    </div>
  );
}
