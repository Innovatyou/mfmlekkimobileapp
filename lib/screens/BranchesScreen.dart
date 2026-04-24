import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Branches.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/Utility.dart';

import 'NoitemScreen.dart';

class BranchesScreen extends StatelessWidget {
  static const routeName = '/branches';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.branches,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF23141D),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: BranchesPageBody(),
      ),
    );
  }
}

class BranchesPageBody extends StatefulWidget {
  @override
  _BranchesPageBodyState createState() => _BranchesPageBodyState();
}

class _BranchesPageBodyState extends State<BranchesPageBody> {
  bool isLoading = true;
  bool isError = false;
  List<Branches>? items = [];

  Future<void> loadItems() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Utility.getDio().post(ApiUrl.FETCH_BRANCHES);

      if (response.statusCode == 200) {
        final dynamic res = jsonDecode(response.data);
        final List<Branches>? fetched = parseBranches(res);
        setState(() {
          isLoading = false;
          isError = false;
          items = fetched;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (exception) {
      print(exception);
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  static List<Branches>? parseBranches(dynamic res) {
    final parsed = res['branches'].cast<Map<String, dynamic>>();
    return parsed.map<Branches>((json) => Branches.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 20));
    }
    if (isError) {
      return NoitemScreen(
        title: t.oops,
        message: t.dataloaderror,
        onClick: loadItems,
      );
    }

    return ListView.builder(
      itemCount: items!.length,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemBuilder: (BuildContext context, int index) {
        return ItemTile(index: index, branches: items![index]);
      },
    );
  }
}

class ItemTile extends StatelessWidget {
  final Branches branches;
  final int index;

  const ItemTile({
    Key? key,
    required this.index,
    required this.branches,
  }) : super(key: key);

  Widget _metaRow(BuildContext context, IconData icon, String value) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5EAF1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF8F3E88), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyles.subhead(context).copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2F2029),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDE4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            branches.name ?? '',
            maxLines: 2,
            style: TextStyles.headline(context).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFF23141D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            branches.pastor ?? '',
            style: TextStyles.subhead(context).copyWith(
              color: const Color(0xFF7A6B75),
            ),
          ),
          const SizedBox(height: 14),
          _metaRow(context, Icons.phone_outlined, branches.phone ?? ''),
          const SizedBox(height: 10),
          _metaRow(context, Icons.email_outlined, branches.email ?? ''),
          const SizedBox(height: 10),
          _metaRow(context, Icons.location_on_outlined, branches.address ?? ''),
          if (branches.latitude != 0.0) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                final lat = branches.latitude!;
                final lng = branches.longitude!;
                Utility.openBrowserTab(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                  context: context,
                  title: 'Map',
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EAF0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: Color(0xFF8F3E88),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.viewinmap,
                      style: TextStyles.subhead(context).copyWith(
                        color: const Color(0xFF8F3E88),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
