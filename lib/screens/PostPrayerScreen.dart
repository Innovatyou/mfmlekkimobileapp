import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:provider/provider.dart';

class PostPrayerScreen extends StatefulWidget {
  static const routeName = '/PostPrayerScreen';

  @override
  PostPrayerScreenState createState() => PostPrayerScreenState();
}

class PostPrayerScreenState extends State<PostPrayerScreen> {
  Userdata? userdata;
  int? public = 1;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController requesterController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> validateandsubmit() async {
    final _title = titleController.text;
    final _requester = requesterController.text;
    final _content = contentController.text;

    if (_title.isEmpty || _requester.isEmpty || _content.isEmpty) {
      Alerts.show(context, t.error, t.updateprofileerrorhint);
      return;
    }

    Alerts.showProgressDialog(context, t.processingpleasewait);
    final formData = FormData.fromMap({
      'title': _title,
      'requester': _requester,
      'content': _content,
      'public': public,
      'email': userdata!.email,
    });

    try {
      final response = await Utility.getDio().post(
        ApiUrl.SUBMIT_PRAYER,
        data: formData,
        onSendProgress: (int send, int total) {
          print((send / total) * 100);
        },
      );
      Navigator.of(context).pop();
      print(response.data);
      Alerts.show(context, t.success, t.successprayerposting);
      setState(() {
        titleController.text = '';
        contentController.text = '';
      });
    } on DioException catch (e) {
      Navigator.of(context).pop();
      Alerts.show(context, t.error, e.message ?? t.error);
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
      } else {
        print(e.message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    userdata = Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata != null) {
      requesterController.text = '${userdata!.firstname!} ${userdata!.lastname!}';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    requesterController.dispose();
    contentController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF7A5D6E)),
      filled: true,
      fillColor: const Color(0xFFF8F2F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: const Color(0xFFE9DFE5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8A5A75), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest =
        Provider.of<AppStateManager>(context, listen: false).userdata == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F1F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.Prayerrequests,
          style: const TextStyle(
            color: Color(0xFF261621),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF261621)),
        leading: isGuest
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A3F60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: validateandsubmit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Submit'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9DFE5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: requesterController,
                    keyboardType: TextInputType.text,
                    cursorColor: const Color(0xFF8A5A75),
                    decoration: _fieldDecoration(
                      label: t.fullname,
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                    cursorColor: const Color(0xFF8A5A75),
                    decoration: _fieldDecoration(
                      label: t.prayertitle,
                      icon: Icons.title,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: contentController,
                    keyboardType: TextInputType.multiline,
                    cursorColor: const Color(0xFF8A5A75),
                    maxLines: 9,
                    decoration: _fieldDecoration(
                      label: t.prayercontent,
                      icon: Icons.edit_note_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9DFE5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prayer Visibility',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF261621),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8F2F6),
                      foregroundColor: const Color(0xFF5A2E46),
                      selectedBackgroundColor: const Color(0xFF7A3F60),
                      selectedForegroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE9DFE5)),
                    ),
                    segments: const [
                      ButtonSegment<int>(
                        value: 0,
                        label: Text('Public'),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        label: Text('Private'),
                      ),
                    ],
                    selected: {public ?? 1},
                    onSelectionChanged: (Set<int> value) {
                      setState(() {
                        public = value.first;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F2F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      public == 0
                          ? 'All members can see request'
                          : 'Only you & Pastor can see request',
                      style: const TextStyle(color: Color(0xFF5E5060)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7A3F60),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: validateandsubmit,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text(
                  'Submit Prayer Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
