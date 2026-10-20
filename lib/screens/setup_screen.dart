import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

/// First-run setup. Shown only when no binary local data exists yet.
/// After this step the app never shows demo data - everything is the
/// user's own real data.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _name = TextEditingController();
  final _role = TextEditingController(text: 'HR Manager');
  final _rate = TextEditingController(text: '100');
  String _currency = 'BDT';

  static const currencies = ['BDT', 'EGP', 'USD', 'EUR', 'INR', 'SAR', 'AED'];

  @override
  void dispose() {
    _company.dispose();
    _name.dispose();
    _role.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    appState.completeSetup(
      company: _company.text.trim(),
      name: _name.text.trim(),
      role: _role.text.trim().isEmpty ? 'HR Manager' : _role.text.trim(),
      curr: _currency,
      overtimeRate: double.tryParse(_rate.text.trim()) ?? 100,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your Company')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome! This takes less than a minute. Everything you '
                'enter is stored only on this device, in binary local '
                'storage - no account, no server, no demo data.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 13.5),
              ),
              const SizedBox(height: 20),
              _label('Company Name'),
              TextFormField(
                controller: _company,
                decoration:
                    const InputDecoration(hintText: 'e.g. Dewan Furniture'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter your company name'
                    : null,
              ),
              const SizedBox(height: 14),
              _label('Your Name'),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(hintText: 'Your full name'),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: 14),
              _label('Your Role'),
              TextFormField(
                controller: _role,
                decoration: const InputDecoration(hintText: 'HR Manager'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Currency'),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _currency,
                          items: currencies
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _currency = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Overtime Rate / hour'),
                        TextFormField(
                          controller: _rate,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '100'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            return double.tryParse(v.trim()) == null
                                ? 'Numbers only'
                                : null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Start Using HR Management'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(t,
            style:
                const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      );
}
