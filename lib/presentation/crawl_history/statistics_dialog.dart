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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 550,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bar_chart, color: AppTheme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Crawl Statistics: ${crawlItem.type}',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () => _copyStatisticsToClipboard(context),
                    tooltip: 'Copy to clipboard',
                    splashRadius: 20,
                    color: AppTheme.colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            // Summary bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSummaryBar(context),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Translatable Section
                    _buildSectionHeader('Translatable Content', Icons.translate),
                    const SizedBox(height: 12),
                    _buildCompactStatsTable([
                      ['Match', 'Segments', 'Source words', 'Latin chars', 'Asian glyphs'],
                      ['101%', '0', '0', '0', '0'],
                      ['100%', '5', '7', '40', '0'],
                      ['99%', '8', '14', '98', '0'],
                      ['98%', '0', '0', '0', '0'],
                      ['Unique', '252', '2,894', '17,061', '0'],
                      ['Total:', '265', '2,915', '17,199', '0'],
                    ]),
                    
                    const SizedBox(height: 20),
                    _buildSectionHeader('Repeated Content (free)', Icons.repeat),
                    const SizedBox(height: 12),
                    _buildCompactStatsTable([
                      ['Match', 'Segments', 'Source words', 'Latin chars', 'Asian glyphs'],
                      ['102%', '473', '3,272', '19,501', '0'],
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Status',
                _getStatusText(crawlItem.status),
                _getStatusIcon(crawlItem.status),
                _getStatusColor(crawlItem.status),
              ),
              _buildSummaryItem(
                'Date',
                crawlItem.startDate,
                Icons.calendar_today,
                AppTheme.colorScheme.primary,
              ),
              _buildSummaryItem(
                'Words',
                crawlItem.wordCount.toString(),
                Icons.text_fields,
                AppTheme.colorScheme.primary,
              ),
              _buildSummaryItem(
                'Pages',
                crawlItem.visitedPages.toString(),
                Icons.file_copy_outlined,
                AppTheme.colorScheme.primary,
              ),
              _buildSummaryItem(
                'Recurrence',
                crawlItem.recurrence,
                Icons.repeat,
                AppTheme.colorScheme.primary,
              ),
            ],
          ),
          
          // Termination reason if available
          if (crawlItem.terminationReason != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildTerminationReasonRow(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStatsTable(List<List<String>> data) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: AppTheme.textTheme.bodyMedium,
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
            (states) => AppTheme.colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          dividerThickness: 1,
          horizontalMargin: 16,
          columnSpacing: 24,
          dataRowHeight: 40,
          columns: data[0].map((header) => 
            DataColumn(
              label: Text(header),
              numeric: header != 'Match',
            )
          ).toList(),
          rows: data.sublist(1).map((row) => 
            DataRow(
              cells: row.asMap().entries.map((entry) {
                int index = entry.key;
                String cell = entry.value;
                bool isTotal = row[0].contains('Total');
                
                return DataCell(
                  Text(
                    cell,
                    style: (isTotal || index == 0) 
                      ? AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                      : null,
                  ),
                );
              }).toList(),
              color: row[0].contains('Total') ? MaterialStateProperty.all(
                AppTheme.colorScheme.primaryContainer.withOpacity(0.2),
              ) : null,
            )
          ).toList(),
        ),
      ),
    );
  }

  void _copyStatisticsToClipboard(BuildContext context) {
    final statsText = _generateStatisticsText();
    Clipboard.setData(ClipboardData(text: statsText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistics copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _generateStatisticsText() {
    final buffer = StringBuffer();
    
    // Basic Info
    buffer.writeln('CRAWL STATISTICS - ${crawlItem.type.toUpperCase()}');
    buffer.writeln('----------------');
    buffer.writeln('Status: ${_getStatusText(crawlItem.status)}');
    if (crawlItem.terminationReason != null) {
      buffer.writeln('Termination reason: ${crawlItem.terminationReason}');
    }
    buffer.writeln('Start date: ${crawlItem.startDate}');
    buffer.writeln('Word count: ${crawlItem.wordCount}');
    buffer.writeln('Visited pages: ${crawlItem.visitedPages}');
    buffer.writeln('Recurrence: ${crawlItem.recurrence}');
    buffer.writeln();
    
    // Add translatable section
    buffer.writeln('TRANSLATABLE CONTENT');
    buffer.writeln('Match | Segments | Source words | Latin chars | Asian glyphs');
    buffer.writeln('101% | 0 | 0 | 0 | 0');
    buffer.writeln('100% | 5 | 7 | 40 | 0');
    buffer.writeln('99% | 8 | 14 | 98 | 0');
    buffer.writeln('98% | 0 | 0 | 0 | 0');
    buffer.writeln('Unique | 252 | 2,894 | 17,061 | 0');
    buffer.writeln('Total: | 265 | 2,915 | 17,199 | 0');
    buffer.writeln();
    
    // Add repeated section
    buffer.writeln('REPEATED CONTENT (FREE)');
    buffer.writeln('Match | Segments | Source words | Latin chars | Asian glyphs');
    buffer.writeln('102% | 473 | 3,272 | 19,501 | 0');
    
    return buffer.toString();
  }

  String _getStatusText(CrawlStatus status) {
    switch (status) {
      case CrawlStatus.completed:
        return 'Done';
      case CrawlStatus.inProgress:
        return 'In progress';
      case CrawlStatus.scheduled:
        return 'Scheduled';
      case CrawlStatus.failed:
        return 'Failed';
      case CrawlStatus.canceled:
        return 'Canceled';
      case CrawlStatus.running:
        return 'Running';
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
      case CrawlStatus.scheduled:
        return Icons.schedule;
      case CrawlStatus.failed:
        return Icons.error;
      case CrawlStatus.canceled:
        return Icons.cancel;
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
      case CrawlStatus.scheduled:
        return Colors.orange;
      case CrawlStatus.failed:
        return Colors.red;
      case CrawlStatus.canceled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTerminationReasonRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Termination reason:',
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          crawlItem.terminationReason!,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
} 