import 'package:flutter/material.dart';
import 'payments_service.dart';
import 'ui/app_shell.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final phoneController = TextEditingController(text: '2547');
  int balance = 0;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final b = await PaymentsService.instance.fetchWalletBalance();
      if (!mounted) return;
      setState(() { balance = b; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  Future<void> _buy(int credits) async {
    setState(() { loading = true; error = null; });
    try {
      await PaymentsService.instance.initiateStkPush(credits: credits, phone: phoneController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('STK push sent. Enter your PIN on your phone.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current balance: $balance credits', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'M-PESA Phone (e.g., 2547XXXXXXXX)')
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in [10,20,50,100])
                    ElevatedButton(
                      onPressed: loading ? null : () => _buy(c),
                      child: Text('Buy $c'),
                    )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: loading ? null : _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Balance'),
                  ),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return AppShell(
      title: 'Buy Credits',
      selectedIndex: 2,
      body: content,
    );
  }
}
