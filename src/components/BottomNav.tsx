import { useAppStore, TabPage } from '../stores/appStore';

const tabs: { key: TabPage; label: string; icon: string }[] = [
  { key: 'documents', label: '文档', icon: '📄' },
  { key: 'vocabulary', label: '生词本', icon: '📖' },
  { key: 'phrases', label: '短语本', icon: '📝' },
  { key: 'settings', label: '我的', icon: '⚙' },
];

export default function BottomNav() {
  const currentTab = useAppStore((s) => s.currentTab);
  const setTab = useAppStore((s) => s.setTab);

  return (
    <nav style={{
      display: 'flex',
      borderTop: '1px solid var(--color-border)',
      background: 'var(--color-bg)',
      height: 56,
      flexShrink: 0,
    }}>
      {tabs.map((tab) => {
        const active = currentTab === tab.key;
        return (
          <button
            key={tab.key}
            onClick={() => setTab(tab.key)}
            style={{
              flex: 1,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              border: 'none',
              background: 'transparent',
              cursor: 'pointer',
              color: active ? 'var(--color-accent)' : 'var(--color-text-placeholder)',
              transition: 'color 150ms',
              fontSize: 10,
              fontWeight: active ? 500 : 400,
              gap: 2,
              minHeight: 44,
              padding: 0,
            }}
          >
            <span style={{ fontSize: 22, lineHeight: 1 }}>{tab.icon}</span>
            <span>{tab.label}</span>
          </button>
        );
      })}
    </nav>
  );
}
