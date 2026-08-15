import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/MarketplaceItem.dart';
import 'package:higherground/providers/MarketplaceModel.dart';
import 'package:higherground/screens/MyMarketplaceListingsScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';

class MarketplaceSubmitScreen extends StatefulWidget {
  static const routeName = '/marketplace/submit';

  final MarketplaceItem? item;

  const MarketplaceSubmitScreen({Key? key, this.item}) : super(key: key);

  @override
  State<MarketplaceSubmitScreen> createState() =>
      _MarketplaceSubmitScreenState();
}

class _MarketplaceSubmitScreenState extends State<MarketplaceSubmitScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _sellerNameCtrl = TextEditingController();
  final _sellerEmailCtrl = TextEditingController();
  final _sellerPhoneCtrl = TextEditingController();

  // Form state
  int? _selectedCategoryId;
  String _condition = 'used';
  bool _isFree = false;
  List<String> _photoPaths = [];
  bool _uploading = false;
  String? _uploadStatus;

  bool get _isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _prefillFromItem(widget.item!);
    } else {
      _loadUserProfile();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceModel>(context, listen: false).fetchCategories();
    });
  }

  void _prefillFromItem(MarketplaceItem item) {
    _titleCtrl.text = item.title;
    _descCtrl.text = item.description ?? '';
    _priceCtrl.text = item.price > 0 ? item.price.toStringAsFixed(2) : '';
    _locationCtrl.text = item.location ?? '';
    _sellerNameCtrl.text = item.sellerName ?? '';
    _sellerEmailCtrl.text = item.sellerEmail ?? '';
    _sellerPhoneCtrl.text = item.sellerPhone ?? '';
    _selectedCategoryId = item.categoryId;
    _condition = item.itemCondition;
    _isFree = item.isFree;
  }

  Future<void> _loadUserProfile() async {
    final user = await SQLiteDbProvider.db.getUserData();
    if (user != null && mounted) {
      setState(() {
        _sellerNameCtrl.text =
            '${user.firstname ?? ''} ${user.lastname ?? ''}'.trim();
        _sellerEmailCtrl.text = user.email ?? '';
        _sellerPhoneCtrl.text = user.phonenumber ?? '';
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _sellerNameCtrl.dispose();
    _sellerEmailCtrl.dispose();
    _sellerPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_photoPaths.length >= 10) {
      _showToast('Maximum 10 photos allowed');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result == null) return;

    final imageMimes = {'jpg', 'jpeg', 'png', 'webp'};
    final valid = <String>[];
    final rejected = <String>[];

    for (final f in result.files) {
      final ext = (f.extension ?? '').toLowerCase();
      if (imageMimes.contains(ext) && f.path != null) {
        if (_photoPaths.length + valid.length < 10) {
          valid.add(f.path!);
        }
      } else {
        rejected.add(f.name);
      }
    }

    if (rejected.isNotEmpty) {
      _showToast('Only photos are allowed (jpg, png, webp)');
    }

    if (valid.isNotEmpty) {
      setState(() => _photoPaths.addAll(valid));
    }
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showToast('Please select a category');
      return;
    }

    final model = Provider.of<MarketplaceModel>(context, listen: false);

    final payload = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category_id': _selectedCategoryId.toString(),
      'item_condition': _condition,
      'price': _isFree ? '0' : _priceCtrl.text.trim(),
      'is_free': _isFree,
      'location': _locationCtrl.text.trim(),
      'seller_name': _sellerNameCtrl.text.trim(),
      'seller_email': _sellerEmailCtrl.text.trim(),
      'seller_phone': _sellerPhoneCtrl.text.trim(),
    };

    if (_isEditMode) {
      final ok = await model.updateListing(widget.item!.id, payload);
      if (!mounted) return;
      if (!ok) {
        _showToast(model.submitError ?? 'Update failed. Please try again.');
        return;
      }
      _showSuccessDialog(isEdit: true);
      return;
    }

    final itemId = await model.submitListing(payload);

    if (itemId == null) {
      _showToast(model.submitError ?? 'Submission failed. Please try again.');
      return;
    }

    // Upload photos
    if (_photoPaths.isNotEmpty) {
      setState(() {
        _uploading = true;
        _uploadStatus = 'Uploading photos…';
      });

      for (int i = 0; i < _photoPaths.length; i++) {
        setState(() =>
            _uploadStatus = 'Uploading photo ${i + 1} of ${_photoPaths.length}…');
        await model.uploadPhoto(itemId, _photoPaths[i]);
      }

      setState(() {
        _uploading = false;
        _uploadStatus = null;
      });
    }

    if (!mounted) return;
    _showSuccessDialog(isEdit: false);
  }

  void _showSuccessDialog({required bool isEdit}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 56),
            const SizedBox(height: 16),
            Text(isEdit ? 'Advert Updated!' : 'Advert Submitted!',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: MyColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              isEdit
                  ? 'Your changes have been saved. The admin will re-review your advert shortly.'
                  : 'Your advert has been submitted. The admin will review it shortly. You\'ll be notified once it\'s approved.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: MyColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: MyColors.primary,
                minimumSize: const Size(200, 44)),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close submit screen
              if (!isEdit) {
                Navigator.pushNamed(
                    context, MyMarketplaceListingsScreen.routeName);
              }
            },
            child: Text(isEdit ? 'Done' : 'View My Adverts'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: MyColors.textPrimary),
        title: Text(_isEditMode ? 'Edit Advert' : 'Post an Advert',
            style: const TextStyle(
                color: MyColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ),
      body: Consumer<MarketplaceModel>(builder: (ctx, model, _) {
        return Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  _section('Listing Details'),
                  _field(
                    label: 'Title *',
                    child: TextFormField(
                      controller: _titleCtrl,
                      maxLength: 200,
                      decoration: _inputDeco('e.g. iPhone 12, Sofa, Bible Study Book'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                    ),
                  ),
                  _field(
                    label: 'Category *',
                    child: DropdownButtonFormField<int>(
                      key: ValueKey(_selectedCategoryId),
                      initialValue: _selectedCategoryId,
                      decoration: _inputDeco('Select a category'),
                      isExpanded: true,
                      items: model.categories
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedCategoryId = v),
                      validator: (v) =>
                          v == null ? 'Please select a category' : null,
                    ),
                  ),
                  _field(
                    label: 'Condition *',
                    child: _conditionToggle(),
                  ),
                  _field(
                    label: 'Description',
                    child: TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: _inputDeco('Describe the item…'),
                    ),
                  ),
                  // Price / Free
                  _field(
                    label: 'Price',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _isFree,
                              activeColor: MyColors.primary,
                              onChanged: (v) =>
                                  setState(() => _isFree = v ?? false),
                            ),
                            const Text('This item is FREE',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: MyColors.textPrimary)),
                          ],
                        ),
                        if (!_isFree)
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'))
                            ],
                            decoration: _inputDeco('0.00').copyWith(
                              prefixText: '${model.currencySymbol} ',
                            ),
                            validator: (v) {
                              if (_isFree) return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter a price or mark as free';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                  _field(
                    label: 'Location / Pick-up Area',
                    child: TextFormField(
                      controller: _locationCtrl,
                      decoration:
                          _inputDeco('e.g. Lagos Island, Church premises'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _section('Seller Information'),
                  _field(
                    label: 'Seller Name *',
                    child: TextFormField(
                      controller: _sellerNameCtrl,
                      decoration: _inputDeco('Your name'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Seller name is required'
                              : null,
                    ),
                  ),
                  _field(
                    label: 'Email *',
                    child: TextFormField(
                      controller: _sellerEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDeco('seller@email.com'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                  ),
                  _field(
                    label: 'Phone (optional)',
                    child: TextFormField(
                      controller: _sellerPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDeco('+234 800 000 0000'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _section(_isEditMode ? 'Add More Photos' : 'Photos (up to 10)'),
                  if (_isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: const [
                        Icon(Icons.info_outline,
                            size: 14, color: MyColors.textSecondary),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Existing photos are kept. Add new ones below.',
                            style: TextStyle(
                                fontSize: 12,
                                color: MyColors.textSecondary),
                          ),
                        ),
                      ]),
                    ),
                  _buildPhotoGrid(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(model),
                ],
              ),
            ),
            if (_uploading || model.submitting)
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const CupertinoActivityIndicator(radius: 18),
                      const SizedBox(height: 14),
                      Text(
                        _uploading
                            ? (_uploadStatus ?? 'Uploading…')
                            : 'Submitting advert…',
                        style: const TextStyle(
                            fontSize: 14, color: MyColors.textPrimary),
                      ),
                    ]),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: MyColors.primary)),
      );

  Widget _field({required String label, required Widget child}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MyColors.textSecondary)),
            const SizedBox(height: 4),
            child,
          ],
        ),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: MyColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: MyColors.danger)),
      );

  Widget _conditionToggle() {
    return Row(
      children: ['new', 'used'].map((cond) {
        final selected = _condition == cond;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _condition = cond),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: cond == 'new' ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? MyColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: selected
                        ? MyColors.primary
                        : const Color(0xFFE2E8F0)),
              ),
              child: Text(
                cond == 'new' ? 'New' : 'Used',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? Colors.white : MyColors.textSecondary),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoGrid() {
    const slots = 10;
    final count = _photoPaths.length;
    final counterText = '$count / $slots';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(counterText,
                style: const TextStyle(
                    fontSize: 12, color: MyColors.textSecondary)),
            if (count < slots)
              TextButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined,
                    size: 16, color: MyColors.primary),
                label: const Text('Add Photos',
                    style:
                        TextStyle(fontSize: 12, color: MyColors.primary)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6),
          itemBuilder: (ctx, i) {
            if (i < count) {
              return Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_photoPaths[i]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (i == 0)
                  Positioned(
                    bottom: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                          color: MyColors.primary,
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('Cover',
                          style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _removePhoto(i),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.close_rounded,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ]);
            }
            // Empty slot
            return GestureDetector(
              onTap: _pickPhotos,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      style: BorderStyle.solid),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Color(0xFFCBD5E1), size: 22),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(MarketplaceModel model) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: MyColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: (model.submitting || _uploading) ? null : _submit,
        child: Text(_isEditMode ? 'Update Advert' : 'Submit for Review',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

