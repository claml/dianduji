import { useState, useEffect } from 'react';
import { db, SavedPhrase } from '../db/database';
import { useAppStore } from '../stores/appStore';
import SearchBar from '../components/SearchBar';
import ConfirmDialog from '../components/ConfirmDialog';
import EmptyState from '../components/EmptyState';

const typeLabels: Record<string, string> = {
  'phrasal_verb': '动词短语',
  'prepositional': '介词短语',
  'collocation': '固定搭配',
  'idiom': '习语',
  'business': '商务搭配',
  'other': '其他',
};

const filterTypes = ['all', 'phrasal_verb', 'prepositional', 'collocation', 'idiom'];

export default function PhraseBook() {
  const [phrases, setPhrases] = useState<SavedPhrase[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<SavedPhrase | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filter, setFilter] = useState('all');

  async function loadPhrases() {
    const all = await db.savedPhrases.orderBy('createdAt').reverse().toArray();
    setPhrases(all);
    setLoading(false);
  }

  useEffect(() => {
    loadPhrases();
  }, []);

  const filtered = phrases
    .filter((p) => {
      if (filter !== 'all') return p.type === filter;
      return true;
    })
    .filter((p) => {
      if (!searchQuery) return true;
      return p.text.toLowerCase().includes(searchQuery.toLowerCase()) ||
        p.meaning.toLowerCase().includes(searchQuery.toLowerCase());
    });

  async function handleDelete() {
    if (!deleteTarget) return;
    await db.savedPhrases.delete(deleteTarget.id);
    setDeleteTarget(null);
    await loadPhrases();
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--color-border)' }}>
        <h2 style={{ fontSize: 22, fontWeight: 700, margin: '0 0 8px' }}>短语本</h2>

        <div style={{ display: 'flex', gap: 4, marginBottom: 8, flexWrap: 'wrap' }}>
          {filterTypes.map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              style={{
                border: `1px solid ${filter === f ? 'var(--color-accent)' : 'var(--color-border)'}`,
                background: filter === f ? 'var(--color-accent-12)' : 'transparent',
                color: filter === f ? 'var(--color-accent)' : 'var(--color-primary)',
                padding: '4px 10px',
                fontSize: 12,
                cursor: 'pointer',
              }}
            >
              {f === 'all' ? '全部' : typeLabels[f] || f}
            </button>
          ))}
        </div>

        <SearchBar value={searchQuery} onChange={setSearchQuery} placeholder="搜索短语..." />
      </div>

      <div style={{ flex: 1, overflow: 'auto' }}>
        {loading ? (
          <div style={{ padding: 32, textAlign: 'center', color: 'var(--color-text-secondary)' }}>加载中...</div>
        ) : filtered.length === 0 ? (
          <EmptyState
            message={searchQuery || filter !== 'all' ? '没有匹配的短语' : '短语本还是空的，去阅读中点击短语旁的 + 按钮收录吧'}
            actionLabel="去阅读"
            onAction={() => useAppStore.getState().setTab('documents')}
          />
        ) : (
          <div style={{ padding: '8px 16px' }}>
            {filtered.map((p) => (
              <div
                key={p.id}
                className="card"
                style={{ padding: '12px 16px', marginBottom: 6 }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                      <span style={{ fontSize: 17, fontWeight: 600 }}>{p.text}</span>
                      <span style={{
                        fontSize: 11,
                        color: 'var(--color-accent)',
                        border: '1px solid var(--color-accent)',
                        padding: '1px 6px',
                      }}>
                        {typeLabels[p.type] || p.type}
                      </span>
                    </div>
                    <div style={{ fontSize: 14, color: 'var(--color-primary)', marginBottom: 4 }}>
                      {p.meaning}
                    </div>
                    {p.contextSentence && (
                      <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', fontStyle: 'italic', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                        「{p.contextSentence}」
                      </div>
                    )}
                    {p.sourceDocumentTitle && (
                      <div style={{ fontSize: 11, color: 'var(--color-text-placeholder)', marginTop: 2 }}>
                        来源：{p.sourceDocumentTitle}
                      </div>
                    )}
                  </div>
                  <button
                    onClick={() => setDeleteTarget(p)}
                    style={{
                      border: 'none', background: 'transparent', color: 'var(--color-error)', fontSize: 12, cursor: 'pointer', padding: '4px 8px', flexShrink: 0, minWidth: 44, minHeight: 44,
                    }}
                  >
                    删除
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="删除短语"
        message={`确定要删除短语「${deleteTarget?.text}」吗？`}
        confirmText="删除"
        danger
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />
    </div>
  );
}
