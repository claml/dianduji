import Dexie, { Table } from 'dexie';

export interface Document {
  id: string;
  title: string;
  fileType: 'txt' | 'pdf' | 'docx';
  fileSize: number;
  wordCount: number;
  paragraphCount: number;
  parseStatus: 'pending' | 'parsing' | 'done' | 'failed';
  lastReadPosition: number;
  readProgress: number;
  content: string;
  createdAt: number;
  updatedAt: number;
}

export interface WordRecord {
  id: string;
  sentenceId: string;
  documentId: string;
  text: string;
  lemma: string;
  posTag: string;
  startOffset: number;
  endOffset: number;
}

export interface SentenceRecord {
  id: string;
  paragraphId: string;
  documentId: string;
  index: number;
  text: string;
  startOffset: number;
  endOffset: number;
}

export interface ParagraphRecord {
  id: string;
  documentId: string;
  index: number;
  text: string;
  style: string;
}

export interface PhraseRecord {
  id: string;
  sentenceId: string;
  documentId: string;
  phraseKey: string;
  text: string;
  type: string;
  meaning: string;
  startOffset: number;
  endOffset: number;
}

export interface VocabularyWord {
  id: string;
  word: string;
  phonetic: string;
  definition: string;
  proficiency: number;
  lookupCount: number;
  firstLookupAt: number;
  lastLookupAt: number;
  sourceDocumentId: string;
  sourceDocumentTitle: string;
}

export interface SavedPhrase {
  id: string;
  phraseKey: string;
  text: string;
  type: string;
  meaning: string;
  contextSentence: string;
  sourceDocumentId: string;
  sourceDocumentTitle: string;
  createdAt: number;
}

export interface AppSettings {
  key: string;
  value: any;
}

class AppDatabase extends Dexie {
  documents!: Table<Document, string>;
  paragraphs!: Table<ParagraphRecord, string>;
  sentences!: Table<SentenceRecord, string>;
  words!: Table<WordRecord, string>;
  phrases!: Table<PhraseRecord, string>;
  vocabulary!: Table<VocabularyWord, string>;
  savedPhrases!: Table<SavedPhrase, string>;
  settings!: Table<AppSettings, string>;

  constructor() {
    super('DianDuJiDB');
    this.version(1).stores({
      documents: 'id, title, fileType, parseStatus, createdAt',
      paragraphs: 'id, documentId, index',
      sentences: 'id, paragraphId, documentId, index',
      words: 'id, sentenceId, documentId, lemma, [documentId+lemma]',
      phrases: 'id, sentenceId, phraseKey',
      vocabulary: 'id, word, proficiency, lastLookupAt',
      savedPhrases: 'id, type, createdAt',
      settings: 'key',
    });
  }
}

export const db = new AppDatabase();
