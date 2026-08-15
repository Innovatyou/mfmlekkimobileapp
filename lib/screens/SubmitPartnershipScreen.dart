import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:higherground/models/Partnership.dart';
import 'package:higherground/models/PartnershipTier.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';

// ── Args ─────────────────────────────────────────────────────────────────────

class SubmitPartnershipArgs {
  final List<PartnershipTier> tiers;
  final Partnership? editPledge;

  const SubmitPartnershipArgs({required this.tiers, this.editPledge});
}

// ── Screen ───────────────────────────────────────────────────────────────────

class SubmitPartnershipScreen extends StatefulWidget {
  static const routeName = '/submit_partnership';

  const SubmitPartnershipScreen({Key? key}) : super(key: key);

  @override
  State<SubmitPartnershipScreen> createState() =>
      _SubmitPartnershipScreenState();
}

class _SubmitPartnershipScreenState extends State<SubmitPartnershipScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  List<PartnershipTier> _tiers = [];
  PartnershipTier? _selectedTier;
  String _currency = 'USD';
  String _frequency = 'monthly';
  bool _submitting = false;
  bool _argsLoaded = false;
  bool _isEdit = false;
  Partnership? _editPledge;

  static const _currencies = ['USD', 'NGN', 'GBP', 'EUR'];
  static const _frequencies = [
    ('one-time', 'One-Time'),
    ('monthly', 'Monthly'),
    ('quarterly', 'Quarterly'),
    ('annually', 'Annually'),
  ];

  @override
  void initState() {
    super.initState();
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata != null) {
      final full =
          '${userdata.firstname ?? ''} ${userdata.lastname ?? ''}'.trim();
      if (full.isNotEmpty) _nameCtrl.text = full;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is SubmitPartnershipArgs) {
      _tiers = args.tiers;
      if (args.editPledge != null) {
        _isEdit = true;
        _editPledge = args.editPledge;
        final p = args.editPledge!;
        _nameCtrl.text = p.partnerName;
        _phoneCtrl.text = p.partnerPhone ?? '';
        _amountCtrl.text =
            p.pledgeAmount > 0 ? p.pledgeAmount.toStringAsFixed(2) : '';
        _currency = p.currency;
        _frequency = p.frequency;
        _notesCtrl.text = p.notes ?? '';
        if (p.tierId != null) {
          _selectedTier = _tiers
              .cast<PartnershipTier?>()
              .firstWhere((t) => t?.id == p.tierId, orElse: () => null);
        }
      }
    } else if (args is List<PartnershipTier>) {
      _tiers = args;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) return;

    setState(() => _submitting = true);

    try {
      final Map<String, dynamic> payload = {
        'email': userdata.email ?? '',
        'partner_name': _nameCtrl.text.trim(),
        'partner_phone': _phoneCtrl.text.trim(),
        'pledge_amount': _amountCtrl.text.trim(),
        'currency': _currency,
        'frequency': _frequency,
        'tier_id': _selectedTier?.id.toString() ?? '',
        'notes': _notesCtrl.text.trim(),
      };

      final String endpoint;
      if (_isEdit && _editPledge != null) {
        payload['partnership_id'] = _editPledge!.id.toString();
        endpoint = ApiUrl.UPDATE_PARTNERSHIP_PLEDGE;
      } else {
        endpoint = ApiUrl.SUBMIT_PARTNERSHIP_PLEDGE;
      }

      final response =
          await (await Utility.getAuthenticatedDio()).post(endpoint, data: payload);

      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      if (!mounted) return;
      setState(() => _submitting = false);

      if (res != null && res['status'] == 'ok') {
        _showReviewDialog();
      } else {
        final msg = res?['message']?.toString() ?? 'Something went wrong.';
        _showError(msg);
      }
    } catch (e) {
      if (mounted) setState(() => _submitting = false);
      _showError('Network error. Please try again.');
    }
  }

  void _showReviewDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF059669), size: 32),
              ),
              const SizedBox(height: 18),
              Text(
                _isEdit ? 'Changes Submitted' : 'Application Submitted',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: MyColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _isEdit
                    ? 'Your changes have been submitted and are pending re-approval. We\'ll review them shortly.'
                    : 'Your partnership application has been submitted for review. We\'ll be in touch soon.',
                style: const TextStyle(
                    fontSize: 13.5,
                    color: MyColors.textSecondary,
                    height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 46),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: MyColors.danger,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEdit ? 'Edit Pledge' : 'Make a Pledge',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEdit)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Editing will reset your pledge to pending status for re-approval.',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF92400E),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildCard(children: [
                _label('Full Name'),
                _field(
                  controller: _nameCtrl,
                  hint: 'Your full name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                _label('Phone (optional)'),
                _field(
                  controller: _phoneCtrl,
                  hint: 'Your phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ]),
              const SizedBox(height: 14),
              _buildCard(children: [
                _label('Partnership Tier (optional)'),
                const SizedBox(height: 8),
                _TierPicker(
                  tiers: _tiers,
                  selected: _selectedTier,
                  onChanged: (t) => setState(() => _selectedTier = t),
                ),
              ]),
              const SizedBox(height: 14),
              _buildCard(children: [
                _label('Pledge Amount'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CurrencyPicker(
                      value: _currency,
                      currencies: _currencies,
                      onChanged: (c) => setState(() => _currency = c),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        controller: _amountCtrl,
                        hint: '0.00',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Amount is required';
                          }
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _label('Frequency'),
                const SizedBox(height: 8),
                _FrequencyPicker(
                  value: _frequency,
                  options: _frequencies,
                  onChanged: (f) => setState(() => _frequency = f),
                ),
              ]),
              const SizedBox(height: 14),
              _buildCard(children: [
                _label('Notes (optional)'),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(
                      fontSize: 14, color: MyColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Any additional message…',
                    hintStyle: const TextStyle(
                        color: MyColors.textDisabled, fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: MyColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: MyColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: MyColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const CupertinoActivityIndicator(
                          color: Colors.white, radius: 10)
                      : Text(
                          _isEdit ? 'Update Pledge' : 'Submit Pledge',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MyColors.textSecondary)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: MyColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: MyColors.textDisabled, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: MyColors.textDisabled),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.danger, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ── Tier Picker ──────────────────────────────────────────────────────────────

class _TierPicker extends StatelessWidget {
  final List<PartnershipTier> tiers;
  final PartnershipTier? selected;
  final ValueChanged<PartnershipTier?> onChanged;

  const _TierPicker(
      {required this.tiers, required this.selected, required this.onChanged});

  Color _hexColor(String? hex) {
    if (hex == null || hex.isEmpty) return MyColors.primary;
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return MyColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    if (tiers.isEmpty) {
      return const Text('No tiers available',
          style: TextStyle(color: MyColors.textDisabled, fontSize: 13));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: () => onChanged(null),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected == null
                  ? MyColors.primaryVeryLight
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected == null ? MyColors.primary : MyColors.border,
                width: selected == null ? 1.5 : 1,
              ),
            ),
            child: Text(
              'None',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected == null
                    ? MyColors.primary
                    : MyColors.textSecondary,
              ),
            ),
          ),
        ),
        ...tiers.map((t) {
          final isSelected = selected?.id == t.id;
          final color = _hexColor(t.color);
          return GestureDetector(
            onTap: () => onChanged(t),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.12)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color : MyColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                t.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? color : MyColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Currency Picker ──────────────────────────────────────────────────────────

class _CurrencyPicker extends StatelessWidget {
  final String value;
  final List<String> currencies;
  final ValueChanged<String> onChanged;

  const _CurrencyPicker(
      {required this.value,
      required this.currencies,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MyColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: currencies
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MyColors.textPrimary)),
                  ))
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
          icon: const Icon(Icons.expand_more_rounded,
              size: 16, color: MyColors.textDisabled),
        ),
      ),
    );
  }
}

// ── Frequency Picker ─────────────────────────────────────────────────────────

class _FrequencyPicker extends StatelessWidget {
  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;

  const _FrequencyPicker(
      {required this.value,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final (key, label) = opt;
        final isSelected = value == key;
        return GestureDetector(
          onTap: () => onChanged(key),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? MyColors.primaryVeryLight
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? MyColors.primary : MyColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    isSelected ? MyColors.primary : MyColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
