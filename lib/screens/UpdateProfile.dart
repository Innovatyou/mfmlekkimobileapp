import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:higherground/screens/HomePage.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/models/Userdata.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

class UpdateProfile extends StatefulWidget {
  static const routeName = "/UpdateProfile";
  const UpdateProfile({Key? key, this.userdata}) : super(key: key);
  final Userdata? userdata;

  @override
  UpdateUserProfileState createState() => UpdateUserProfileState();
}

class UpdateUserProfileState extends State<UpdateProfile> {
  Userdata? userdata;
  String? gender = "Male";
  String? avatar = "";
  String? coverPhoto = "";

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController linkdlnController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1930, 8),
      lastDate: DateTime(2101),
      locale: const Locale('en', 'US'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: MyColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> pickImages(String type) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowCompression: true,
      allowMultiple: false,
      withData: false,
      allowedExtensions: ['png', 'PNG', 'JPEG', 'JPG', 'jpg', 'jpeg'],
    );
    if (!mounted) return;
    if (result != null) {
      final PlatformFile file = result.files.first;
      setState(() {
        if (type == "avatar") {
          avatar = file.path;
        } else {
          coverPhoto = file.path;
        }
      });
    }
  }

  Future<void> validateandsubmit() async {
    if (userdata!.photo == "" && avatar == "") {
      Alerts.show(context, t.error, t.pleaseselectprofilephoto);
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uploadFileFromDio(
      firstnameController.text,
      lastnameController.text,
      dobController.text,
      phoneController.text,
      addressController.text,
      occupationController.text,
      aboutController.text,
      facebookController.text,
      twitterController.text,
      linkdlnController.text,
      prefs.getString("firebase_token"),
    );
  }

  Future<List<int>?> _compressImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final resized = img.copyResize(decoded,
          width: decoded.width > 1024 ? 1024 : decoded.width);
      return img.encodeJpg(resized, quality: 75);
    } catch (_) {
      return null;
    }
  }

  Future<void> uploadFileFromDio(
    String firstname,
    String lastname,
    String dob,
    String phone,
    String address,
    String occupation,
    String aboutme,
    String facebook,
    String twitter,
    String linkedln,
    String? token,
  ) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    final Map<String, dynamic> fields = {
      "email": userdata!.email,
      "firstname": firstname,
      "lastname": lastname,
      "dob": dob,
      "phone": phone,
      "gender": gender,
      "address": address,
      "occupation": occupation,
      "aboutme": Utility.getBase64EncodedString(aboutme),
      "facebook": facebook,
      "twitter": twitter,
      "linkedln": linkedln,
    };
    if (avatar != null && avatar!.isNotEmpty) {
      final compressed = await _compressImage(avatar!);
      if (compressed != null) {
        fields["avatar_base64"] = base64Encode(compressed);
        fields["avatar_ext"] = "jpg";
      }
    }
    if (coverPhoto != null && coverPhoto!.isNotEmpty) {
      final compressed = await _compressImage(coverPhoto!);
      if (compressed != null) {
        fields["cover_photo_base64"] = base64Encode(compressed);
        fields["cover_photo_ext"] = "jpg";
      }
    }
    print(
        "[UpdateProfile] Sending fields: email=${fields['email']}, hasAvatar=${fields.containsKey('avatar_base64')}");
    try {
      final response = await Utility.getDio().post(
        ApiUrl.updateUserProfile,
        data: json.encode({"data": fields}),
      );
      print("[UpdateProfile] Response: ${response.data}");
      if (!mounted) return;
      Navigator.of(context).pop();
      final Map<String, dynamic> res = Utility.decodeResponse(response.data);
      if (res["status"] == "error") {
        Alerts.show(context, t.error, res["msg"]);
        return;
      }
      if (res["user"] == null) {
        Alerts.show(
            context,
            t.error,
            res["msg"]?.toString() ??
                "Profile update failed. Please try again.");
        return;
      }
      final Userdata updated = Userdata.fromJson(res["user"]);
      Provider.of<AppStateManager>(context, listen: false).setUserData(updated);
      if (Provider.of<AppStateManager>(context, listen: false).userdata ==
          null) {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      } else {
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      Alerts.show(context, t.error, e.message ?? t.error);
    }
  }

  @override
  void initState() {
    super.initState();
    userdata = widget.userdata;
    if ((userdata?.gender ?? '').isNotEmpty) gender = userdata!.gender;
    dobController.text = userdata?.dob ?? '';
    firstnameController.text = userdata?.firstname ?? '';
    lastnameController.text = userdata?.lastname ?? '';
    phoneController.text = userdata?.phonenumber ?? '';
    addressController.text = userdata?.address ?? '';
    occupationController.text = userdata?.occupation ?? '';
    aboutController.text = (userdata?.aboutme ?? '').isEmpty
        ? ''
        : Utility.getBase64DecodedString(userdata!.aboutme!);
    facebookController.text = userdata?.facebook ?? '';
    twitterController.text = userdata?.twitter ?? '';
    linkdlnController.text = userdata?.linkedln ?? '';
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    addressController.dispose();
    occupationController.dispose();
    aboutController.dispose();
    facebookController.dispose();
    twitterController.dispose();
    linkdlnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Personal ────────────────────────────────────────
                  _SectionLabel('PERSONAL INFORMATION'),
                  const SizedBox(height: 8),
                  _FormCard(children: [
                    _FormField(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF6366f1),
                      iconBg: const Color(0xFFe0e7ff),
                      label: t.firstname,
                      controller: firstnameController,
                      keyboardType: TextInputType.name,
                    ),
                    _FormField(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF8b5cf6),
                      iconBg: const Color(0xFFede9fe),
                      label: t.lastname,
                      controller: lastnameController,
                      keyboardType: TextInputType.name,
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 20),
                  _SectionLabel('GENDER'),
                  const SizedBox(height: 8),
                  _GenderSelector(
                    value: gender,
                    onChanged: (v) => setState(() => gender = v),
                  ),

                  const SizedBox(height: 20),
                  _SectionLabel('DATE OF BIRTH'),
                  const SizedBox(height: 8),
                  _FormCard(children: [
                    _FormField(
                      icon: FontAwesomeIcons.cakeCandles.data,
                      iconColor: const Color(0xFFec4899),
                      iconBg: const Color(0xFFfce7f3),
                      label: t.dob,
                      controller: dobController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      isLast: true,
                    ),
                  ]),

                  // ── Contact ─────────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionLabel('CONTACT'),
                  const SizedBox(height: 8),
                  _FormCard(children: [
                    _FormField(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFF10b981),
                      iconBg: const Color(0xFFd1fae5),
                      label: t.phonenumber,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _FormField(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFf59e0b),
                      iconBg: const Color(0xFFFEF3C7),
                      label: t.address,
                      controller: addressController,
                      keyboardType: TextInputType.streetAddress,
                      isLast: true,
                    ),
                  ]),

                  // ── Work & Bio ───────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionLabel('WORK & BIO'),
                  const SizedBox(height: 8),
                  _FormCard(children: [
                    _FormField(
                      icon: Icons.work_rounded,
                      iconColor: const Color(0xFF6366f1),
                      iconBg: const Color(0xFFe0e7ff),
                      label: t.occupation,
                      controller: occupationController,
                      keyboardType: TextInputType.text,
                    ),
                    _FormField(
                      icon: Icons.notes_rounded,
                      iconColor: const Color(0xFF64748b),
                      iconBg: const Color(0xFFf1f5f9),
                      label: t.aboutme,
                      controller: aboutController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      isLast: true,
                    ),
                  ]),

                  // ── Social ───────────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionLabel('SOCIAL'),
                  const SizedBox(height: 8),
                  _FormCard(children: [
                    _FormField(
                      icon: FontAwesomeIcons.facebook.data,
                      iconColor: const Color(0xFF1877F2),
                      iconBg: const Color(0xFFdbeafe),
                      label: t.facebookprofilelink,
                      controller: facebookController,
                      keyboardType: TextInputType.url,
                    ),
                    _FormField(
                      icon: FontAwesomeIcons.xTwitter.data,
                      iconColor: const Color(0xFF000000),
                      iconBg: const Color(0xFFf1f5f9),
                      label: t.twitterprofilelink,
                      controller: twitterController,
                      keyboardType: TextInputType.url,
                    ),
                    _FormField(
                      icon: FontAwesomeIcons.linkedin.data,
                      iconColor: const Color(0xFF0A66C2),
                      iconBg: const Color(0xFFdbeafe),
                      label: t.linkdln,
                      controller: linkdlnController,
                      keyboardType: TextInputType.url,
                      isLast: true,
                    ),
                  ]),

                  // ── Save button ──────────────────────────────────────
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: MyColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        t.save,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: validateandsubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      backgroundColor: MyColors.navBackground,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () {
          final appLogin = Provider.of<DashboardModel>(context, listen: false)
                  .data['app_login'] as bool? ??
              false;
          if (appLogin) {
            Navigator.of(context).pushReplacementNamed(HomePage.routeName);
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo
            _buildCoverPhoto(),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Cover photo edit button
            Positioned(
              right: 16,
              bottom: 16,
              child: _EditPhotoButton(
                onTap: () => pickImages("coverphoto"),
                tooltip: 'Change cover photo',
              ),
            ),
            // Avatar + title anchored at bottom-left
            Positioned(
              left: 20,
              right: 80,
              bottom: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildAvatarWithEdit(),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(color: Color(0x88000000), blurRadius: 8),
                            ],
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Update your photo and details',
                          style: TextStyle(
                            color: Color(0xBFFFFFFF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPhoto() {
    if (coverPhoto != null && coverPhoto!.isNotEmpty) {
      return Image.file(
        File.fromUri(Uri.parse(coverPhoto!)),
        fit: BoxFit.cover,
      );
    }
    if ((userdata?.coverphoto ?? '').isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: userdata!.coverphoto!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _coverFallback(),
        errorWidget: (_, __, ___) => _coverFallback(),
      );
    }
    return _coverFallback();
  }

  Widget _coverFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e0a3c), Color(0xFF4f46e5), Color(0xFF0d1117)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      );

  Widget _buildAvatarWithEdit() {
    final Widget photo = (avatar != null && avatar!.isNotEmpty)
        ? Image.file(File.fromUri(Uri.parse(avatar!)),
            fit: BoxFit.cover, width: 72, height: 72)
        : ((userdata?.photo ?? '').isNotEmpty
            ? CachedNetworkImage(
                imageUrl: userdata!.photo!,
                fit: BoxFit.cover,
                width: 72,
                height: 72,
                placeholder: (_, __) => _avatarFallback(),
                errorWidget: (_, __, ___) => _avatarFallback(),
              )
            : _avatarFallback());

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: photo,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _EditPhotoButton(
              onTap: () => pickImages("avatar"),
              tooltip: 'Change photo',
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFF4f46e5),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit photo button
// ─────────────────────────────────────────────────────────────────────────────

class _EditPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;
  final double size;

  const _EditPhotoButton({
    required this.onTap,
    required this.tooltip,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: MyColors.primary,
              borderRadius: BorderRadius.circular(size / 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: size * 0.50),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 0),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6366f1),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Form card (white rounded container)
// ─────────────────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFe2e8f0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual form field row
// ─────────────────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isLast;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const _FormField({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isLast = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  readOnly: readOnly,
                  onTap: onTap,
                  maxLines: maxLines,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0f172a),
                  ),
                  cursorColor: MyColors.primary,
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94a3b8),
                      fontWeight: FontWeight.w500,
                    ),
                    floatingLabelStyle: const TextStyle(
                      fontSize: 12,
                      color: MyColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 64,
            endIndent: 0,
            color: Color(0xFFf1f5f9),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender selector (toggle chip row)
// ─────────────────────────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GenderChip(
          label: 'Male',
          icon: Icons.male_rounded,
          selected: value == 'Male',
          onTap: () => onChanged('Male'),
        ),
        const SizedBox(width: 12),
        _GenderChip(
          label: 'Female',
          icon: Icons.female_rounded,
          selected: value == 'Female',
          onTap: () => onChanged('Female'),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: selected ? MyColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? MyColors.primary : const Color(0xFFe2e8f0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? MyColors.primary.withValues(alpha: 0.20)
                    : const Color(0x08000000),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : const Color(0xFF94a3b8),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF64748b),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
