import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'crawl_model.dart';

class StatisticsDialog extends StatelessWidget {
  final CrawlItem crawlItem;

  const StatisticsDialog({
    super.key,
    required this.crawlItem,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 820, // Adjusted from 850 to 820
          maxHeight: 700,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistics of pages processed this crawl',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  splashRadius: 20,
                  color: AppTheme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Translatable section
                        _buildSectionHeader(context, 'Translatable'),
                        _buildTableCard(context, [
                          _buildDataRow(['Match', 'Segments', 'Source words', 'Latin characters', 'Latin characters with spaces', 'Asian glyphs'], isHeader: true),
                          _buildDataRow(['101%', '0', '0', '0', '0', '0']),
                          _buildDataRow(['100%', '5', '7', '40', '42', '0']),
                          _buildDataRow(['99%', '8', '14', '98', '105', '0']),
                          _buildDataRow(['98%', '0', '0', '0', '0', '0']),
                          _buildDataRow(['Unique', '252', '2,894', '17,061', '19,724', '0'], isUniqueRow: true),
                          _buildDataRow(['Total translatable:', '265', '2,915', '17,199', '19,871', '0'], isTotal: true),
                        ]),
                        
                        const SizedBox(height: 20),
                        
                        // Repeated section
                        _buildSectionHeader(context, 'Repeated (free)'),
                        _buildTableCard(context, [
                          _buildDataRow(['Match', 'Segments', 'Source words', 'Latin characters', 'Latin characters with spaces', 'Asian glyphs'], isHeader: true),
                          _buildDataRow(['102%', '473', '3,272', '19,501', '22,361', '0']),
                        ]),
                      ],
                    ),
                    
                    // Copy button
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => _copyStatisticsToClipboard(context),
                        tooltip: 'Copy to clipboard',
                        splashRadius: 20,
                        color: AppTheme.colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    foregroundColor: AppTheme.colorScheme.onPrimary,
                    backgroundColor: AppTheme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: AppTheme.textTheme.labelLarge,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: AppTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper to build table card
  Widget _buildTableCard(BuildContext context, List<TableRow> rows) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: SelectionArea(
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: AppTheme.colorScheme.outlineVariant,
              width: 1.0,
            ),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FractionColumnWidth(0.20), // Match
            1: FractionColumnWidth(0.12), // Segments (slightly reduced)
            2: FractionColumnWidth(0.16), // Source words (slightly reduced)
            3: FractionColumnWidth(0.16), // Latin characters (slightly reduced)
            4: FractionColumnWidth(0.22), // Latin characters with spaces (increased)
            5: FractionColumnWidth(0.14), // Asian glyphs (increased)
          },
          children: rows,
        ),
      ),
    );
  }

  // Helper to build table rows
  TableRow _buildDataRow(List<String> cells, {bool isHeader = false, bool isTotal = false, bool isUniqueRow = false}) {
    return TableRow(
      decoration: isHeader 
          ? BoxDecoration(color: AppTheme.colorScheme.surfaceVariant.withOpacity(0.5))
          : null,
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String value = entry.value;
        
        // Determine if this cell should be bold
        bool makeTextBold = false;
        
        if (isHeader) {
          // Make the Source words column header bold
          makeTextBold = index == 2;
        } else {
          // Make entire row bold if it's the total row
          if (isTotal) {
            makeTextBold = true;
          } 
          // Make the Source words column (index 2) bold for all rows
          else if (index == 2) {
            makeTextBold = true;
          }
          // Make the "Unique" text bold
          else if (isUniqueRow && index == 0) {
            makeTextBold = true;
          }
        }
        
        // Adjust text style with slightly smaller font size
        final textStyle = AppTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: makeTextBold ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? AppTheme.colorScheme.onSurfaceVariant
              : AppTheme.colorScheme.onSurface,
          fontSize: 13.0, // Reduced from default (~14) to 13
        );
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced vertical padding from 12 to 10
          child: index == 0
              // First column is always left-aligned
              ? Text(
                  value, 
                  style: textStyle,
                  overflow: TextOverflow.visible,
                )
              // All other columns are right-aligned (including headers)
              : Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value, 
                    style: textStyle,
                    textAlign: TextAlign.right, // Explicitly set text alignment
                  ),
                ),
        );
      }).toList(),
    );
  }

  void _copyStatisticsToClipboard(BuildContext context) {
    // Define table headers
    final headers = [
      'Match', 'Segments', 'Source words', 'Latin characters',
      'Latin characters\\nwith spaces', 'Asian glyphs'
    ];

    // Define Translatable table data (matches the hardcoded data in build method)
    final translatableData = [
      ['101%', '0', '0', '0', '0', '0'],
      ['100%', '5', '7', '40', '42', '0'],
      ['99%', '8', '14', '98', '105', '0'],
      ['98%', '0', '0', '0', '0', '0'],
      ['Unique', '252', '2,894', '17,061', '19,724', '0'],
      ['Total translatable:', '265', '2,915', '17,199', '19,871', '0'],
    ];

    // Define Repeated table data (matches the hardcoded data in build method)
    final repeatedData = [
      ['102%', '473', '3,272', '19,501', '22,361', '0'],
    ];

    // Helper function to format a table into a string
    String formatTable(String title, List<String> headers, List<List<String>> data) {
      final buffer = StringBuffer();
      buffer.writeln(title);
      buffer.writeln('-' * title.length); // Underline title
      // Format headers (replace newline for clipboard)
      buffer.writeln(headers.map((h) => h.replaceAll('\\n', ' ')).join('\\t'));
      // Format data rows
      for (final row in data) {
        buffer.writeln(row.join('\\t'));
      }
      buffer.writeln(); // Add a blank line after the table
      return buffer.toString();
    }

    // Generate the full text for the clipboard
    final statsText = '''
Crawl Statistics: ${crawlItem.type}
Status: ${_getStatusText(crawlItem.status)}
Date: ${crawlItem.startDate}
Words: ${crawlItem.wordCount}
Pages: ${crawlItem.visitedPages}
Recurrence: ${crawlItem.recurrence}
${crawlItem.terminationReason != null ? 'Termination Reason: ${crawlItem.terminationReason}\\n' : ''}
${formatTable('Translatable', headers, translatableData)}
${formatTable('Repeated (free)', headers, repeatedData)}
''';

    Clipboard.setData(ClipboardData(text: statsText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Statistics copied to clipboard',
          style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.colorScheme.onPrimary),
        ),
        backgroundColor: AppTheme.colorScheme.primary,
      ),
    );
  }

  String _getStatusText(CrawlStatus status) {
    switch (status) {
      case CrawlStatus.completed:
        return 'Completed';
      case CrawlStatus.inProgress:
      case CrawlStatus.running:
        return 'Running';
      case CrawlStatus.queued:
        return 'Queued';
      case CrawlStatus.failed:
        return 'Failed';
      case CrawlStatus.canceled:
        return 'Canceled';
      case CrawlStatus.canceledSchedule:
        return 'Canceled schedule';
      default:
        return 'Unknown';
    }
  }
} 