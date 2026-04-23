import 'package:flutter/material.dart';

import 'package:higherground/models/language.dart';
import 'package:higherground/utils/components/language_list_element.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key, this.title, this.isAutomaticEnabled}) : super(key: key);

  final String? title;
  final bool? isAutomaticEnabled;

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final TextEditingController _searchTextController = TextEditingController();

  final List<Language> _languageList = [
    // minimal set for brevity; keep the full list as needed
    Language('auto', 'Automatic', false, false, false),
    Language('en', 'English', true, true, true),
    Language('fr', 'French', true, true, true),
    Language('es', 'Spanish', false, false, true),
    Language('de', 'German', false, false, true),
  ];

  final List<Language> recentLanguages = [];

  List<Language> get _searchedList {
    final query = _searchTextController.text.trim().toLowerCase();
    if (query.isEmpty) return _languageList;
    return _languageList
        .where((l) => (l.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isAutomaticEnabled == false) {
      _languageList.removeWhere((l) => l.code == 'auto');
    }
  }

  void _sendBackLanguage(Language? language) {
    if (language == null) return;
    Navigator.pop(context, language);
  }

  Widget _buildSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: TextField(
        controller: _searchTextController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, size: 24.0, color: Colors.grey),
          suffixIcon: _searchTextController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchTextController.clear();
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final list = _searchedList;
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) => LanguageListElement(
          language: list[i],
          onSelect: _sendBackLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Select language'),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          _buildSearch(),
          if (recentLanguages.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48.0,
                  color: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Recent Languages',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentLanguages.length,
                  itemBuilder: (context, i) => LanguageListElement(
                    language: recentLanguages[i],
                    onSelect: _sendBackLanguage,
                  ),
                ),
              ],
            ),
          Container(
            height: 48.0,
            color: Colors.blue[600],
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'All languages',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          _buildList(),
        ],
      ),
    );
  }
}


