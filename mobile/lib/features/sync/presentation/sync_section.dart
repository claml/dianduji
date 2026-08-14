import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'sync_controller.dart';

/// Login / cloud-sync section embedded in the settings page.
class SyncSection extends ConsumerStatefulWidget {
  const SyncSection({super.key});

  @override
  ConsumerState<SyncSection> createState() => _SyncSectionState();
}

class _SyncSectionState extends ConsumerState<SyncSection> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(syncControllerProvider);
    final state = controller.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('账号与云同步', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text(
          '登录后在多设备间同步生词本与设置（需自建网关，见 docs/gateway-reference/sync-api.md）。',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (state.errorMessage != null) ...[
          Semantics(
            container: true,
            liveRegion: true,
            label: state.errorMessage!,
            excludeSemantics: true,
            child: Text(
              state.errorMessage!,
              key: const Key('sync-error'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (state.status != SyncUiStatus.loggedIn)
          _loginForm(context, state, controller),
        if (state.status == SyncUiStatus.loggedIn)
          _loggedInPane(context, state, controller),
      ],
    );
  }

  Widget _loginForm(
    BuildContext context,
    SyncUiState state,
    SyncController controller,
  ) {
    final working = state.status == SyncUiStatus.working;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('sync-username'),
          controller: _username,
          enabled: !working,
          decoration: const InputDecoration(
            labelText: '用户名',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('sync-password'),
          controller: _password,
          enabled: !working,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: '密码（至少 6 位）',
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: IconButton(
              tooltip: _obscure ? '显示密码' : '隐藏密码',
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                key: const Key('sync-login'),
                onPressed: working
                    ? null
                    : () => controller.login(
                          _username.text.trim(),
                          _password.text,
                        ),
                child: working
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                key: const Key('sync-register'),
                onPressed: working
                    ? null
                    : () => controller.register(
                          _username.text.trim(),
                          _password.text,
                        ),
                child: const Text('注册'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loggedInPane(
    BuildContext context,
    SyncUiState state,
    SyncController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_done_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '已登录：${state.username ?? ''}',
                key: const Key('sync-username-label'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            TextButton(
              key: const Key('sync-logout'),
              onPressed: state.syncing ? null : controller.logout,
              child: const Text('退出登录'),
            ),
          ],
        ),
        if (state.lastSyncAt != null) ...[
          const SizedBox(height: 6),
          Text(
            '上次同步：${_formatTime(state.lastSyncAt!)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            key: const Key('sync-now'),
            onPressed: state.syncing ? null : controller.syncNow,
            icon: state.syncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync, size: 18),
            label: Text(state.syncing ? '同步中…' : '立即同步'),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
