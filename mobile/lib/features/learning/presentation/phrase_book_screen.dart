import 'package:flutter/material.dart';

import '../../phrases/domain/phrase_type.dart';

class SavedPhraseListItem {
  const SavedPhraseListItem({
    required this.surface,
    required this.meaning,
    required this.type,
    required this.context,
  });

  final String surface;
  final String meaning;
  final PhraseType type;
  final String context;
}

class PhraseBookScreen extends StatefulWidget {
  const PhraseBookScreen({required this.phrases, super.key});

  final List<SavedPhraseListItem> phrases;

  @override
  State<PhraseBookScreen> createState() => _PhraseBookScreenState();
}

class _PhraseBookScreenState extends State<PhraseBookScreen> {
  PhraseType? _filter;

  @override
  Widget build(BuildContext context) {
    final visible = widget.phrases
        .where((phrase) => _filter == null || phrase.type == _filter)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('短语本')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _chip('全部', null),
                const SizedBox(width: 8),
                _chip('短语动词', PhraseType.phrasalVerb),
                const SizedBox(width: 8),
                _chip('介词短语', PhraseType.prepositionalPhrase),
                const SizedBox(width: 8),
                _chip('搭配', PhraseType.collocation),
                const SizedBox(width: 8),
                _chip('习语', PhraseType.idiom),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('还没有收藏短语'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: visible.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final phrase = visible[index];
                      return Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                phrase.surface,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(phrase.meaning),
                              const SizedBox(height: 10),
                              Text(
                                phrase.context,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, PhraseType? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}
