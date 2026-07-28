import 'package:flutter/material.dart';

class ReaderToken {
  const ReaderToken({required this.id, required this.surface});

  final String id;
  final String surface;
}

class TokenText extends StatelessWidget {
  const TokenText({
    required this.token,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ReaderToken token;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      key: Key('token-semantics-${token.id}'),
      button: true,
      selected: selected,
      label: '${token.surface}，点按查看释义',
      child: GestureDetector(
        key: Key(token.id),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.12) : null,
            border: Border(
              bottom: BorderSide(
                color: selected ? primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(token.surface),
        ),
      ),
    );
  }
}
