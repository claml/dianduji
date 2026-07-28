import { useState, useEffect } from 'react';
import { db, VocabularyWord } from '../db/database';
import { useAppStore } from '../stores/appStore';
import SearchBar from '../components/SearchBar';
import ConfirmDialog from '../components/ConfirmDialog';
import EmptyState from '../components/EmptyState';

const proficiencyLabels = ['认识', '模糊', '陌生'];
const proficiencyFilterKeys = ['known', 'vague', 'unknown'] as const;

export default function VocabularyBook() {
  const [words, setWords] = useState<VocabularyWord[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteTarget, setDeleteTarget] = useState<VocabularyWord | null>(null);
  const [detailWord, setDetailWord] = useState<VocabularyWord | null>(null);

  const vocabularyFilter = useAppStore((s) => s.vocabularyFilter);
  const setVocabularyFilter = useAppStore((s) => s.setVocabularyFilter);
  const vocabularySortBy = useAppStore((s) => s.vocabularySortBy);
  const setVocabularySortBy = useAppStore((s) => s.setVocabularySortBy);
  const searchQuery = useAppStore((s) => s.searchQuery);
  const setSearchQuery = useAppStore((s) => s.setSearchQuery);

  async function loadWords() {
    let collection = db.vocabulary.toCollection();
    const words = await collection.toArray();
    setWords(words);
    setLoading(false);
  }

  useEffect(() => {
    loadWords();
  }, []);

  const filtered = words
    .filter((w) => {
      if (vocabularyFilter !== 'all') {
        const idx = proficiencyFilterKeys.indexOf(vocabularyFilter as typeof proficiencyFilterKeys[number]);
        if (idx === -1) return true;
        return w.proficiency === idx;
      }
      return true;
    })
    .filter((w) => {
      if (!searchQuery) return true;
      return w.word.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (w.definition && w.definition.toLowerCase().includes(searchQuery.toLowerCase()));
    })
    .sort((a, b) => {
      switch (vocabularySortBy) {
        case 'alpha': return a.word.localeCompare(b.word);
        case 'frequency': return b.lookupCount - a.lookupCount;
        case 'time':
        default: return b.lastLookupAt - a.lastLookupAt;
      }
    });

  async function handleDelete() {
    if (!deleteTarget) return;
    await db.vocabulary.delete(deleteTarget.id);
    setDeleteTarget(null);
    await loadWords();
  }

  async function handleProficiencyChange(word: VocabularyWord, newP: number) {
    await db.vocabulary.update(word.id, { proficiency: newP });
    await loadWords();
  }

  async function handleManualAdd() {
    const w = prompt('输入要添加的单词：');
    if (!w || !w.trim()) return;
    const { lookupWord } = await import('../engine/dictionary');
    const entry = lookupWord(w.trim());
    const existing = await db.vocabulary.where('word').equals(w.trim().toLowerCase()).first();
    if (existing) {
      await db.vocabulary.update(existing.id, {
        lookupCount: existing.lookupCount + 1,
        lastLookupAt: Date.now(),
      });
    } else {
      const { generateId } = await import('../engine/parser');
      await db.vocabulary.put({
        id: generateId(),
        word: w.trim().toLowerCase(),
        phonetic: entry?.phonetic || '',
        definition: entry ? `${entry.pos} ${entry.definition}` : '',
        proficiency: 2,
        lookupCount: 1,
        firstLookupAt: Date.now(),
        lastLookupAt: Date.now(),
        sourceDocumentId: '',
        sourceDocumentTitle: '手动添加',
      });
    }
    await loadWords();
  }

  async function handleExportCSV() {
    const words = await db.vocabulary.toArray();
    const header = 'word,phonetic,definition,proficiency,lookup_count,source';
    const rows = words.map((w) =>
      `"${w.word}","${w.phonetic}","${w.definition}",${w.proficiency},${w.lookupCount},"${w.sourceDocumentTitle}"`
    );
    const csv = [header, ...rows].join('\n');
    const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `vocabulary_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '12px 16px', borderBottom: '1px solid var(--color-border)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <h2 style={{ fontSize: 22, fontWeight: 700, margin: 0 }}>生词本</h2>
          <div style={{ display: 'flex', gap: 8 }}>
            <button onClick={handleManualAdd} className="btn-secondary" style={{ padding: '6px 12px', fontSize: 13 }}>
              + 添加
            </button>
            <button onClick={handleExportCSV} className="btn-secondary" style={{ padding: '6px 12px', fontSize: 13 }}>
              导出
            </button>
          </div>
        </div>

        <div style={{ display: 'flex', gap: 4, marginBottom: 8, flexWrap: 'wrap' }}>
          {['all', 'known', 'vague', 'unknown'].map((f) => (
            <button
              key={f}
              onClick={() => setVocabularyFilter(f as typeof vocabularyFilter)}
              style={{
                border: `1px solid ${vocabularyFilter === f ? 'var(--color-accent)' : 'var(--color-border)'}`,
                background: vocabularyFilter === f ? 'var(--color-accent-12)' : 'transparent',
                color: vocabularyFilter === f ? 'var(--color-accent)' : 'var(--color-primary)',
                padding: '4px 10px',
                fontSize: 12,
                cursor: 'pointer',
              }}
            >
              {f === 'all' ? '全部' : proficiencyLabels[proficiencyFilterKeys.indexOf(f as typeof proficiencyFilterKeys[number])]}
            </button>
          ))}
          <span style={{ flex: 1 }} />
          <select
            value={vocabularySortBy}
            onChange={(e) => setVocabularySortBy(e.target.value as 'time' | 'alpha' | 'frequency')}
            style={{
              border: '1px solid var(--color-border)',
              background: 'var(--color-bg)',
              color: 'var(--color-primary)',
              padding: '4px 8px',
              fontSize: 12,
            }}
          >
            <option value="time">按时间</option>
            <option value="alpha">按字母</option>
            <option value="frequency">按频率</option>
          </select>
        </div>

        <SearchBar value={searchQuery} onChange={setSearchQuery} placeholder="搜索单词..." />
      </div>

      <div style={{ flex: 1, overflow: 'auto' }}>
        {loading ? (
          <div style={{ padding: 32, textAlign: 'center', color: 'var(--color-text-secondary)' }}>加载中...</div>
        ) : filtered.length === 0 ? (
          <EmptyState
            message={searchQuery || vocabularyFilter !== 'all' ? '没有匹配的生词' : '生词本还是空的，去阅读中点击单词吧'}
            actionLabel="导入文档"
            onAction={() => useAppStore.getState().setTab('documents')}
          />
        ) : (
          <div style={{ padding: '8px 16px' }}>
            {filtered.map((w) => (
              <div
                key={w.id}
                className="card"
                style={{ padding: '12px 16px', marginBottom: 6, cursor: 'pointer', transition: 'filter 150ms' }}
                onClick={() => setDetailWord(w)}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 17, fontWeight: 600, marginBottom: 2 }}>{w.word}</div>
                    {w.phonetic && <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', marginBottom: 2 }}>{w.phonetic}</div>}
                    <div style={{ fontSize: 13, color: 'var(--color-text-secondary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {w.definition || '暂无释义'}
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexShrink: 0 }}>
                    <div style={{ display: 'flex', gap: 2 }}>
                      {[0, 1, 2].map((p) => (
                        <button
                          key={p}
                          onClick={(e) => { e.stopPropagation(); handleProficiencyChange(w, p); }}
                          style={{
                            border: `1px solid ${w.proficiency === p ? 'var(--color-accent)' : 'var(--color-border)'}`,
                            background: w.proficiency === p ? 'var(--color-accent-12)' : 'transparent',
                            color: w.proficiency === p ? 'var(--color-accent)' : 'var(--color-text-placeholder)',
                            fontSize: 11,
                            padding: '2px 6px',
                            cursor: 'pointer',
                            minWidth: 44,
                            minHeight: 30,
                          }}
                        >
                          {proficiencyLabels[p]}
                        </button>
                      ))}
                    </div>
                    <button
                      onClick={(e) => { e.stopPropagation(); setDeleteTarget(w); }}
                      style={{
                        border: 'none', background: 'transparent', color: 'var(--color-error)', fontSize: 12, cursor: 'pointer', padding: '4px 8px', minWidth: 44, minHeight: 44,
                      }}
                    >
                      删除
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <ConfirmDialog
        open={deleteTarget !== null}
        title="删除生词"
        message={`确定要删除「${deleteTarget?.word}」吗？`}
        confirmText="删除"
        danger
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />

      {detailWord && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }} onClick={() => setDetailWord(null)}>
          <div style={{ background: 'var(--color-bg)', border: '1px solid var(--color-border)', maxWidth: 360, width: 'calc(100% - 48px)', maxHeight: '70vh', overflow: 'auto' }} onClick={(e) => e.stopPropagation()}>
            <div style={{ padding: 24 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
                <div>
                  <h3 style={{ fontSize: 24, fontWeight: 700, margin: 0 }}>{detailWord.word}</h3>
                  {detailWord.phonetic && <p style={{ fontSize: 14, color: 'var(--color-text-secondary)', margin: '4px 0 0' }}>{detailWord.phonetic}</p>}
                </div>
                <button onClick={() => setDetailWord(null)} style={{ border: 'none', background: 'transparent', fontSize: 22, cursor: 'pointer', color: 'var(--color-text-secondary)', minWidth: 44, minHeight: 44, padding: 0 }}>✕</button>
              </div>
              <div style={{ marginBottom: 16 }}>
                <p style={{ fontSize: 16, lineHeight: 1.6 }}>{detailWord.definition || '暂无释义'}</p>
              </div>
              <div style={{ fontSize: 13, color: 'var(--color-text-secondary)', display: 'flex', flexDirection: 'column', gap: 4 }}>
                <div>查询次数：{detailWord.lookupCount}</div>
                <div>来源：{detailWord.sourceDocumentTitle || '未知'}</div>
                <div>熟练度：{proficiencyLabels[detailWord.proficiency]}</div>
                <div>最近查询：{new Date(detailWord.lastLookupAt).toLocaleString()}</div>
              </div>
              <div style={{ marginTop: 20, display: 'flex', gap: 8 }}>
                {[0, 1, 2].map((p) => (
                  <button
                    key={p}
                    onClick={() => {
                      handleProficiencyChange(detailWord, p);
                      setDetailWord((prev) => prev ? { ...prev, proficiency: p } : null);
                    }}
                    style={{
                      flex: 1,
                      border: `1px solid ${detailWord.proficiency === p ? 'var(--color-accent)' : 'var(--color-border)'}`,
                      background: detailWord.proficiency === p ? 'var(--color-accent-12)' : 'transparent',
                      color: detailWord.proficiency === p ? 'var(--color-accent)' : 'var(--color-primary)',
                      padding: '8px',
                      fontSize: 14,
                      cursor: 'pointer',
                    }}
                  >
                    {proficiencyLabels[p]}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
