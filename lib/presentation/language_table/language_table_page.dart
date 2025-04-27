import 'package:flutter/material.dart';
import 'package:elbaseapp/theme/app_theme.dart';

class LanguageTablePage extends StatefulWidget {
  const LanguageTablePage({super.key});

  @override
  State<LanguageTablePage> createState() => _LanguageTablePageState();
}

class _LanguageTablePageState extends State<LanguageTablePage> {
  late List<Language> _languages;
  late List<Language> _filteredLanguages;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _languages = languageData;
    _filteredLanguages = _languages;
  }

  void _filterLanguages(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredLanguages = _languages;
      } else {
        _filteredLanguages = _languages
            .where((language) =>
                language.code.toLowerCase().contains(query.toLowerCase()) ||
                language.name.toLowerCase().contains(query.toLowerCase()) ||
                language.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language Table',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: AppTheme.colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterLanguages,
              decoration: InputDecoration(
                labelText: 'Search languages',
                hintText: 'Search by code, name, or description',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppTheme.colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppTheme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                fillColor: AppTheme.colorScheme.surface,
                filled: true,
              ),
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: _filteredLanguages.isEmpty
                ? Center(
                    child: Text(
                      'No languages found matching "$_searchQuery"',
                      style: AppTheme.textTheme.headlineSmall,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          AppTheme.colorScheme.primaryContainer.withOpacity(0.2),
                        ),
                        dataRowColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return AppTheme.colorScheme.primaryContainer.withOpacity(0.1);
                            }
                            return Colors.transparent;
                          },
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Code',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Description',
                              style: AppTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: _filteredLanguages
                            .map(
                              (language) => DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      language.code,
                                      style: AppTheme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      language.name,
                                      style: AppTheme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      language.description,
                                      style: AppTheme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class Language {
  final String code;
  final String name;
  final String description;

  Language({
    required this.code,
    required this.name,
    required this.description,
  });
}

final List<Language> languageData = [
  Language(
    code: 'en',
    name: 'English',
    description: 'Germanic language widely used internationally',
  ),
  Language(
    code: 'es',
    name: 'Spanish',
    description: 'Romance language spoken in Spain and Latin America',
  ),
  Language(
    code: 'fr',
    name: 'French',
    description: 'Romance language spoken in France and other countries',
  ),
  Language(
    code: 'de',
    name: 'German',
    description: 'Germanic language spoken primarily in Germany',
  ),
  Language(
    code: 'it',
    name: 'Italian',
    description: 'Romance language spoken primarily in Italy',
  ),
  Language(
    code: 'pt',
    name: 'Portuguese',
    description: 'Romance language spoken in Portugal and Brazil',
  ),
  Language(
    code: 'ru',
    name: 'Russian',
    description: 'East Slavic language spoken primarily in Russia',
  ),
  Language(
    code: 'zh',
    name: 'Chinese',
    description: 'Group of languages spoken in China and other regions',
  ),
  Language(
    code: 'ja',
    name: 'Japanese',
    description: 'Language spoken primarily in Japan',
  ),
  Language(
    code: 'ko',
    name: 'Korean',
    description: 'Language spoken primarily in Korea',
  ),
  Language(
    code: 'ar',
    name: 'Arabic',
    description: 'Semitic language spoken in the Middle East and North Africa',
  ),
  Language(
    code: 'hi',
    name: 'Hindi',
    description: 'Indo-Aryan language spoken primarily in India',
  ),
  Language(
    code: 'nl',
    name: 'Dutch',
    description: 'Germanic language spoken in the Netherlands and Belgium',
  ),
  Language(
    code: 'sv',
    name: 'Swedish',
    description: 'Germanic language spoken primarily in Sweden',
  ),
  Language(
    code: 'no',
    name: 'Norwegian',
    description: 'Germanic language spoken primarily in Norway',
  ),
]; 