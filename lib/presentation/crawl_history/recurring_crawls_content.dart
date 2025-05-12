import 'package:flutter/material.dart';
import 'package:elbaseapp/el_paw/models/crawl_item.dart';
import 'package:intl/intl.dart';

class RecurringCrawlsContent extends StatelessWidget {
  final List<CrawlItem> recurringItems;
  final Function(BuildContext, CrawlItem) onCancelRecurrence;
  final Function(BuildContext, CrawlItem, {bool isRecurringView}) viewDetails;

  const RecurringCrawlsContent({
    Key? key,
    required this.recurringItems,
    required this.onCancelRecurrence,
    required this.viewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recurringItems.isEmpty) {
      return Center(
        child: Text('No recurring crawls found'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expanded area for the table
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildTable(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16.0,
        dataRowMinHeight: 64,
        dataRowMaxHeight: 64,
        headingRowHeight: 48,
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        columns: [
          DataColumn(label: Text('Type'), numeric: false),
          DataColumn(label: Text('Recurrence'), numeric: false),
          DataColumn(label: Text('Next run'), numeric: false),
          DataColumn(label: Text('Actions'), numeric: false),
        ],
        rows: recurringItems.map((item) => _buildRecurringDataRow(context, item)).toList(),
      ),
    );
  }

  // Helper to build DataRow for recurring items
  DataRow _buildRecurringDataRow(BuildContext context, CrawlItem item) {
    final nextRunFormatted = item.nextScheduledRun != null
        ? DateFormat('MMM d, yyyy').format(item.nextScheduledRun!) // Date only format
        : 'Not scheduled'; 

    // Determine display text for recurrence
    String recurrenceText;
    switch (item.recurrence.toLowerCase()) {
      case 'weekly':
        recurrenceText = 'Weekly';
        break;
      case 'monthly':
        recurrenceText = 'Monthly';
        break;
      default:
        recurrenceText = item.recurrence; // Fallback
    }

    return DataRow(
      cells: [
        DataCell(Text(item.type)),
        DataCell(Text(recurrenceText)),
        DataCell(Text(nextRunFormatted)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 20),
                tooltip: 'View details',
                onPressed: () => viewDetails(context, item, isRecurringView: true),
              ),
              IconButton(
                icon: Icon(Icons.cancel_outlined, size: 20),
                tooltip: 'Cancel recurrence',
                onPressed: () => onCancelRecurrence(context, item),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 