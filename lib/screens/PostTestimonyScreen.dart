import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:provider/provider.dart';

class PostTestimonyScreen extends StatefulWidget {
  static const routeName = '/PostTestimonyScreen';

  @override
  PostTestimonyScreenScreenState createState() =>
      PostTestimonyScreenScreenState();
}

class PostTestimonyScreenScreenState extends State<PostTestimonyScreen> {
  Userdata? userdata;

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
      'testifier': _requester,
      'content': _content,
    });

    try {
      final response = await Utility.getDio().post(
        ApiUrl.SUBMIT_TESTIMONY,
        data: formData,
        onSendProgress: (int send, int total) {
          print((send / total) * 100);
        },
      );
      Navigator.of(context).pop();
      print(response.data);
      Alerts.show(context, t.success, t.successtestimonyposting);
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
      prefixIcon: Icon(icon, color: const Color(0xFF6A5E45)),
      filled: true,
      fillColor: const Color(0xFFF8F4EA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: const Color(0xFFE8DECB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF8F7442), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuest =
        Provider.of<AppStateManager>(context, listen: false).userdata == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F1E6),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.addtestimony,
          style: const TextStyle(
            color: Color(0xFF2B2316),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2B2316)),
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
                backgroundColor: const Color(0xFF7A6234),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: validateandsubmit,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8DECB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: requesterController,
                keyboardType: TextInputType.text,
                cursorColor: const Color(0xFF8F7442),
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
                cursorColor: const Color(0xFF8F7442),
                decoration: _fieldDecoration(
                  label: t.testimonytitle,
                  icon: Icons.title,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: contentController,
                keyboardType: TextInputType.multiline,
                cursorColor: const Color(0xFF8F7442),
                maxLines: 10,
                decoration: _fieldDecoration(
                  label: t.testimonycontent,
                  icon: Icons.auto_stories_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7A6234),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: validateandsubmit,
            icon: const Icon(Icons.done_all, size: 20),
            label: const Text(
              'Submit Testimony',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
