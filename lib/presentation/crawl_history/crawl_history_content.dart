import 'package:flutter/material.dart';
import 'package:elbaseapp/el_paw/models/crawl_item.dart';

class CrawlHistoryContent extends StatelessWidget {
  final List<CrawlItem> items;
  final int? sortColumn;
  final bool sortAscending;
  final Function(int, bool) onSort;
  final Function() onAddItem;
  final Function(BuildContext, CrawlItem, {bool isRecurringView}) viewDetails;
  final Function(BuildContext, CrawlItem) viewStatistics;
  final Function(BuildContext, CrawlItem) rerunCrawl;
  final Function(BuildContext, CrawlItem) cancelCrawl;
  final Widget Function(BuildContext, CrawlItem) buildPopupMenu;
  final Widget Function(CrawlItem) buildStatusIndicatorText;
  final Function(BuildContext, CrawlItem) showWarningsDialog;

  const CrawlHistoryContent({
    Key? key,
    required this.items,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
    required this.onAddItem,
    required this.viewDetails,
    required this.viewStatistics,
    required this.rerunCrawl,
    required this.cancelCrawl,
    required this.buildPopupMenu,
    required this.buildStatusIndicatorText,
    required this.showWarningsDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('No crawl history found'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button row at top
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => onAddItem(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Start new crawl'),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Table in a card - Expanded with scrolling
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
          DataColumn(
            label: Text('Started'),
            onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
            numeric: false,
          ),
          DataColumn(
            label: Text('Status'),
            onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
            numeric: false,
          ),
          DataColumn(
            label: Text('Visited pages'),
            onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
            numeric: true,
          ),
          DataColumn(
            label: Text('Word count'),
            onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
            numeric: true,
          ),
          DataColumn(
            label: Text('Type'),
            onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
            numeric: false,
          ),
          DataColumn(
            label: Text('Actions'),
            numeric: false,
          ),
        ],
        rows: items.map((item) => _buildDataRow(context, item)).toList(),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, CrawlItem item) {
    return DataRow(
      cells: [
        DataCell(Text(item.startTime)),
        DataCell(buildStatusIndicatorText(item)),
        DataCell(Text(item.visitedPages.toString())),
        DataCell(Text(item.wordCount.toString())),
        DataCell(Text(item.type)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 20),
                tooltip: 'View details',
                onPressed: () => viewDetails(context, item),
              ),
              IconButton(
                icon: Icon(Icons.bar_chart, size: 20),
                tooltip: 'View statistics',
                onPressed: () => viewStatistics(context, item),
              ),
              buildPopupMenu(context, item),
            ],
          ),
        ),
      ],
    );
  }
} 