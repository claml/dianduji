import { useState, useEffect, useCallback } from 'react';
import { db, Document } from '../db/database';
import { useAppStore } from '../stores/appStore';
import { generateId, splitParagraphs, splitSentences, tokenizeWords, lemmatize } from '../engine/parser';
import SearchBar from '../components/SearchBar';
import ConfirmDialog from '../components/ConfirmDialog';
import EmptyState from '../components/EmptyState';

export default function DocumentList() {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState(true);
  const [showImport, setShowImport] = useState(false);
  const [importText, setImportText] = useState('');
  const [importTitle, setImportTitle] = useState('');
  const [importFileType, setImportFileType] = useState<'txt' | 'pdf' | 'docx'>('txt');
  const [importing, setImporting] = useState(false);
  const [parsingDocId, setParsingDocId] = useState<string | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Document | null>(null);

  const searchQuery = useAppStore((s) => s.searchQuery);
  const setSearchQuery = useAppStore((s) => s.setSearchQuery);
  const setTab = useAppStore((s) => s.setTab);
  const selectWord = useAppStore((s) => s.selectWord);
  const [currentDocId, setCurrentDocId] = useState<string | null>(null);

  const loadDocuments = useCallback(async () => {
    const docs = await db.documents.orderBy('createdAt').reverse().toArray();
    setDocuments(docs);
    setLoading(false);
  }, []);

  useEffect(() => {
    loadDocuments();
  }, [loadDocuments]);

  const filteredDocs = documents.filter((doc) => {
    if (!searchQuery) return true;
    return doc.title.toLowerCase().includes(searchQuery.toLowerCase());
  });

  async function handleImportText() {
    if (!importText.trim()) return;
    setImporting(true);
    const id = generateId();
    const title = importTitle.trim() || `文档 ${new Date().toLocaleDateString()}`;

    const doc: Document = {
      id,
      title,
      fileType: importFileType,
      fileSize: new Blob([importText]).size,
      wordCount: 0,
      paragraphCount: 0,
      parseStatus: 'parsing',
      lastReadPosition: 0,
      readProgress: 0,
      content: importText,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };

    await db.documents.put(doc);
    setParsingDocId(id);
    setShowImport(false);
    setImportText('');
    setImportTitle('');
    setImporting(false);

    await parseDocument(id, importText);
    await loadDocuments();
  }

  async function parseDocument(docId: string, text: string) {
    try {
      const paragraphs = splitParagraphs(text);
      const doc = await db.documents.get(docId);
      if (!doc) return;

      let totalWords = 0;
      for (let pi = 0; pi < paragraphs.length; pi++) {
        const p = paragraphs[pi];
        const pId = generateId();
        await db.paragraphs.put({
          id: pId,
          documentId: docId,
          index: pi,
          text: p.text,
          style: p.style,
        });

        const sents = splitSentences(p.text);
        for (let si = 0; si < sents.length; si++) {
          const s = sents[si];
          const sId = generateId();
          await db.sentences.put({
            id: sId,
            paragraphId: pId,
            documentId: docId,
            index: si,
            text: s.text,
            startOffset: s.start,
            endOffset: s.end,
          });

          const words = tokenizeWords(s.text);
          for (const w of words) {
            const wId = generateId();
            await db.words.put({
              id: wId,
              sentenceId: sId,
              documentId: docId,
              text: w.word,
              lemma: lemmatize(w.word),
              posTag: '',
              startOffset: w.start,
              endOffset: w.end,
            });
            totalWords++;
          }
        }
      }

      await db.documents.update(docId, {
        parseStatus: 'done',
        wordCount: totalWords,
        paragraphCount: paragraphs.length,
        updatedAt: Date.now(),
      });
    } catch (err) {
      await db.documents.update(docId, { parseStatus: 'failed' });
    }
    setParsingDocId(null);
  }

  async function handleFileUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    const ext = file.name.split('.').pop()?.toLowerCase() || 'txt';
    const type: 'txt' | 'pdf' | 'docx' = ext === 'pdf' ? 'pdf' : ext === 'docx' ? 'docx' : 'txt';

    const text = await file.text();
    setImportText(text);
    setImportTitle(file.name.replace(/\.[^.]+$/, ''));
    setImportFileType(type);
    setShowImport(true);

    e.target.value = '';
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    const docId = deleteTarget.id;
    await db.words.where('documentId').equals(docId).delete();
    await db.sentences.where('documentId').equals(docId).delete();
    await db.phrases.where('documentId').equals(docId).delete();
    await db.paragraphs.where('documentId').equals(docId).delete();
    await db.documents.delete(docId);
    setDeleteTarget(null);
    await loadDocuments();
  }

  function openReader(doc: Document) {
    if (doc.parseStatus !== 'done') return;
    selectWord(null, null);
    setCurrentDocId(doc.id);
  }

  if (currentDocId) {
    return <ReaderView docId={currentDocId} onBack={() => { setCurrentDocId(null); loadDocuments(); }} />;
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <SearchBar
        value={searchQuery}
        onChange={setSearchQuery}
        placeholder="搜索文档..."
        onAction={() => {
          setImportText('');
          setImportTitle('');
          setImportFileType('txt');
          setShowImport(true);
        }}
        actionLabel="导入"
      />

      <div style={{ flex: 1, overflow: 'auto' }}>
        {loading ? (
          <div style={{ padding: 32, textAlign: 'center', color: 'var(--color-text-secondary)' }}>加载中...</div>
        ) : filteredDocs.length === 0 ? (
          <EmptyState
            message={searchQuery ? '未找到匹配的文档' : '导入你的第一篇英文文档'}
            actionLabel="导入文档"
            onAction={() => {
              setImportText('');
              setImportTitle('');
              setImportFileType('txt');
              setShowImport(true);
            }}
          />
        ) : (
          <div style={{ padding: '8px 16px' }}>
            {filteredDocs.map((doc) => (
              <div
                key={doc.id}
                className="card"
                style={{
                  padding: 16,
                  marginBottom: 8,
                  cursor: doc.parseStatus === 'done' ? 'pointer' : 'default',
                  opacity: doc.parseStatus === 'done' ? 1 : 0.6,
                  transition: 'filter 150ms',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
                onClick={() => {
                  if (doc.parseStatus === 'done') openReader(doc);
                }}
              >
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 16, fontWeight: 500, marginBottom: 4, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {doc.title}
                  </div>
                  <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', display: 'flex', gap: 12 }}>
                    <span>{doc.fileType.toUpperCase()}</span>
                    <span>{doc.wordCount} 词</span>
                    {doc.parseStatus === 'parsing' && <span style={{ color: 'var(--color-warning)' }}>解析中...</span>}
                    {doc.parseStatus === 'failed' && <span style={{ color: 'var(--color-error)' }}>解析失败</span>}
                    {doc.readProgress > 0 && doc.parseStatus === 'done' && <span>已读 {Math.round(doc.readProgress * 100)}%</span>}
                  </div>
                </div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    setDeleteTarget(doc);
                  }}
                  style={{
                    border: 'none',
                    background: 'transparent',
                    color: 'var(--color-error)',
                    fontSize: 13,
                    cursor: 'pointer',
                    padding: '8px',
                    flexShrink: 0,
                    minWidth: 44,
                    minHeight: 44,
                  }}
                >
                  删除
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* 隐藏的文件选择器 */}
      <input
        type="file"
        accept=".txt,.pdf,.docx"
        onChange={handleFileUpload}
        style={{ display: 'none' }}
        id="file-upload"
      />

      <ConfirmDialog
        open={deleteTarget !== null}
        title="删除文档"
        message={`确定要删除「${deleteTarget?.title}」吗？此操作不可撤销。`}
        confirmText="删除"
        danger
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />

      {/* 导入弹窗 */}
      {showImport && (
        <div
          style={{
            position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)',
            display: 'flex', alignItems: 'flex-end', justifyContent: 'center', zIndex: 1000,
          }}
          onClick={() => setShowImport(false)}
        >
          <div
            style={{
              background: 'var(--color-bg)',
              borderTop: '1px solid var(--color-border)',
              width: '100%', maxWidth: 600,
              padding: '24px 16px 32px',
              maxHeight: '80vh',
              overflow: 'auto',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <h3 style={{ fontSize: 18, fontWeight: 600, margin: 0 }}>导入文档</h3>
              <button onClick={() => setShowImport(false)} style={{ border: 'none', background: 'transparent', fontSize: 24, cursor: 'pointer', color: 'var(--color-text-secondary)', minWidth: 44, minHeight: 44 }}>
                ✕
              </button>
            </div>

            <div style={{ marginBottom: 16 }}>
              <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
                {(['txt', 'pdf', 'docx'] as const).map((t) => (
                  <button
                    key={t}
                    onClick={() => setImportFileType(t)}
                    style={{
                      border: `1px solid ${importFileType === t ? 'var(--color-accent)' : 'var(--color-border)'}`,
                      background: importFileType === t ? 'var(--color-accent-12)' : 'transparent',
                      color: importFileType === t ? 'var(--color-accent)' : 'var(--color-primary)',
                      padding: '6px 14px',
                      fontSize: 13,
                      cursor: 'pointer',
                    }}
                  >
                    {t.toUpperCase()}
                  </button>
                ))}
              </div>

              <input
                className="input"
                placeholder="文档标题（可选）"
                value={importTitle}
                onChange={(e) => setImportTitle(e.target.value)}
                style={{ marginBottom: 12 }}
              />

              <textarea
                className="input"
                placeholder={`在此粘贴${importFileType === 'pdf' ? '文本' : importFileType === 'docx' ? '文档' : '文本'}内容...`}
                value={importText}
                onChange={(e) => setImportText(e.target.value)}
                rows={10}
                style={{ resize: 'vertical', fontFamily: 'Georgia, serif', marginBottom: 12 }}
              />

              <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', marginBottom: 16 }}>
                或从文件导入：
                <label
                  htmlFor="file-upload-top"
                  style={{ color: 'var(--color-accent)', cursor: 'pointer', marginLeft: 8, textDecoration: 'underline' }}
                >
                  选择文件
                </label>
                <input type="file" accept=".txt,.pdf,.docx" onChange={handleFileUpload} style={{ display: 'none' }} id="file-upload-top" />
              </div>

              <button
                className="btn-primary"
                disabled={!importText.trim() || importing}
                onClick={handleImportText}
                style={{ width: '100%', opacity: !importText.trim() || importing ? 0.5 : 1 }}
              >
                {importing ? '导入中...' : '开始导入'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function ReaderView({ docId, onBack }: { docId: string; onBack: () => void }) {
  const [paragraphs, setParagraphs] = useState<{ id: string; text: string; style: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [scrollProgress, setScrollProgress] = useState(0);

  const fontSize = useAppStore((s) => s.fontSize);
  const lineHeight = useAppStore((s) => s.lineHeight);
  const selectedWord = useAppStore((s) => s.selectedWord);
  const selectedSentence = useAppStore((s) => s.selectedSentence);
  const translationCardOpen = useAppStore((s) => s.translationCardOpen);
  const selectWord = useAppStore((s) => s.selectWord);
  const closeTranslationCard = useAppStore((s) => s.closeTranslationCard);

  const [scrollTop, setScrollTop] = useState(0);
  const [viewHeight, setViewHeight] = useState(0);
  const [contentHeight, setContentHeight] = useState(0);
  const [docTitle, setDocTitle] = useState('');

  useEffect(() => {
    async function load() {
      const doc = await db.documents.get(docId);
      if (doc) setDocTitle(doc.title);
      const paras = await db.paragraphs.where('documentId').equals(docId).sortBy('index');
      setParagraphs(paras.map((p) => ({ id: p.id, text: p.text, style: p.style })));
      setLoading(false);
    }
    load();
  }, [docId]);

  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    const target = e.currentTarget;
    const top = target.scrollTop;
    const vh = target.clientHeight;
    const ch = target.scrollHeight;
    setScrollTop(top);
    setViewHeight(vh);
    setContentHeight(ch);
    if (ch > vh) {
      setScrollProgress(top / (ch - vh));
    }
  };

  function handleWordClick(word: string, sentenceText: string) {
    selectWord(word, sentenceText);
  }

  function renderParagraph(text: string) {
    const words = tokenizeWords(text);
    if (words.length === 0) return text;

    const elements: React.ReactNode[] = [];
    let lastEnd = 0;

    words.forEach((w, i) => {
      if (w.start > lastEnd) {
        elements.push(text.slice(lastEnd, w.start));
      }

      const isInSelectedSentence = selectedSentence !== null && text.includes(selectedSentence.replace(/\n/g, ' ')) &&
        w.start >= text.indexOf(selectedSentence.replace(/\n/g, ' ').split(' ')[0] || '') &&
        w.end <= text.indexOf(selectedSentence.replace(/\n/g, ' ')) + selectedSentence.length;

      const isSelected = selectedWord !== null && w.word.toLowerCase() === selectedWord.toLowerCase();

      elements.push(
        <span
          key={i}
          onClick={(e) => {
            e.stopPropagation();
            handleWordClick(w.word, text);
          }}
          style={{
            cursor: 'pointer',
            textDecoration: isSelected ? 'underline' : 'none',
            textDecorationColor: 'var(--color-accent)',
            textDecorationThickness: 2,
            textUnderlineOffset: 3,
            backgroundColor: isSelected ? 'var(--color-accent-12)' : 'transparent',
            transition: 'background-color 120ms',
            borderRadius: 0,
            padding: '1px 0',
          }}
        >
          {w.word}
        </span>
      );

      lastEnd = w.end;
    });

    if (lastEnd < text.length) {
      elements.push(text.slice(lastEnd));
    }

    return elements;
  }

  if (loading) {
    return (
      <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--color-text-secondary)' }}>
        加载中...
      </div>
    );
  }

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', position: 'relative' }}>
      <div style={{
        display: 'flex', alignItems: 'center', padding: '8px 16px',
        borderBottom: '1px solid var(--color-border)',
        background: 'var(--color-bg)',
        gap: 12,
        minHeight: 48,
      }}>
        <button
          onClick={() => { closeTranslationCard(); onBack(); }}
          style={{ border: 'none', background: 'transparent', fontSize: 20, cursor: 'pointer', color: 'var(--color-accent)', minWidth: 44, minHeight: 44, padding: 0 }}
        >
          ←
        </button>
        <div style={{ flex: 1, fontSize: 16, fontWeight: 500, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {docTitle}
        </div>
      </div>

      <div
        style={{ flex: 1, overflow: 'auto', padding: '16px 16px 40px' }}
        onScroll={handleScroll}
        onClick={() => { if (translationCardOpen) closeTranslationCard(); }}
      >
        {paragraphs.map((p) => (
          <div
            key={p.id}
            style={{
              fontSize: p.style === 'heading1' ? Math.min(24, fontSize + 6) : fontSize,
              fontWeight: p.style === 'heading1' ? 700 : 400,
              lineHeight: p.style === 'heading1' ? 1.4 : lineHeight,
              marginBottom: 16,
              fontFamily: "'Georgia', 'Noto Serif CJK SC', serif",
              color: 'var(--color-primary)',
            }}
          >
            {renderParagraph(p.text)}
          </div>
        ))}
        {paragraphs.length > 0 && (
          <div style={{ textAlign: 'center', color: 'var(--color-text-placeholder)', fontSize: 13, padding: '32px 0' }}>
            — 已到达文档末尾 —
          </div>
        )}
      </div>

      <div
        style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          right: 0,
          height: 4,
          background: 'var(--color-bg-secondary)',
          opacity: translationCardOpen ? 0 : 1,
          transition: 'opacity 200ms',
          pointerEvents: translationCardOpen ? 'none' : 'auto',
        }}
      >
        <div
          style={{
            height: '100%',
            width: `${Math.min(100, Math.max(0, scrollProgress * 100))}%`,
            background: 'var(--color-accent)',
            transition: 'width 150ms',
          }}
        />
      </div>

      {translationCardOpen && selectedWord && (
        <TranslationCard word={selectedWord} sentence={selectedSentence || ''} docId={docId} />
      )}
    </div>
  );
}

function TranslationCard({ word, sentence, docId }: { word: string; sentence: string; docId: string }) {
  const closeTranslationCard = useAppStore((s) => s.closeTranslationCard);
  const cardExpanded = useAppStore((s) => s.cardExpanded);
  const setCardExpanded = useAppStore((s) => s.setCardExpanded);
  const autoAddVocabulary = useAppStore((s) => s.autoAddVocabulary);
  const selectWord = useAppStore((s) => s.selectWord);

  const [wordData, setWordData] = useState<{ phonetic: string; pos: string; definition: string }>({ phonetic: '', pos: '', definition: '' });
  const [phrases, setPhrases] = useState<{ text: string; type: string; meaning: string }[]>([]);
  const [phraseSaved, setPhraseSaved] = useState<Record<string, boolean>>({});

  useEffect(() => {
    let cancelled = false;
    async function lookup() {
      const { lookupWord } = await import('../engine/dictionary');
      const { recognizePhrases } = await import('../engine/phrases');
      const entry = lookupWord(word);
      if (!cancelled) {
        if (entry) {
          setWordData({ phonetic: entry.phonetic, pos: entry.pos, definition: entry.definition });
        } else {
          setWordData({ phonetic: '', pos: '', definition: '未找到释义' });
        }

        const recognized = recognizePhrases(sentence);
        setPhrases(recognized.map((p) => ({ text: p.text, type: p.type, meaning: p.meaning })));
      }
    }
    lookup();
    return () => { cancelled = true; };
  }, [word, sentence]);

  useEffect(() => {
    if (autoAddVocabulary && word) {
      (async () => {
        const existing = await db.vocabulary.where('word').equals(word.toLowerCase()).first();
        if (existing) {
          await db.vocabulary.update(existing.id, {
            lookupCount: existing.lookupCount + 1,
            lastLookupAt: Date.now(),
          });
        } else {
          const doc = await db.documents.get(docId);
          await db.vocabulary.put({
            id: generateId(),
            word: word.toLowerCase(),
            phonetic: wordData.phonetic || '',
            definition: wordData.pos ? `${wordData.pos} ${wordData.definition}` : '',
            proficiency: 2,
            lookupCount: 1,
            firstLookupAt: Date.now(),
            lastLookupAt: Date.now(),
            sourceDocumentId: docId,
            sourceDocumentTitle: doc?.title || '',
          });
        }
      })();
    }
  }, [word, wordData, autoAddVocabulary, docId]);

  async function handleSavePhrase(p: { text: string; type: string; meaning: string }) {
    const key = `${p.text}:${p.type}`;
    const existing = await db.savedPhrases.where('phraseKey').equals(key).first();
    if (existing) {
      setPhraseSaved((prev) => ({ ...prev, [key]: true }));
      return;
    }
    const doc = await db.documents.get(docId);
    await db.savedPhrases.put({
      id: generateId(),
      phraseKey: key,
      text: p.text,
      type: p.type,
      meaning: p.meaning,
      contextSentence: sentence,
      sourceDocumentId: docId,
      sourceDocumentTitle: doc?.title || '',
      createdAt: Date.now(),
    });
    setPhraseSaved((prev) => ({ ...prev, [key]: true }));
  }

  const typeLabel: Record<string, string> = {
    'phrasal_verb': '动词短语',
    'prepositional': '介词短语',
    'collocation': '固定搭配',
    'idiom': '习语',
  };

  return (
    <div
      style={{
        position: 'absolute',
        bottom: 0,
        left: 0,
        right: 0,
        background: 'var(--color-bg-secondary)',
        borderTop: '1px solid var(--color-border)',
        maxHeight: cardExpanded ? '65%' : '40%',
        display: 'flex',
        flexDirection: 'column',
        zIndex: 100,
        transition: 'max-height 250ms',
      }}
    >
      <div
        style={{
          display: 'flex',
          justifyContent: 'center',
          padding: '8px 0',
          cursor: 'ns-resize',
          minHeight: 44,
          alignItems: 'center',
        }}
        onClick={() => setCardExpanded(!cardExpanded)}
      >
        <div style={{ width: 32, height: 3, background: 'var(--color-border)', borderRadius: 0 }} />
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '0 16px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8, marginBottom: 8 }}>
          <span style={{ fontSize: 22, fontWeight: 700 }}>{word}</span>
          {wordData.phonetic && <span style={{ fontSize: 13, color: 'var(--color-text-secondary)' }}>{wordData.phonetic}</span>}
          {wordData.pos && (
            <span style={{
              fontSize: 11,
              color: 'var(--color-accent)',
              border: '1px solid var(--color-accent)',
              padding: '1px 6px',
            }}>
              {wordData.pos}
            </span>
          )}
        </div>

        <p style={{ fontSize: 15, lineHeight: 1.5, margin: '0 0 16px', color: 'var(--color-primary)' }}>
          {wordData.definition}
        </p>

        {phrases.length > 0 && (
          <div>
            <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--color-text-secondary)', marginBottom: 8, textTransform: 'uppercase', letterSpacing: 1 }}>
              本句短语
            </div>
            {phrases.map((p, i) => {
              const key = `${p.text}:${p.type}`;
              return (
                <div
                  key={i}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '10px 0',
                    borderBottom: i < phrases.length - 1 ? '1px solid var(--color-border)' : 'none',
                    gap: 8,
                  }}
                >
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 15, fontWeight: 500 }}>{p.text}</div>
                    <div style={{ fontSize: 12, color: 'var(--color-text-secondary)', display: 'flex', gap: 8 }}>
                      <span style={{ color: 'var(--color-accent)' }}>{typeLabel[p.type] || p.type}</span>
                      <span>{p.meaning}</span>
                    </div>
                  </div>
                  <button
                    onClick={() => handleSavePhrase(p)}
                    disabled={phraseSaved[key]}
                    style={{
                      border: `1px solid ${phraseSaved[key] ? 'var(--color-success)' : 'var(--color-accent)'}`,
                      background: phraseSaved[key] ? 'rgba(52, 199, 89, 0.12)' : 'transparent',
                      color: phraseSaved[key] ? 'var(--color-success)' : 'var(--color-accent)',
                      width: 32, height: 32,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      cursor: phraseSaved[key] ? 'default' : 'pointer',
                      fontSize: 18,
                      fontWeight: 300,
                      flexShrink: 0,
                      minWidth: 44, minHeight: 44,
                      padding: 0,
                    }}
                  >
                    {phraseSaved[key] ? '✓' : '+'}
                  </button>
                </div>
              );
            })}
          </div>
        )}

        {cardExpanded && phrases.length === 0 && (
          <p style={{ fontSize: 13, color: 'var(--color-text-placeholder)', padding: '16px 0' }}>
            当前句子中未识别到短语
          </p>
        )}
      </div>
    </div>
  );
}
