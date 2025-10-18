import 'package:flutter/material.dart';
import 'package:my_flutter_project/ui/app_shell.dart';
import 'history_service.dart';
import 'history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool includeText = false;
  bool loading = true;
  String? error;
  List<HistoryItem> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await HistoryService.instance.fetchHistory(includeText: includeText);
      if (!mounted) return;
      setState(() {
        items = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppShell(
      title: 'Analysis History',
      selectedIndex: 1,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Switch(
                      value: includeText,
                      onChanged: (v) async {
                        setState(() => includeText = v);
                        await _load();
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Include essay text'),
                    const Spacer(),
                    IconButton(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    )
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: Builder(
                    builder: (_) {
                      if (loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (error != null) {
                        return ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                              ),
                            ),
                          ],
                        );
                      }
                      if (items.isEmpty) {
                        return ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No history yet.'),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final h = items[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'AI: ${h.aiPercent.toStringAsFixed(1)}%  |  Human: ${h.humanPercent.toStringAsFixed(1)}%',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      if (h.createdAt != null)
                                        Text(
                                          h.createdAt.toString(),
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (h.reasoning.isNotEmpty)
                                    Text('Reasoning: ${h.reasoning}'),
                                  if (includeText && (h.essayText?.isNotEmpty ?? false)) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: theme.colorScheme.outlineVariant),
                                      ),
                                      child: Text(
                                        h.essayText!,
                                        style: const TextStyle(height: 1.3),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}