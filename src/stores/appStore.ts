import { create } from 'zustand';

export type Theme = 'day' | 'night' | 'eye-care';
export type Proficiency = 0 | 1 | 2;
export type SortBy = 'time' | 'alpha' | 'frequency';
export type TabPage = 'documents' | 'vocabulary' | 'phrases' | 'settings';

interface AppState {
  currentTab: TabPage;
  theme: Theme;
  fontSize: number;
  lineHeight: number;
  autoAddVocabulary: boolean;
  selectedWord: string | null;
  selectedSentence: string | null;
  translationCardOpen: boolean;
  cardExpanded: boolean;
  documentSortBy: SortBy;
  vocabularyFilter: 'all' | 'known' | 'vague' | 'unknown';
  vocabularySortBy: SortBy;
  phraseFilter: string;
  searchQuery: string;

  setTab: (tab: TabPage) => void;
  setTheme: (theme: Theme) => void;
  setFontSize: (size: number) => void;
  setLineHeight: (height: number) => void;
  setAutoAddVocabulary: (auto: boolean) => void;
  selectWord: (word: string | null, sentence?: string | null) => void;
  closeTranslationCard: () => void;
  setCardExpanded: (expanded: boolean) => void;
  setDocumentSortBy: (sort: SortBy) => void;
  setVocabularyFilter: (filter: 'all' | 'known' | 'vague' | 'unknown') => void;
  setVocabularySortBy: (sort: SortBy) => void;
  setPhraseFilter: (filter: string) => void;
  setSearchQuery: (query: string) => void;
}

export const useAppStore = create<AppState>((set) => ({
  currentTab: 'documents',
  theme: 'day',
  fontSize: 16,
  lineHeight: 1.6,
  autoAddVocabulary: true,
  selectedWord: null,
  selectedSentence: null,
  translationCardOpen: false,
  cardExpanded: false,
  documentSortBy: 'time',
  vocabularyFilter: 'all',
  vocabularySortBy: 'time',
  phraseFilter: 'all',
  searchQuery: '',

  setTab: (tab) => set({ currentTab: tab }),
  setTheme: (theme) => set({ theme }),
  setFontSize: (size) => set({ fontSize: Math.max(12, Math.min(24, size)) }),
  setLineHeight: (height) => set({ lineHeight: Math.max(1.4, Math.min(2.0, height)) }),
  setAutoAddVocabulary: (auto) => set({ autoAddVocabulary: auto }),
  selectWord: (word, sentence = null) =>
    set({
      selectedWord: word,
      selectedSentence: sentence,
      translationCardOpen: word !== null,
      cardExpanded: false,
    }),
  closeTranslationCard: () =>
    set({ translationCardOpen: false, cardExpanded: false }),
  setCardExpanded: (expanded) => set({ cardExpanded: expanded }),
  setDocumentSortBy: (sort) => set({ documentSortBy: sort }),
  setVocabularyFilter: (filter) => set({ vocabularyFilter: filter }),
  setVocabularySortBy: (sort) => set({ vocabularySortBy: sort }),
  setPhraseFilter: (filter) => set({ phraseFilter: filter }),
  setSearchQuery: (query) => set({ searchQuery: query }),
}));
