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
  final random = DateTime.now().microsecond; // For some minor variation in data
  final List<CrawlItem> items = [];
  
  // Create sample items in the specified order:
  // 1. One ongoing (inProgress)
  // 2. One queued
  // 3. Then the others
  items.addAll([
    // 1. One ongoing item at the top (inProgress)
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.inProgress,
      startDate: '2025-04-18T14:09:21',
      wordCount: 30000,
      visitedPages: 247,
      pageLimit: 1000,
      recurrence: 'No',
    ),
    
    // 2. One queued item
    const CrawlItem(
      type: 'New content detection',
      status: CrawlStatus.queued,
      startDate: '2025-04-16T16:30:00',
      wordCount: 0,
      visitedPages: 0,
      pageLimit: 750,
      recurrence: 'No',
    ),
    
    // 3. Then the others
    // Completed
    CrawlItem(
      type: 'Content extraction',
      status: CrawlStatus.completed,
      startDate: '2025-04-17T09:45:36',
      wordCount: 30000,
      visitedPages: 247,
      pageLimit: 247,
      recurrence: 'Weekly',
      terminationReason: 'No more pages left',
      warnings: [
        'HTTP 3XX status codes were encountered 4 times',
        '48 pages weren\'t processed. See request summary for details'
      ],
      nextScheduledRun: dateFormat.parse('2025-04-17').add(const Duration(days: 7)),
    ),
    
    // Failed
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.failed,
      startDate: '2025-04-14T09:15:44',
      wordCount: 8500,
      visitedPages: 73,
      pageLimit: 1000,
      recurrence: 'No',
      terminationReason: 'Account balance depleted',
    ),
    
    // Canceled
    const CrawlItem(
      type: 'TLS content extraction',
      status: CrawlStatus.canceled,
      startDate: '2025-04-15T10:30:17',
      wordCount: 15000,
      visitedPages: 127,
      pageLimit: 500,
      recurrence: 'No',
      terminationReason: 'Partial results only',
    ),
    
    // CanceledSchedule
    const CrawlItem(
      type: 'Content extraction',
      status: CrawlStatus.canceledSchedule,
      startDate: '2025-04-13T16:27:30',
      wordCount: 8500,
      visitedPages: 63,
      pageLimit: 500,
      recurrence: 'Weekly',
      terminationReason: 'Partial results only',
    ),
  ]);
  
  // Generate a series of items with different dates and properties
  final List<String> crawlTypes = [
    'Discovery crawl',
    'Content extraction',
    'New content detection',
    'TLS content extraction',
  ];
  
  // We've removed the running status from the initial items, 
  // as the user wants just a single ongoing item at the top
  final List<CrawlStatus> statuses = [
    CrawlStatus.completed, // More completed statuses for realism
    CrawlStatus.completed,
    CrawlStatus.completed, 
    CrawlStatus.completed,
    CrawlStatus.completed,
    CrawlStatus.completed,
    CrawlStatus.completed,
    CrawlStatus.failed,    // Keep some failed
    CrawlStatus.failed,
    CrawlStatus.canceled,  // Keep some canceled
    CrawlStatus.canceled,
  ];
  
  final List<String> recurrenceTypes = [
    'No',
    'Weekly',
    'Monthly',
    'Every 15 days',
  ];
  
  // Generate 50 additional items
  for (int i = 0; i < 50; i++) {
    final DateTime startDateObj = DateTime(2025, 4, 15).subtract(Duration(days: i));
    final String startDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(startDateObj);
    
    // Select attributes based on position in the list for some variety
    final String type = crawlTypes[i % crawlTypes.length];
    
    // New status distribution - we already have queued and inProgress in the top items
    CrawlStatus status;
    if (i % 10 < 7) {
      status = CrawlStatus.completed;  // 70% completed
    } else if (i % 10 == 8) {
      status = CrawlStatus.failed;     // 10% failed
    } else {
      status = CrawlStatus.canceled;   // 20% canceled
    }
                                           
    final String recurrence = recurrenceTypes[i % recurrenceTypes.length];
    
    // For completed items, add more data
    final bool isCompleted = status == CrawlStatus.completed;
    final int wordCount;
    final int visitedPages;
    
    // Set word count and visited pages
    if (isCompleted) {
      // Completed items have full data
      wordCount = 10000 + (i * 1000);
      visitedPages = 100 + (i * 10);
    } else if (status == CrawlStatus.failed || status == CrawlStatus.canceled) {
      // Failed or canceled items have partial data
      wordCount = 2000 + (i * 500);
      visitedPages = 20 + (i * 5);
    } else {
      // Queued items have zero data
      wordCount = 0;
      visitedPages = 0;
    }
    
    final int pageLimit = 500 + (i % 10) * 100;
    
    // For some items, add warnings or termination reasons
    List<String>? warnings;
    String? terminationReason;
    
    if (isCompleted && i % 5 == 0) {
      warnings = [
        'HTTP 3XX status codes were encountered ${(i % 10) + 1} times',
        '${(i % 20) + 10} pages weren\'t processed. See request summary for details'
      ];
    }
    
    // Set specific termination reasons as requested
    if (status == CrawlStatus.failed) {
      terminationReason = 'Account balance depleted';
    } else if (status == CrawlStatus.canceled || status == CrawlStatus.canceledSchedule) {
      terminationReason = 'Partial results only';
    } else if (isCompleted) {
      terminationReason = 'No more pages left';
    }
    
    // For recurring items, set next scheduled run
    DateTime? nextScheduledRun;
    if (recurrence != 'No') {
      final int daysToAdd = recurrence == 'Weekly' ? 7 : recurrence == 'Monthly' ? 30 : 15;
      nextScheduledRun = startDateObj.add(Duration(days: daysToAdd));
    }
    
    items.add(CrawlItem(
      type: type,
      status: status,
      startDate: startDate,
      wordCount: wordCount,
      visitedPages: visitedPages,
      pageLimit: pageLimit,
      recurrence: recurrence,
      terminationReason: terminationReason,
      warnings: warnings,
      nextScheduledRun: nextScheduledRun,
    ));
  }
  
  return items;
} 