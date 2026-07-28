import { useState } from 'react';
import { useAppStore } from '../stores/appStore';

export default function Settings() {
  const theme = useAppStore((s) => s.theme);
  const setTheme = useAppStore((s) => s.setTheme);
  const fontSize = useAppStore((s) => s.fontSize);
  const setFontSize = useAppStore((s) => s.setFontSize);
  const lineHeight = useAppStore((s) => s.lineHeight);
  const setLineHeight = useAppStore((s) => s.setLineHeight);
  const autoAddVocabulary = useAppStore((s) => s.autoAddVocabulary);
  const setAutoAddVocabulary = useAppStore((s) => s.setAutoAddVocabulary);

  const [showCacheConfirm, setShowCacheConfirm] = useState(false);
  const [cacheCleared, setCacheCleared] = useState(false);

  async function handleClearCache() {
    const { db } = await import('../db/database');
    await db.paragraphs.clear();
    await db.sentences.clear();
    await db.words.clear();
    await db.phrases.clear();
    await db.documents.clear();
    setShowCacheConfirm(false);
    setCacheCleared(true);
    setTimeout(() => setCacheCleared(false), 2000);
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--color-border)' }}>
        <h2 style={{ fontSize: 22, fontWeight: 700, margin: 0 }}>设置</h2>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: 16 }}>
        <div style={{ marginBottom: 24 }}>
          <h3 style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-secondary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>
            阅读设置
          </h3>

          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: '12px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--color-border)' }}>
              <span style={{ fontSize: 16 }}>主题</span>
              <div style={{ display: 'flex', gap: 4 }}>
                {[
                  { key: 'day' as const, label: '日间' },
                  { key: 'eye-care' as const, label: '护眼' },
                  { key: 'night' as const, label: '夜间' },
                ].map((t) => (
                  <button
                    key={t.key}
                    onClick={() => setTheme(t.key)}
                    style={{
                      border: `1px solid ${theme === t.key ? 'var(--color-accent)' : 'var(--color-border)'}`,
                      background: theme === t.key ? 'var(--color-accent-12)' : 'transparent',
                      color: theme === t.key ? 'var(--color-accent)' : 'var(--color-primary)',
                      padding: '4px 12px',
                      fontSize: 13,
                      cursor: 'pointer',
                    }}
                  >
                    {t.label}
                  </button>
                ))}
              </div>
            </div>

            <div style={{ padding: '12px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--color-border)' }}>
              <span style={{ fontSize: 16 }}>字体大小</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <button
                  onClick={() => setFontSize(fontSize - 1)}
                  disabled={fontSize <= 12}
                  style={{ border: '1px solid var(--color-border)', background: 'transparent', width: 36, height: 36, cursor: 'pointer', fontSize: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 44, minHeight: 44, padding: 0 }}
                >
                  −
                </button>
                <span style={{ fontSize: 15, minWidth: 32, textAlign: 'center' }}>{fontSize}</span>
                <button
                  onClick={() => setFontSize(fontSize + 1)}
                  disabled={fontSize >= 24}
                  style={{ border: '1px solid var(--color-border)', background: 'transparent', width: 36, height: 36, cursor: 'pointer', fontSize: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 44, minHeight: 44, padding: 0 }}
                >
                  +
                </button>
              </div>
            </div>

            <div style={{ padding: '12px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: 16 }}>行间距</span>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <button
                  onClick={() => setLineHeight(lineHeight - 0.1)}
                  disabled={lineHeight <= 1.4}
                  style={{ border: '1px solid var(--color-border)', background: 'transparent', width: 36, height: 36, cursor: 'pointer', fontSize: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 44, minHeight: 44, padding: 0 }}
                >
                  −
                </button>
                <span style={{ fontSize: 15, minWidth: 32, textAlign: 'center' }}>{lineHeight.toFixed(1)}</span>
                <button
                  onClick={() => setLineHeight(lineHeight + 0.1)}
                  disabled={lineHeight >= 2.0}
                  style={{ border: '1px solid var(--color-border)', background: 'transparent', width: 36, height: 36, cursor: 'pointer', fontSize: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', minWidth: 44, minHeight: 44, padding: 0 }}
                >
                  +
                </button>
              </div>
            </div>
          </div>
        </div>

        <div style={{ marginBottom: 24 }}>
          <h3 style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-secondary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>
            学习设置
          </h3>
          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: '12px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: 16 }}>自动收录生词本</span>
              <button
                onClick={() => setAutoAddVocabulary(!autoAddVocabulary)}
                style={{
                  width: 48, height: 28,
                  borderRadius: 14,
                  border: 'none',
                  background: autoAddVocabulary ? 'var(--color-accent)' : 'var(--color-border)',
                  position: 'relative',
                  cursor: 'pointer',
                  transition: 'background 150ms',
                  padding: 0,
                  minWidth: 48,
                }}
              >
                <div style={{
                  width: 22, height: 22,
                  background: 'white',
                  borderRadius: 11,
                  position: 'absolute',
                  top: 3,
                  left: autoAddVocabulary ? 23 : 3,
                  transition: 'left 150ms',
                }} />
              </button>
            </div>
          </div>
        </div>

        <div style={{ marginBottom: 24 }}>
          <h3 style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-secondary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>
            缓存管理
          </h3>
          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: '12px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: 16 }}>清空所有文档数据</span>
              <button
                onClick={() => setShowCacheConfirm(true)}
                className="btn-danger"
                style={{ padding: '6px 16px', fontSize: 13 }}
              >
                {cacheCleared ? '已清空' : '清空'}
              </button>
            </div>
          </div>
        </div>

        <div style={{ marginBottom: 24 }}>
          <h3 style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-secondary)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 12 }}>
            关于
          </h3>
          <div className="card" style={{ padding: 0 }}>
            <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--color-border)' }}>
              <span style={{ fontSize: 16 }}>版本</span>
              <span style={{ float: 'right', color: 'var(--color-text-secondary)' }}>v1.0.0</span>
            </div>
            <div style={{ padding: '12px 16px' }}>
              <span style={{ fontSize: 16, color: 'var(--color-text-secondary)' }}>
                英文文档点读翻译 App — 轻量极简的英语阅读辅助工具
              </span>
            </div>
          </div>
        </div>
      </div>

      {showCacheConfirm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }} onClick={() => setShowCacheConfirm(false)}>
          <div style={{ background: 'var(--color-bg)', border: '1px solid var(--color-border)', maxWidth: 320, width: 'calc(100% - 48px)' }} onClick={(e) => e.stopPropagation()}>
            <div style={{ padding: '24px 24px 16px' }}>
              <h3 style={{ fontSize: 18, fontWeight: 600, margin: '0 0 8px' }}>清空数据</h3>
              <p style={{ fontSize: 14, color: 'var(--color-text-secondary)', margin: 0 }}>确定要清空所有文档和解析数据吗？生词本和短语本不会受影响。</p>
            </div>
            <div style={{ display: 'flex', borderTop: '1px solid var(--color-border)' }}>
              <button onClick={() => setShowCacheConfirm(false)} className="btn-secondary" style={{ flex: 1, border: 'none', borderRight: '1px solid var(--color-border)' }}>取消</button>
              <button onClick={handleClearCache} className="btn-danger" style={{ flex: 1, border: 'none' }}>清空</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
