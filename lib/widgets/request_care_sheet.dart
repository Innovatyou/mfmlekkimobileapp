import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/wellness_provider.dart';

class RequestCareSheet extends StatefulWidget {
  final String email;
  final VoidCallback onSuccess;

  const RequestCareSheet({
    Key? key,
    required this.email,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<RequestCareSheet> createState() => _RequestCareSheetState();
}

class _RequestCareSheetState extends State<RequestCareSheet> {
  String? _selectedType;
  final _msgCtrl = TextEditingController();
  bool _submitting = false;

  static const _careTypes = [
    _CareTypeOption('call',       '\u{1F4DE}', 'Phone Call'),
    _CareTypeOption('visit',      '\u{1F3E0}', 'Home Visit'),
    _CareTypeOption('prayer',     '\u{1F64F}', 'Prayer'),
    _CareTypeOption('counseling', '\u{1F4AC}', 'Counseling'),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a care type.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<WellnessProvider>().requestCare(
            widget.email,
            _selectedType!,
            _msgCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Your request has been sent. We\'ll be in touch soon. \u{1F64F}'),
          backgroundColor: Color(0xFF10b981),
        ),
      );
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFe2e8f0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'Request Pastoral Care',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1e293b)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Let our pastoral team know you\'d like to connect.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748b)),
            ),
            const SizedBox(height: 20),

            // 2×2 care type grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: _careTypes.map((opt) {
                final selected = _selectedType == opt.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = opt.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFe0e7ff)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF6366f1)
                            : const Color(0xFFe2e8f0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(opt.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(opt.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? const Color(0xFF6366f1)
                                  : const Color(0xFF475569),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Optional message
            TextField(
              controller: _msgCtrl,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Anything you\'d like us to know? (optional)',
                hintStyle:
                    const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF6366f1), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.favorite_rounded, size: 18),
                label: Text(
                  _submitting ? 'Sending...' : 'Send Request',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFa5b4fc),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareTypeOption {
  final String value;
  final String emoji;
  final String label;
  const _CareTypeOption(this.value, this.emoji, this.label);
}
