String normalizeEnglishWord(String value) =>
    value.trim().replaceAll('’', "'").toLowerCase();
