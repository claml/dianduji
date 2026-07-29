import 'package:flutter/material.dart';

enum VocabularyProficiency { known, vague, unknown }

class VocabularyListItem {
  const VocabularyListItem({
    required this.lemma,
    required this.phonetic,
    required this.definition,
    required this.proficiency,
    required this.lookupCount,
  });

  final String lemma;
  final String phonetic;
  final String definition;
  final VocabularyProficiency proficiency;
  final int lookupCount;
}

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({required this.entries, super.key});

  final List<VocabularyListItem> entries;

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String _query = '';
  VocabularyProficiency? _filter;

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final visible = widget.entries
        .where(
          (entry) =>
              (_filter == null || entry.proficiency == _filter) &&
              (normalized.isEmpty ||
                  entry.lemma.toLowerCase().contains(normalized) ||
                  entry.definition.contains(normalized)),
        )
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('生词本'),
        actions: [
          IconButton(
            tooltip: '导出 CSV',
            onPressed: widget.entries.isEmpty ? null : () {},
            icon: const Icon(Icons.ios_share_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              hintText: '搜索单词或中文释义',
              leading: const Icon(Icons.search_rounded),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('全部', null),
                const SizedBox(width: 8),
                _filterChip('认识', VocabularyProficiency.known),
                const SizedBox(width: 8),
                _filterChip('模糊', VocabularyProficiency.vague),
                const SizedBox(width: 8),
                _filterChip('陌生', VocabularyProficiency.unknown),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('没有符合条件的生词'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: visible.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = visible[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        title: Text(
                          entry.lemma,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${entry.phonetic}\n${entry.definition}',
                        ),
                        isThreeLine: true,
                        trailing: Text('查询 ${entry.lookupCount} 次'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, VocabularyProficiency? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}
