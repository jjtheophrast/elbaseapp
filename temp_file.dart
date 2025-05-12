import 'package:intl/intl.dart'; // Import for date formatting

class CrawlItem {
  final String type;
  final CrawlStatus status;
  final String startDate;
  final int wordCount;
  final int visitedPages;
  final int? pageLimit;
  final String recurrence;
  final String? terminationReason;
  final List<String>? warnings;
  final DateTime? nextScheduledRun;

  const CrawlItem({
    required this.type,
    required this.status,
    required this.startDate,
    required this.wordCount,
    required this.visitedPages,
    this.pageLimit,
    required this.recurrence,
    this.terminationReason,
    this.warnings,
    this.nextScheduledRun,
  });
}

enum CrawlStatus {
  completed,
  inProgress,
  queued,
  failed,
  canceled,
  running,
  canceledSchedule,
}

List<CrawlItem> getMockCrawlItems() {
  final dateFormat = DateFormat('yyyy-MM-dd'); // Use a consistent format for parsing
  
  return [
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.inProgress,
      startDate: '2025-04-18',
      wordCount: 30000,
      visitedPages: 247,
      pageLimit: 1000,
      recurrence: 'No',
    ),
    CrawlItem(
      type: 'Content extraction',
      status: CrawlStatus.completed,
      startDate: '2025-04-17',
      wordCount: 30000,
      visitedPages: 247,
      pageLimit: 247,
      recurrence: 'Weekly',
      terminationReason: 'All pages processed',
      warnings: [
        'HTTP 3XX status codes were encountered 4 times',
        '48 pages weren\'t processed. See request summary for details'
      ],
      nextScheduledRun: dateFormat.parse('2025-04-17').add(const Duration(days: 7)),
    ),
    const CrawlItem(
      type: 'New content detection',
      status: CrawlStatus.completed,
      startDate: '2025-04-16',
      wordCount: 60000,
      visitedPages: 446,
      pageLimit: 500,
      recurrence: 'No',
      terminationReason: 'All pages processed',
    ),
    const CrawlItem(
      type: 'TLS content extraction',
      status: CrawlStatus.failed,
      startDate: '2025-04-15',
      wordCount: 15000,
      visitedPages: 124,
      pageLimit: 1000,
      recurrence: 'No',
      terminationReason: 'Account balance depleted',
    ),
    CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.queued,
      startDate: '2025-04-20',
      wordCount: 0,
      visitedPages: 0,
      pageLimit: 1000,
      recurrence: 'Monthly',
      nextScheduledRun: dateFormat.parse('2025-04-20').add(const Duration(days: 30)),
    ),
    const CrawlItem(
      type: 'Content extraction',
      status: CrawlStatus.canceled,
      startDate: '2025-04-14',
      wordCount: 8500,
      visitedPages: 65,
      recurrence: 'No',
      terminationReason: 'Partial results only',
    ),
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.canceledSchedule,
      startDate: '2025-04-19',
      wordCount: 0,
      visitedPages: 0,
      pageLimit: 500,
      recurrence: 'Weekly',
      terminationReason: 'Partial results only',
    ),
  ];
} 