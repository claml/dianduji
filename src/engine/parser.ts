export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 10);
}

export function tokenizeWords(text: string): { word: string; start: number; end: number }[] {
  const tokens: { word: string; start: number; end: number }[] = [];
  const regex = /[a-zA-Z]+(?:'[a-zA-Z]+)?/g;
  let match: RegExpExecArray | null;
  while ((match = regex.exec(text)) !== null) {
    tokens.push({ word: match[0], start: match.index, end: match.index + match[0].length });
  }
  return tokens;
}

export function splitSentences(text: string): { text: string; start: number; end: number }[] {
  const sentences: { text: string; start: number; end: number }[] = [];
  const regex = /[^.!?\n]+[.!?]*(\s|$)|[^.!?\n]+\n/g;
  let match: RegExpExecArray | null;
  while ((match = regex.exec(text)) !== null) {
    const s = match[0].trim();
    if (s.length > 1) {
      sentences.push({ text: s, start: match.index, end: match.index + match[0].length });
    }
  }
  return sentences;
}

export function splitParagraphs(text: string): { text: string; style: string }[] {
  const paragraphs: { text: string; style: string }[] = [];
  const lines = text.split(/\n\s*\n/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    const isHeading = /^[IVX]+\.\s|^Chapter\s|^第[一二三四五六七八九十]/.test(trimmed);
    paragraphs.push({
      text: trimmed,
      style: isHeading ? 'heading1' : 'normal',
    });
  }
  return paragraphs;
}

const IRREGULARS: Record<string, string> = {
  'ran': 'run', 'running': 'run', 'runs': 'run',
  'was': 'be', 'were': 'be', 'been': 'be', 'being': 'be', 'am': 'be', 'are': 'be', 'is': 'be',
  'had': 'have', 'has': 'have', 'having': 'have',
  'did': 'do', 'does': 'do', 'done': 'do', 'doing': 'do',
  'went': 'go', 'gone': 'go', 'goes': 'go', 'going': 'go',
  'made': 'make', 'makes': 'make', 'making': 'make',
  'took': 'take', 'taken': 'take', 'takes': 'take', 'taking': 'take',
  'came': 'come', 'comes': 'come', 'coming': 'come',
  'saw': 'see', 'seen': 'see', 'sees': 'see', 'seeing': 'see',
  'knew': 'know', 'known': 'know', 'knows': 'know', 'knowing': 'know',
  'got': 'get', 'gotten': 'get', 'gets': 'get', 'getting': 'get',
  'gave': 'give', 'given': 'give', 'gives': 'give', 'giving': 'give',
  'found': 'find', 'finds': 'find', 'finding': 'find',
  'thought': 'think', 'thinks': 'think', 'thinking': 'think',
  'told': 'tell', 'tells': 'tell', 'telling': 'tell',
  'became': 'become', 'becomes': 'become', 'becoming': 'become',
  'left': 'leave', 'leaves': 'leave', 'leaving': 'leave',
  'felt': 'feel', 'feels': 'feel', 'feeling': 'feel',
  'put': 'put', 'puts': 'put', 'putting': 'put',
  'brought': 'bring', 'brings': 'bring', 'bringing': 'bring',
  'began': 'begin', 'begun': 'begin', 'begins': 'begin', 'beginning': 'begin',
  'kept': 'keep', 'keeps': 'keep', 'keeping': 'keep',
  'held': 'hold', 'holds': 'hold', 'holding': 'hold',
  'wrote': 'write', 'written': 'write', 'writes': 'write', 'writing': 'write',
  'stood': 'stand', 'stands': 'stand', 'standing': 'stand',
  'heard': 'hear', 'hears': 'hear', 'hearing': 'hear',
  'let': 'let', 'lets': 'let', 'letting': 'let',
  'meant': 'mean', 'means': 'mean', 'meaning': 'mean',
  'set': 'set', 'sets': 'set', 'setting': 'set',
  'met': 'meet', 'meets': 'meet', 'meeting': 'meet',
  'paid': 'pay', 'pays': 'pay', 'paying': 'pay',
  'sat': 'sit', 'sits': 'sit', 'sitting': 'sit',
  'spoke': 'speak', 'spoken': 'speak', 'speaks': 'speak', 'speaking': 'speak',
  'lay': 'lie', 'lain': 'lie', 'lies': 'lie', 'lying': 'lie',
  'led': 'lead', 'leads': 'lead', 'leading': 'lead',
  'read': 'read', 'reads': 'read', 'reading': 'read',
  'grew': 'grow', 'grown': 'grow', 'grows': 'grow', 'growing': 'grow',
  'lost': 'lose', 'loses': 'lose', 'losing': 'lose',
  'fell': 'fall', 'fallen': 'fall', 'falls': 'fall', 'falling': 'fall',
  'sent': 'send', 'sends': 'send', 'sending': 'send',
  'built': 'build', 'builds': 'build', 'building': 'build',
  'understood': 'understand', 'understands': 'understand', 'understanding': 'understand',
  'drew': 'draw', 'drawn': 'draw', 'draws': 'draw', 'drawing': 'draw',
  'broke': 'break', 'broken': 'break', 'breaks': 'break', 'breaking': 'break',
  'spent': 'spend', 'spends': 'spend', 'spending': 'spend',
  'cut': 'cut', 'cuts': 'cut', 'cutting': 'cut',
  'rose': 'rise', 'risen': 'rise', 'rises': 'rise', 'rising': 'rise',
  'drove': 'drive', 'driven': 'drive', 'drives': 'drive', 'driving': 'drive',
  'bought': 'buy', 'buys': 'buy', 'buying': 'buy',
  'wore': 'wear', 'worn': 'wear', 'wears': 'wear', 'wearing': 'wear',
  'chose': 'choose', 'chosen': 'choose', 'chooses': 'choose', 'choosing': 'choose',
  'sought': 'seek', 'seeks': 'seek', 'seeking': 'seek',
  'threw': 'throw', 'thrown': 'throw', 'throws': 'throw', 'throwing': 'throw',
  'caught': 'catch', 'catches': 'catch', 'catching': 'catch',
  'dealt': 'deal', 'deals': 'deal', 'dealing': 'deal',
  'won': 'win', 'wins': 'win', 'winning': 'win',
  'taught': 'teach', 'teaches': 'teach', 'teaching': 'teach',
  'sold': 'sell', 'sells': 'sell', 'selling': 'sell',
  'ate': 'eat', 'eaten': 'eat', 'eats': 'eat', 'eating': 'eat',
  'flew': 'fly', 'flown': 'fly', 'flies': 'fly', 'flying': 'fly',
  'swam': 'swim', 'swum': 'swim', 'swims': 'swim', 'swimming': 'swim',
  'drank': 'drink', 'drunk': 'drink', 'drinks': 'drink', 'drinking': 'drink',
  'rang': 'ring', 'rung': 'ring', 'rings': 'ring', 'ringing': 'ring',
  'sang': 'sing', 'sung': 'sing', 'sings': 'sing', 'singing': 'sing',
  'blew': 'blow', 'blown': 'blow', 'blows': 'blow', 'blowing': 'blow',
  'rode': 'ride', 'ridden': 'ride', 'rides': 'ride', 'riding': 'ride',
  'slept': 'sleep', 'sleeps': 'sleep', 'sleeping': 'sleep',
  'shook': 'shake', 'shaken': 'shake', 'shakes': 'shake', 'shaking': 'shake',
  'bore': 'bear', 'borne': 'bear', 'bears': 'bear', 'bearing': 'bear',
  'forgot': 'forget', 'forgotten': 'forget', 'forgets': 'forget', 'forgetting': 'forget',
  'froze': 'freeze', 'frozen': 'freeze', 'freezes': 'freeze', 'freezing': 'freeze',
  'swore': 'swear', 'sworn': 'swear', 'swears': 'swear', 'swearing': 'swear',
  'hid': 'hide', 'hidden': 'hide', 'hides': 'hide', 'hiding': 'hide',
  'lent': 'lend', 'lends': 'lend', 'lending': 'lend',
  'fed': 'feed', 'feeds': 'feed', 'feeding': 'feed',
  'bit': 'bite', 'bitten': 'bite', 'bites': 'bite', 'biting': 'bite',
  'shot': 'shoot', 'shoots': 'shoot', 'shooting': 'shoot',
  'struck': 'strike', 'stricken': 'strike', 'strikes': 'strike', 'striking': 'strike',
  'dug': 'dig', 'digs': 'dig', 'digging': 'dig',
  'stuck': 'stick', 'sticks': 'stick', 'sticking': 'stick',
  'swept': 'sweep', 'sweeps': 'sweep', 'sweeping': 'sweep',
  'wept': 'weep', 'weeps': 'weep', 'weeping': 'weep',
  'bent': 'bend', 'bends': 'bend', 'bending': 'bend',
  'shone': 'shine', 'shines': 'shine', 'shining': 'shine',
  'hung': 'hang', 'hangs': 'hang', 'hanging': 'hang',
  'lit': 'light', 'lights': 'light', 'lighting': 'light',
  'fought': 'fight', 'fights': 'fight', 'fighting': 'fight',
  'wound': 'wind', 'winds': 'wind', 'winding': 'wind',
  'stole': 'steal', 'stolen': 'steal', 'steals': 'steal', 'stealing': 'steal',
  'tore': 'tear', 'torn': 'tear', 'tears': 'tear', 'tearing': 'tear',
  'sped': 'speed', 'speeds': 'speed', 'speeding': 'speed',
  'withdrew': 'withdraw', 'withdrawn': 'withdraw', 'withdraws': 'withdraw',
  'knelt': 'kneel', 'kneels': 'kneel', 'kneeling': 'kneel',
  'forecast': 'forecast', 'forecasts': 'forecast',
  'leapt': 'leap', 'leaps': 'leap', 'leaping': 'leap',
  'spoilt': 'spoil', 'spoils': 'spoil', 'spoiling': 'spoil',
  'dreamt': 'dream', 'dreams': 'dream', 'dreaming': 'dream',
  'burnt': 'burn', 'burns': 'burn', 'burning': 'burn',
  'spilt': 'spill', 'spills': 'spill', 'spilling': 'spill',
  'learnt': 'learn', 'learns': 'learn', 'learning': 'learn',
  'smelt': 'smell', 'smells': 'smell', 'smelling': 'smell',
  'spelt': 'spell', 'spells': 'spell', 'spelling': 'spell',
  'dwelt': 'dwell', 'dwells': 'dwell', 'dwelling': 'dwell',
  'leaned': 'lean', 'leans': 'lean', 'leaning': 'lean',
};

export function lemmatize(word: string): string {
  const lower = word.toLowerCase();
  if (IRREGULARS[lower]) return IRREGULARS[lower];
  if (lower.endsWith('ies') && lower.length > 4) return lower.slice(0, -3) + 'y';
  if (lower.endsWith('ves') && lower.length > 4) return lower.slice(0, -3) + 'f';
  if (lower.endsWith('es') && /(ss|sh|ch|x|zz)es$/.test(lower)) return lower.slice(0, -2);
  if (lower.endsWith('s') && !lower.endsWith('ss') && lower.length > 3) {
    const base = lower.slice(0, -1);
    if (!IRREGULARS[base]) return base;
  }
  if (lower.endsWith('ed') && lower.length > 4) {
    const base = lower.slice(0, -2);
    if (IRREGULARS[base]) return IRREGULARS[base];
    return base.endsWith('i') ? base.slice(0, -1) + 'y' : base;
  }
  if (lower.endsWith('ing') && lower.length > 5) {
    const base = lower.slice(0, -3);
    if (IRREGULARS[base]) return IRREGULARS[base];
    const withE = base + 'e';
    if (IRREGULARS[withE]) return IRREGULARS[withE];
    return base.endsWith(base[base.length - 1]) ? base.slice(0, -1) : base;
  }
  if (lower.endsWith('er') && lower.length > 4) return lower.slice(0, -2);
  if (lower.endsWith('est') && lower.length > 5) return lower.slice(0, -3);
  if (lower.endsWith("'s")) return lower.slice(0, -2);
  return lower;
}
