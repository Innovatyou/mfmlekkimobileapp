import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';

const List<Map<String, dynamic>> _kCategories = [
  {'value': 'marriage', 'label': 'Marriage', 'icon': Icons.favorite_rounded},
  {'value': 'family', 'label': 'Family', 'icon': Icons.people_rounded},
  {'value': 'grief', 'label': 'Grief & Loss', 'icon': Icons.spa_rounded},
  {'value': 'addiction', 'label': 'Addiction', 'icon': Icons.warning_rounded},
  {
    'value': 'mental_health',
    'label': 'Mental Health',
    'icon': Icons.psychology_rounded
  },
  {
    'value': 'financial',
    'label': 'Financial',
    'icon': Icons.account_balance_wallet_rounded
  },
  {'value': 'spiritual', 'label': 'Spiritual', 'icon': Icons.menu_book_rounded},
  {
    'value': 'relationship',
    'label': 'Relationships',
    'icon': Icons.group_rounded
  },
  {
    'value': 'other',
    'label': 'Other',
    'icon': Icons.chat_bubble_outline_rounded
  },
];

class SubmitCounselingScreen extends StatefulWidget {
  static const routeName = '/counseling/submit';

  const SubmitCounselingScreen({Key? key}) : super(key: key);

  @override
  State<SubmitCounselingScreen> createState() => _SubmitCounselingScreenState();
}

class _SubmitCounselingScreenState extends State<SubmitCounselingScreen> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _selectedCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      _showError('Please select a category.');
      return;
    }
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) return;

    setState(() => _submitting = true);

    try {
      final response = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.SUBMIT_COUNSELING_REQUEST,
        data: FormData.fromMap({
          'email': userdata.email ?? '',
          'name':
              '${userdata.firstname ?? ''} ${userdata.lastname ?? ''}'.trim(),
          'category': _selectedCategory,
          'title': _titleCtrl.text.trim(),
          'note': _noteCtrl.text.trim(),
        }),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      dynamic res;
      try {
        res = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
      } catch (_) {
        _showError('Server returned an unexpected response. Please try again.');
        return;
      }

      if (res == null) {
        _showError('No response from server. Please try again.');
        return;
      }

      if (res['status'] == 'ok') {
        _showSuccessDialog(res['message'] as String? ??
            'Your counseling request has been submitted. A pastor will be in touch soon.');
      } else {
        _showError(res['message'] as String? ?? 'An error occurred.');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showError(e.message ?? 'An error occurred. Please try again.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      debugPrint('[Counseling] Submit error: $e');
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MyColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
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
                  color: Color(0xFF065F46), size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Request Submitted',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: MyColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: MyColors.textSecondary, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              'You can track the status under "My Cases".',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: MyColors.textDisabled, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint,
      {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: MyColors.textDisabled, fontSize: 13),
      prefixIcon:
          icon != null ? Icon(icon, color: MyColors.primary, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: MyColors.primary, width: 1.5),
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
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Counseling',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
            Text(
              'This request is strictly confidential.',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
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
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryCard(),
            const SizedBox(height: 12),
            _buildFieldsCard(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category_rounded,
                  size: 16, color: MyColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MyColors.textPrimary,
                ),
              ),
              const Text(' *',
                  style: TextStyle(color: MyColors.danger, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kCategories.map((cat) {
              final selected = _selectedCategory == cat['value'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategory = cat['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? MyColors.primaryVeryLight
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? MyColors.primary : MyColors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        size: 15,
                        color: selected
                            ? MyColors.primary
                            : MyColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              selected ? MyColors.primary : MyColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleCtrl,
            maxLines: 2,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              "What's on your heart?",
              'Brief summary of your concern (optional)…',
              icon: Icons.edit_note_rounded,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteCtrl,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 6,
            decoration: _inputDecoration(
              'Additional details (optional)',
              'Share any background that would help the pastor…',
              icon: Icons.notes_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: MyColors.primaryLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _submitting ? null : _submit,
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(color: Colors.white),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded, size: 17),
                  SizedBox(width: 8),
                  Text(
                    'Submit Confidentially',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }
}
