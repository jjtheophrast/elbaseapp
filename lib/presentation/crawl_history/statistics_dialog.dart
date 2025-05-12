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
    // Revert to Dialog with custom layout matching the reference image style
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Match reference image corner radius
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 900, // Increased width further
        ),
        padding: const EdgeInsets.all(24.0), // Overall padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statistics of pages processed this crawl', // Title from original stats
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.colorScheme.onSurface, // Standard dark text color
                  ),
                ),
                Row( // Row for the icons
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      splashRadius: 20,
                      color: AppTheme.colorScheme.onSurfaceVariant, // Subtle color for close icon
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Wrap the central content (headers and table cards) in Flexible/ScrollView
            Flexible(
              child: SingleChildScrollView(
                child: Stack( // WRAPPED content column with Stack
                  children: [
                    Column( // This Column contains the headers and table cards
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Translatable Section Header (Now directly in dialog's Column)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Removed horizontal padding for header
                          child: Text(
                            'Translatable',
                            style: AppTheme.textTheme.bodyLarge?.copyWith( // Slightly larger than table body
                              color: AppTheme.colorScheme.onSurface, // Changed color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Card wrapping the Translatable DataTable
                        Card(
                          margin: EdgeInsets.zero, // Match main table card style
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Consistent rounding
                            side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 1), // Consistent border
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                               columnSpacing: 12.0,
                               headingRowHeight: 48,
                               dataRowMinHeight: 40.0,
                               dataRowMaxHeight: 40.0,
                               headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                 return AppTheme.colorScheme.surfaceVariant.withOpacity(0.5);
                               }),
                               headingTextStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                                 fontWeight: FontWeight.normal,
                                 color: AppTheme.colorScheme.onSurfaceVariant,
                               ),
                               dataTextStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                                 color: AppTheme.colorScheme.onSurface // Standard text color for data
                               ),
                               dividerThickness: 1.0,
                               showBottomBorder: true,
                               columns: const [
                                  DataColumn(label: Text('Match'), numeric: false),
                                  DataColumn(label: Text('Segments'), numeric: false),
                                  DataColumn(label: Text('Source words', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Latin characters'), numeric: false),
                                  DataColumn(label: Text('Latin characters\nwith spaces'), numeric: false), 
                                  DataColumn(label: Text('Asian glyphs'), numeric: false),
                               ],
                               rows: [
                                  _buildStatsDataRow(['101%', '0', '0', '0', '0', '0']),
                                  _buildStatsDataRow(['100%', '5', '7', '40', '42', '0']),
                                  _buildStatsDataRow(['99%', '8', '14', '98', '105', '0']),
                                  _buildStatsDataRow(['98%', '0', '0', '0', '0', '0']),
                                  _buildStatsDataRow(['Unique', '252', '2,894', '17,061', '19,724', '0']),
                                  _buildStatsDataRow(['Total translatable:', '265', '2,915', '17,199', '19,871', '0'], isTotal: true), 
                               ],
                             ),
                          ),
                        ),
                        const SizedBox(height: 20), // Spacer between sections
                        // Repeated Section Header (Now directly in dialog's Column)
                        Padding( 
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0), // Removed horizontal padding for header
                          child: Text(
                            'Repeated (free)',
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.colorScheme.onSurface, // Changed color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Card wrapping the Repeated DataTable
                        Card(
                          margin: EdgeInsets.zero, // Match main table card style
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Consistent rounding
                            side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 1), // Consistent border
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columnSpacing: 12.0,
                              headingRowHeight: 48,
                              dataRowMinHeight: 40.0,
                              dataRowMaxHeight: 40.0,
                              headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                return AppTheme.colorScheme.surfaceVariant.withOpacity(0.5);
                              }),
                              headingTextStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: AppTheme.colorScheme.onSurfaceVariant,
                              ),
                               dataTextStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                                 color: AppTheme.colorScheme.onSurface // Standard text color for data
                               ),
                              dividerThickness: 1.0,
                              showBottomBorder: true,
                              columns: const [
                                DataColumn(label: Text('Match'), numeric: false),
                                DataColumn(label: Text('Segments'), numeric: false),
                                DataColumn(label: Text('Source words', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Latin characters'), numeric: false),
                                DataColumn(label: Text('Latin characters\nwith spaces'), numeric: false),
                                DataColumn(label: Text('Asian glyphs'), numeric: false),
                              ],
                              rows: [
                                _buildStatsDataRow(['102%', '473', '3,272', '19,501', '22,361', '0']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Positioned Copy Button
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => _copyStatisticsToClipboard(context),
                        tooltip: 'Copy to clipboard',
                        splashRadius: 20,
                        color: AppTheme.colorScheme.primary,
                        visualDensity: VisualDensity.compact, // Reduce padding around icon
                        constraints: const BoxConstraints(), // Remove default constraints
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Custom Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                     foregroundColor: AppTheme.colorScheme.onPrimary,
                     backgroundColor: AppTheme.colorScheme.primary,
                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Adjust padding
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

  // Helper to build DataRow (apply semi-bold style where needed)
  DataRow _buildStatsDataRow(List<String> cells, {bool isTotal = false}) {
    return DataRow(
      cells: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String value = entry.value;
        // Apply semi-bold style for 'Source words' column (index 2) or the entire total row
        final bool isSemiBold = isTotal || index == 2;
        final textStyle = AppTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSemiBold ? FontWeight.bold : FontWeight.normal,
          // Ensure color is consistent with the table's dataTextStyle
          color: AppTheme.colorScheme.onSurface, 
        );

        return DataCell(Text(value, style: textStyle));
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
  
  IconData _getStatusIcon(CrawlStatus status) {
    switch (status) {
      case CrawlStatus.completed:
        return Icons.check_circle;
      case CrawlStatus.inProgress:
      case CrawlStatus.running:
        return Icons.sync;
      case CrawlStatus.queued:
        return Icons.schedule;
      case CrawlStatus.failed:
        return Icons.error;
      case CrawlStatus.canceled:
        return Icons.cancel;
      case CrawlStatus.canceledSchedule:
        return Icons.event_busy;
      default:
        return Icons.help_outline;
    }
  }
  
  Color _getStatusColor(CrawlStatus status) {
    switch (status) {
      case CrawlStatus.completed:
        return Colors.green;
      case CrawlStatus.inProgress:
      case CrawlStatus.running:
        return Colors.blue;
      case CrawlStatus.queued:
        return Colors.orange;
      case CrawlStatus.failed:
        return Colors.red;
      case CrawlStatus.canceled:
        return Colors.grey;
      case CrawlStatus.canceledSchedule:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTerminationReasonRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: AppTheme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Termination Reason: ${crawlItem.terminationReason}',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
} 