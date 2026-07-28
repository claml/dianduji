import { useAppStore } from './stores/appStore';
import BottomNav from './components/BottomNav';
import DocumentList from './pages/DocumentList';
import VocabularyBook from './pages/VocabularyBook';
import PhraseBook from './pages/PhraseBook';
import Settings from './pages/Settings';

export default function App() {
  const currentTab = useAppStore((s) => s.currentTab);
  const theme = useAppStore((s) => s.theme);

  const themeClass = theme === 'night' ? 'theme-night' : theme === 'eye-care' ? 'theme-eye-care' : '';

  return (
    <div className={themeClass} style={{ height: '100%', display: 'flex', flexDirection: 'column', background: 'var(--color-bg)', color: 'var(--color-primary)' }}>
      <div style={{ flex: 1, overflow: 'hidden', position: 'relative' }}>
        {currentTab === 'documents' && <DocumentList />}
        {currentTab === 'vocabulary' && <VocabularyBook />}
        {currentTab === 'phrases' && <PhraseBook />}
        {currentTab === 'settings' && <Settings />}
      </div>
      <BottomNav />
    </div>
  );
}
