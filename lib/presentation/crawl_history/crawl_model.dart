class CrawlItem {
  final String type;
  final CrawlStatus status;
  final String startDate;
  final int wordCount;
  final int visitedPages;
  final String recurrence;
  final String? terminationReason;

  const CrawlItem({
    required this.type,
    required this.status,
    required this.startDate,
    required this.wordCount,
    required this.visitedPages,
    required this.recurrence,
    this.terminationReason,
  });
}

enum CrawlStatus {
  completed,
  inProgress,
  scheduled,
  failed,
  canceled,
  running,
  canceledSchedule,
}

List<CrawlItem> getMockCrawlItems() {
  return [
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.inProgress,
      startDate: '2023-04-18',
      wordCount: 30000,
      visitedPages: 247,
      recurrence: 'No',
    ),
    const CrawlItem(
      type: 'Content extraction',
      status: CrawlStatus.completed,
      startDate: '2023-04-17',
      wordCount: 30000,
      visitedPages: 247,
      recurrence: 'Weekly',
      terminationReason: 'No more pages left',
    ),
    const CrawlItem(
      type: 'New content detection',
      status: CrawlStatus.completed,
      startDate: '2023-04-16',
      wordCount: 60000,
      visitedPages: 446,
      recurrence: 'No',
      terminationReason: 'No more pages left',
    ),
    const CrawlItem(
      type: 'Target language specific (TLS) content extraction',
      status: CrawlStatus.failed,
      startDate: '2023-04-15',
      wordCount: 15000,
      visitedPages: 124,
      recurrence: 'No',
      terminationReason: 'Stopped, because your balance has been depleted',
    ),
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.scheduled,
      startDate: '2023-04-20',
      wordCount: 0,
      visitedPages: 0,
      recurrence: 'Monthly',
    ),
    const CrawlItem(
      type: 'Content extraction',
      status: CrawlStatus.canceled,
      startDate: '2023-04-14',
      wordCount: 8500,
      visitedPages: 65,
      recurrence: 'No',
      terminationReason: 'Cancelled - displayed statistics are partial results of the crawl',
    ),
    const CrawlItem(
      type: 'Discovery crawl',
      status: CrawlStatus.canceledSchedule,
      startDate: '2023-04-19',
      wordCount: 0,
      visitedPages: 0,
      recurrence: 'Weekly',
      terminationReason: 'Schedule canceled',
    ),
  ];
} 