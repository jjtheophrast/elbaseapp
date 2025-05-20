import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod import
import '../../theme/app_theme.dart';
import '../../theme/button_styles.dart';
import '../widgets/right_panel/el_right_panel_destination.dart'; // Added import
import '../widgets/right_panel/el_right_panel_container.dart'; // Added import
import '../widgets/right_panel/el_right_panel_rail.dart'; // Added import
import 'crawl_model.dart';
import 'statistics_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Ensure intl is imported
import '../widgets/buttons/button_color_config.dart';
import '../widgets/buttons/el_button.dart';
import '../widgets/buttons/el_button_config.dart';
import 'package:material_symbols_icons/symbols.dart'; // Added Material Symbols icons
import 'package:flutter/services.dart';

// Define sortable columns globally
enum SortableColumn { started, status, type, wordCount, visitedPages }

// Convert to ConsumerStatefulWidget
class CrawlHistoryPage extends ConsumerStatefulWidget {
  const CrawlHistoryPage({super.key});

  @override
  ConsumerState<CrawlHistoryPage> createState() => _CrawlHistoryPageState();
}

// --- Define Enum and Provider for Right Panel ---
enum CrawlDetailsPanel {
  details,
  requestSummary,
  logs
}

final crawlDetailsPanelProvider = StateProvider<CrawlDetailsPanel?>((ref) => null);
// --- End Enum and Provider Definition ---

class _CrawlHistoryPageState extends ConsumerState<CrawlHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CrawlItem> _allCrawlItems = []; // Store fetched items
  List<CrawlItem> _displayedCrawlItems = []; // Items currently displayed
  CrawlItem? _selectedCrawlItem; // Added: To hold the item for the details panel
  
  // Pagination variables
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10; // Reduced for demo purposes
  bool _showLoadMore = false; // New state variable to track if we should show the Load More button

  // --- Right Panel Destinations (Fixed: Wrap Icons constants in Icon() widgets) ---
  final List<ELRightPanelDestination> _panelDestinations = const [
    ELRightPanelDestination(
      icon: Icon(Icons.info_outline_rounded),
      label: 'Settings Summary',
      tooltip: 'Crawl details',
    ),
    ELRightPanelDestination(
      icon: Icon(Icons.format_list_numbered_rtl_outlined),
      label: 'Requests',
      tooltip: 'Requests statistics',
    ),
    ELRightPanelDestination(
      icon: Icon(Icons.manage_search_outlined),
      label: 'Logs',
      tooltip: 'Crawl logs',
    ),
  ];
  // --- End Right Panel Destinations ---

  // Default selected crawl item for panels
  CrawlItem? _defaultCrawlItem;

  // Sorting state moved here
  SortableColumn? _sortColumn = SortableColumn.started;
  bool _sortAscending = false; // Default sort: newest first

  // Add a focus node for keyboard handling
  final FocusNode _escKeyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _allCrawlItems = getMockCrawlItems(); // Get mock data
    _loadInitialItems(); // Load initial page of items
    _sortData(); // Initial sort

    // Set a default item for fallback purposes only, but don't auto-select it
    if (_displayedCrawlItems.isNotEmpty) {
      _defaultCrawlItem = _displayedCrawlItems.first;
      // Remove auto-selection of first item 
      // _selectedCrawlItem = _displayedCrawlItems.first;
    }

    _tabController = TabController(
      length: 2, 
      vsync: this,
    );
    
    // Add listener to update when tab changes
    _tabController.addListener(() {
      // If the tab selection has changed, close any open panel
      if (_tabController.indexIsChanging || _tabController.animation!.value != _tabController.index.toDouble()) {
        // And if the panel is currently open
        if (ref.read(crawlDetailsPanelProvider) != null) {
          // Close the panel
          ref.read(crawlDetailsPanelProvider.notifier).state = null;
        }
        
        // Clear selection when switching tabs
        if (_selectedCrawlItem != null) {
          setState(() {
            _selectedCrawlItem = null;
          });
        }
      }
      
      // Force refresh when tab changes to update the panel options
      if (mounted) {
        setState(() {
          // Update default item based on the current tab without selecting it
          if (_tabController.index == 0) { // Crawl history tab
            // Find a good default item for history tab
            final historyItems = _displayedCrawlItems.where((item) => 
                item.status != CrawlStatus.canceledSchedule).toList();
            if (historyItems.isNotEmpty) {
              _defaultCrawlItem = historyItems.first;
              // Remove auto-selection of item when tab changes
              // if (_selectedCrawlItem == null) {
              //   _selectedCrawlItem = _defaultCrawlItem;
              // }
            }
          } else { // Recurring crawls tab
            // Find a good default item for recurring tab
            final recurringItems = _allCrawlItems.where((item) {
              final recurrenceLower = item.recurrence.toLowerCase();
              return (recurrenceLower == 'weekly' || recurrenceLower == 'monthly') 
                    && item.nextScheduledRun != null;
            }).toList();
            if (recurringItems.isNotEmpty) {
              _defaultCrawlItem = recurringItems.first;
              // Remove auto-selection of item when tab changes
              // if (_selectedCrawlItem == null) {
              //   _selectedCrawlItem = _defaultCrawlItem;
              // }
            }
          }
        });
      }
    });
  }
  
  // Load initial set of items
  void _loadInitialItems() {
    // Sort to prioritize showing items in the specified order:
    // 1. One ongoing (inProgress/running)
    // 2. One queued
    // 3. Then others (completed, failed, canceled, etc.)
    _allCrawlItems.sort((a, b) {
      // First sort by these priorities
      final aStatus = a.status;
      final bStatus = b.status;
      
      // Check for ongoing items (inProgress or running)
      final aIsOngoing = aStatus == CrawlStatus.inProgress || aStatus == CrawlStatus.running;
      final bIsOngoing = bStatus == CrawlStatus.inProgress || bStatus == CrawlStatus.running;
      
      // First priority: ongoing items
      if (aIsOngoing && !bIsOngoing) return -1;
      if (!aIsOngoing && bIsOngoing) return 1;
      
      // Second priority: queued items
      if (aStatus == CrawlStatus.queued && bStatus != CrawlStatus.queued) return -1;
      if (aStatus != CrawlStatus.queued && bStatus == CrawlStatus.queued) return 1;
      
      // For items of the same status, sort by date (newest first)
      return b.startDate.compareTo(a.startDate);
    });
    
    setState(() {
      _currentPage = 1;
      final displayItems = <CrawlItem>[];
      
      // Helper to check if an item is already in displayItems based on type and startDate
      bool isAlreadyAdded(CrawlItem itemToCheck) {
        return displayItems.any((di) => di.type == itemToCheck.type && di.startDate == itemToCheck.startDate);
      }

      // First: Add one ongoing item (inProgress or running)
      CrawlItem? ongoingItem;
      try {
        ongoingItem = _allCrawlItems.firstWhere(
          (item) => item.status == CrawlStatus.inProgress || item.status == CrawlStatus.running,
        );
      } catch (e) { /* Not found */ }
      if (ongoingItem != null && !isAlreadyAdded(ongoingItem)) {
        displayItems.add(ongoingItem);
      }
      
      // Second: Add one queued item
      CrawlItem? queuedItem;
      try {
        queuedItem = _allCrawlItems.firstWhere(
          (item) => item.status == CrawlStatus.queued && (ongoingItem == null || (item.type != ongoingItem.type || item.startDate != ongoingItem.startDate)),
        );
      } catch (e) { /* Not found */ }
      if (queuedItem != null && !isAlreadyAdded(queuedItem)) {
        displayItems.add(queuedItem);
      }
      
      // Third: Add other items to fill the first page
      // Make sure we have at least one of each remaining status
      final remainingStatuses = [
        CrawlStatus.completed,
        CrawlStatus.failed,
        CrawlStatus.canceled,
        CrawlStatus.canceledSchedule,
      ];
      
      for (final status in remainingStatuses) {
        if (displayItems.length >= _itemsPerPage) break; // Stop if page is full
        CrawlItem? statusItem;
        try {
          statusItem = _allCrawlItems.firstWhere(
            (item) => item.status == status && !isAlreadyAdded(item),
          );
        } catch (e) { /* Not found */ }
        
        if (statusItem != null && !isAlreadyAdded(statusItem)) { // Double check not added
          displayItems.add(statusItem);
        }
      }
      
      // Then fill remaining slots with next items
      if (displayItems.length < _itemsPerPage) {
        final remainingSlots = _itemsPerPage - displayItems.length;
        final remainingItems = _allCrawlItems
            .where((item) => !isAlreadyAdded(item))
            .take(remainingSlots)
            .toList();
        displayItems.addAll(remainingItems);
      }
      
      _displayedCrawlItems = displayItems;
      _hasMoreItems = _allCrawlItems.length > _displayedCrawlItems.length; // This might need a more robust check based on actual number of available items not yet displayed
    });
  }
  
  // Load more items when requested
  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMoreItems) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      final nextItems = _allCrawlItems
          .skip(_displayedCrawlItems.length)
          .take(_itemsPerPage)
          .toList();
          
      _displayedCrawlItems.addAll(nextItems);
      _currentPage++;
      _hasMoreItems = _displayedCrawlItems.length < _allCrawlItems.length;
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _escKeyFocusNode.dispose(); // Dispose the focus node
    super.dispose();
  }

  // Sorting logic moved here
  void _sortData([SortableColumn? column, bool? ascending]) {
    setState(() {
      _sortColumn = column ?? _sortColumn;
      _sortAscending = ascending ?? _sortAscending;
      
      // Ensure column/ascending have defaults if called initially
      final currentColumn = _sortColumn ?? SortableColumn.started;
      final currentAscending = _sortAscending;

      _allCrawlItems.sort((a, b) {
        // First, prioritize status ordering (ongoing → queued → done)
        // Define a helper function to get status priority (lower means higher priority)
        int getStatusPriority(CrawlStatus status) {
          if (status == CrawlStatus.running || status == CrawlStatus.inProgress) {
            return 0; // Highest priority - ongoing
          } else if (status == CrawlStatus.queued) {
            return 1; // Second priority - queued
          } else if (status == CrawlStatus.completed) {
            return 2; // Third priority - done
          } else {
            return 3; // Lowest priority - other statuses (failed, canceled, etc.)
          }
        }
        
        // Compare based on status priority
        final int statusPriorityA = getStatusPriority(a.status);
        final int statusPriorityB = getStatusPriority(b.status);
        
        // If status priorities are different, sort by status priority
        if (statusPriorityA != statusPriorityB) {
          return statusPriorityA - statusPriorityB;
        }
        
        // If status priorities are the same, sort by the selected column
        int compare = 0; // Initialize compare
        switch (currentColumn) {
          case SortableColumn.started:
            compare = a.startDate.compareTo(b.startDate);
            break;
          case SortableColumn.status:
            // For status column, we already sorted by priority above
            // This is just a secondary sort within the same status
            compare = a.status.index.compareTo(b.status.index);
            break;
          case SortableColumn.type:
            compare = a.type.compareTo(b.type);
            break;
          case SortableColumn.wordCount:
            compare = a.wordCount.compareTo(b.wordCount);
            break;
          case SortableColumn.visitedPages:
            compare = a.visitedPages.compareTo(b.visitedPages);
            break;
        }
        return currentAscending ? compare : -compare;
      });
      
      // Update displayed items based on the new sort
      _loadInitialItems();
    });
  }

  // Handler for DataColumn sorting callback
  void _handleSort(SortableColumn column, bool ascending) {
     _sortData(column, ascending);
  }

  // --- Helper method to build panel content builders ---
  // Ensure WidgetRef is a parameter, explicit return types
  Map<CrawlDetailsPanel, Widget Function()> _buildPanelBuilders(
    BuildContext context,
    WidgetRef ref,
    CrawlItem? item,
  ) {
    // Use the provided item if available, otherwise use the default item
    final crawlItem = item ?? _defaultCrawlItem;
    if (crawlItem == null) return {};
    
    final numberFormat = NumberFormat.decimalPattern();

    // Return the map of builders
    return {
      CrawlDetailsPanel.details: () {
        // Define panel widget
        final Widget panel = ELRightPanelContainer(
          panelProvider: crawlDetailsPanelProvider,
          title: 'Crawl details',
          onCancel: () => ref.read(crawlDetailsPanelProvider.notifier).state = null,
          children: [
            // Use a constrained box to ensure minimum width
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 400, // Set a minimum width for the panel content
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crawl type and date header with initiator info
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Crawl title and date on top
                        Text(
                          '${crawlItem.type} - ${DateFormat('MMM d, yyyy').format(DateTime.parse(crawlItem.startDate))}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        // Spacing between title and profile info
                        const SizedBox(height: 16),
                        
                        // Container for profile info with alignment to the right
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Account information column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Dilyara Seitova',
                                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'dseitova@skawa.hu',
                                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    'key: 1115600133249752868870',
                                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.colorScheme.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Account icon
                              Icon(
                                Icons.account_circle_outlined,
                                size: 40,
                                color: AppTheme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Notes section
                  _buildSectionCard(
                    context,
                    'Notes',
                    [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'first crawl',
                          style: AppTheme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  
                  // Divider between sections
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            
            // Crawl type section
            _buildSectionCard(
              context,
              'Crawl type',
              [
                      _buildCompactSettingWithCheckmark('Discovery crawl'),
                      _buildCompactSettingWithCheckmark('Prerender pages: Yes'),
              ],
            ),
                  
                  // Divider between sections
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            
            // Scope Section
            _buildSectionCard(
              context,
              'Scope',
              [
                      _buildCompactSettingWithCheckmark('Crawl entire website'),
                      _buildCompactSettingWithCheckmark('Page limit: 100'),
                    ],
                  ),
                  
                  // Divider between sections
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                  
                  // Restrictions Section - Main heading
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 4.0, top: 16.0),
                    child: Text(
              'Restrictions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600, 
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  
                  // Existing project restrictions container
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Text(
                            'Existing project restrictions',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crawl pages starting with:',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                _buildPathItem('/blog*'),
                _buildPathItem('/news*'),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              Text(
                                'Don\'t crawl pages starting with:',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                _buildPathItem('/de_de*', isAllowed: false, isLocked: true),
                _buildPathItem('/about*', isAllowed: false),
                _buildPathItem('/contact*', isAllowed: false),
              ],
                              ),
                              const SizedBox(height: 16), // Add bottom padding
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Temporary restrictions container
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Text(
              'Temporary restrictions for this crawl',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crawl pages starting with:',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                _buildPathItem('/product*'),
                _buildPathItem('/category*'),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              Text(
                                'Don\'t crawl pages starting with:',
                                style: AppTheme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: [
                _buildPathItem('/admin*', isAllowed: false),
                _buildPathItem('/login*', isAllowed: false),
              ],
                              ),
                              const SizedBox(height: 16), // Add bottom padding
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider between sections
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            
            // Snapshot Section
            _buildSectionCard(
              context,
              'Snapshot',
              [
                _buildSettingWithCheckmark('Reuse existing pages and don\'t store new pages'),
              ],
            ),
                  
                  // Divider between sections
                  Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            
            // Fine-tune Section
            _buildSectionCard(
              context,
              'Fine-tune',
              [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resources to collect:',
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCheckmarkItem('HTML pages'),
                            
                            const SizedBox(height: 16),
                            Text(
                              'Collection of non-standard pages:',
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCheckmarkItem('Error pages'),
                            
                            const SizedBox(height: 16),
                            Text(
                              'Tweaks:',
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCheckmarkItem('Skip content-type check'),
                            _buildCheckmarkItem('Do not reload existing resources'),
                            
                            const SizedBox(height: 16),
                            Text(
                              'Simultaneous requests: 8',
                              style: AppTheme.textTheme.bodyMedium,
                            ),
                          ],
                  ),
                ),
              ],
            ),
                  
                  // Divider between sections (REMOVED for Recurrence)
                  // Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            
            // Recurrence Section (REMOVED)
            // _buildSectionCard(
            //   context,
            //   'Recurrence',
            //   [
            //           _buildSettingWithCheckmark('Every 15 days'),
            //           _buildSettingWithCheckmark('Next run date: May 7, 2025'),
            //   ],
            //       ),
                ],
              ),
            ),
          ],
        );
        return panel; // Return as Widget
      },
      CrawlDetailsPanel.requestSummary: () {
        // Define panel widget
        final Widget panel = ELRightPanelContainer(
          panelProvider: crawlDetailsPanelProvider,
          title: 'Requests',
          onCancel: () => ref.read(crawlDetailsPanelProvider.notifier).state = null,
          children: [
            // Crawl type and date header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${crawlItem.type} - ${DateFormat('MMM d, yyyy').format(DateTime.parse(crawlItem.startDate))}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Visited response codes section
            _buildSummarySection(
              context, 
              'Visited response codes',
              [
                _buildKeyValueRow(context, 'HTTP 200', '10'),
                _buildKeyValueRow(context, 'HTTP 301', '4'),
              ],
            ),
            
            const Divider(height: 32),
            
            // Page views section
            _buildSummarySection(
              context, 
              'Page views',
              [
                _buildKeyValueRow(context, 'HTML pages', '10'),
                _buildKeyValueRow(
                  context, 
                  'Images', 
                  '0',
                  tooltip: 'Scanning images won\'t count as a Page view,\n'
                    'only content-type will be checked.\n'
                    'When building a Source cache, images are\n'
                    'downloaded and counted as page views.',
                ),
                _buildKeyValueRow(context, 'Resources (images are not included)', '4'),
                _buildKeyValueRow(context, 'Without content type', '0'),
                _buildKeyValueRow(context, 'Total (billed requests)', '14', isBold: true),
                _buildKeyValueRow(context, 'Prerendered pages', '0', indent: 1),
                _buildKeyValueRow(context, 'Non-prerendered pages', '14', indent: 1),
              ],
            ),
            
            const Divider(height: 32),
            
            // Pages not processed section
            _buildSummarySection(
              context, 
              'Pages not processed',
              [
                _buildKeyValueRow(context, 'Redirection received, but redirections are not processed', '4'),
                _buildKeyValueRow(context, 'URL points to a resource, but resource collection is disabled', '44'),
                _buildKeyValueRow(context, 'Total', '48', isBold: true),
              ],
            ),
            
            const Divider(height: 32),
            
            // Other statistics section
            _buildSummarySection(
              context, 
              'Other statistics',
              [
                _buildKeyValueRow(context, 'Words added', '0'),
                _buildKeyValueRow(context, 'Pages skipped for any reason (not billed)', '0'),
                _buildKeyValueRow(context, 'Pages which translated', '10', isAdminOnly: true),
                _buildKeyValueRow(context, 'Pages with added source entries', '10', isAdminOnly: true),
                _buildKeyValueRow(context, 'Requests sent by reduce worker', '57', isAdminOnly: true),
                _buildKeyValueRow(context, 'Preflight requests', '0', isAdminOnly: true),
                _buildKeyValueRow(context, 'Non-billable requests', '57'),
                _buildKeyValueRow(context, 'Total request count (not all billable)', '71', isBold: true),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Add "View logs for more details" link button
            Center(
              child: InkWell(
                onTap: () {
                  // Navigate to the logs panel
                  ref.read(crawlDetailsPanelProvider.notifier).state = CrawlDetailsPanel.logs;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See logs for more details',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.navigate_next,
                        size: 16,
                        color: AppTheme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        );
        return panel; // Return as Widget
      },
      CrawlDetailsPanel.logs: () {
        // Define panel widget
        final Widget panel = ELRightPanelContainer(
          panelProvider: crawlDetailsPanelProvider,
          title: 'Logs',
          onCancel: () => ref.read(crawlDetailsPanelProvider.notifier).state = null,
          children: [
            // Crawl type and date header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${crawlItem.type} - ${DateFormat('MMM d, yyyy').format(DateTime.parse(crawlItem.startDate))}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Just two log files - one with parameters, one without
            _buildLogFileCard(
              context,
              fileName: '0be45hl6_0Tie9x_1745582270415_88960-00000.log',
              hasParameters: true,
              onFilter: () => _showLogFilterDialog(context),
            ),
            
            _buildLogFileCard(
              context,
              fileName: '0be45hl6_0Tie9x_1745582270415_88960-00001.log',
              hasParameters: false,
              onFilter: () => _showLogFilterDialog(context),
            ),
          ],
        );
        return panel; // Return as Widget
      },
    };
  }
  // --- End helper method ---
  
  // Method to build a section card with dividers between sections, not after headers
  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 4.0, top: 16.0),
            child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, 
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
          ),
          // Content
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
          ),
        ],
      ),
    );
  }
  
  // Method for building setting rows without checkmarks by default
  Widget _buildSettingWithCheckmark(String text, {bool hasCheckmark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasCheckmark)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.check,
                size: 20,
                color: AppTheme.colorScheme.primary,
              ),
            ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Create a compact version of the setting item
  Widget _buildCompactSettingWithCheckmark(String text, {bool hasCheckmark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasCheckmark)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.check,
                size: 20,
                color: AppTheme.colorScheme.primary,
              ),
            ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Update method for showing paths as chips with primary colors, all with checkmarks
  Widget _buildPathItem(String path, {bool isAllowed = true, bool isLocked = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
        color: AppTheme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked)
            Icon(
                Icons.lock_outline,
                size: 16,
              color: AppTheme.colorScheme.primary,
            )
          else
            Icon(
                Icons.check,
                size: 16,
              color: AppTheme.colorScheme.primary,
              ),
          const SizedBox(width: 8),
          Text(
            path,
            style: AppTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // New helper method for section headers within cards
  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        text,
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // New helper method for URL list items
  Widget _buildUrlItem(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        url,
        style: AppTheme.textTheme.bodyMedium,
      ),
    );
  }

  // Helper for building stat items in the request summary panel
  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Helper for building HTTP stat items
  Widget _buildHttpStatItem(BuildContext context, String code, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            code,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Helper for building log entries
  Widget _buildLogEntry(BuildContext context, String level, String timestamp, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              level,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timestamp,
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  message,
                  style: AppTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) { 
    final sortedItems = List<CrawlItem>.from(_allCrawlItems);
    final selectedPanel = ref.watch(crawlDetailsPanelProvider);
    
    // If there's a selected crawl item, use it; do NOT fall back to default item
    final itemForPanel = _selectedCrawlItem;
    final panelBuilders = _buildPanelBuilders(context, ref, itemForPanel);
    
    // Calculate available width based on panel status
    final isPanelOpen = selectedPanel != null;
    
    // Check if we're in the recurring tab
    final bool isRecurringTab = _tabController.index == 1;
    
    // Check if no item is selected
    final bool noItemSelected = _selectedCrawlItem == null;
    
    // Define consistent tooltips for recurring tab and history tabs
    final String recurringRequestsTooltip = 'Requests statistics are only available after a crawl has run';
    final String recurringLogsTooltip = 'Logs are only available after a crawl has run';
    final String settingsTooltip = 'Select a crawl from the table to see crawl details';
    final String requestsTooltip = 'Select a crawl from the table to see request statistics';
    final String logsTooltip = 'Select a crawl from the table to see logs';
    
    // Create panel destinations with appropriate disabled states and improved tooltips
    final List<ELRightPanelDestination> activePanelDestinations = [
      ELRightPanelDestination(
        icon: _panelDestinations[0].icon,
        label: _panelDestinations[0].label,
        tooltip: isRecurringTab && noItemSelected
            ? settingsTooltip
            : (noItemSelected && !isRecurringTab
                ? settingsTooltip 
                : _panelDestinations[0].tooltip),
        disabled: noItemSelected, // Disable when no item is selected
      ),
      ELRightPanelDestination(
        icon: _panelDestinations[1].icon,
        label: _panelDestinations[1].label,
        tooltip: isRecurringTab
            ? recurringRequestsTooltip
            : (noItemSelected 
                ? requestsTooltip 
                : (itemForPanel?.status == CrawlStatus.queued
                    ? 'Requests data not yet available for queued crawls'
                    : _panelDestinations[1].tooltip)),
        disabled: noItemSelected || isRecurringTab || (itemForPanel?.status == CrawlStatus.queued),
      ),
      ELRightPanelDestination(
        icon: _panelDestinations[2].icon,
        label: _panelDestinations[2].label,
        tooltip: isRecurringTab
            ? recurringLogsTooltip
            : (noItemSelected 
                ? logsTooltip 
                : (itemForPanel?.status == CrawlStatus.queued
                    ? 'Log data not yet available for queued crawls'
                    : _panelDestinations[2].tooltip)),
        disabled: noItemSelected || isRecurringTab || (itemForPanel?.status == CrawlStatus.queued),
      ),
    ];
    
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _handleEscKeyPress,
      },
      child: Focus(
        focusNode: _escKeyFocusNode,
        autofocus: true,
        child: GestureDetector(
          // Close panel when tapping outside of it (on the main content area)
          onTap: isPanelOpen 
              ? () => ref.read(crawlDetailsPanelProvider.notifier).state = null
              : null,
          child: Scaffold(
            body: GestureDetector(
              // Stop event propagation to prevent closing when tapping inside the scaffold
              onTap: () {},
              child: Column(
                children: [
                  // Top app bar - blue (full width)
                  Container(
                    height: 60,
                    color: AppTheme.colorScheme.primary,
                    child: Row(
                      children: [
                        // Left sidebar icon
                        Container(
                          width: 317,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.menu, color: AppTheme.colorScheme.onPrimary),
                        ),
                        // Right area with domain, notifications, etc.
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'csega.hu',
                                        style: TextStyle(color: AppTheme.colorScheme.primary),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_drop_down, color: AppTheme.colorScheme.primary),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.notifications_outlined, color: AppTheme.colorScheme.onPrimary),
                                const SizedBox(width: 16),
                                Icon(Icons.help_outline, color: AppTheme.colorScheme.onPrimary),
                                const SizedBox(width: 16),
                                // Simple avatar matching the reference image
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: const Color(0xFFE3EDFB),
                                  child: Icon(
                                    Icons.account_circle_outlined,
                                    color: AppTheme.colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main content and side panels below the top app bar
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left sidebar with blue background
                        SizedBox(
                          width: 317,
                          child: GestureDetector(
                            // Stop propagation for left sidebar to prevent panel closing
                            onTap: () {},
                            child: Container(
                              color: const Color(0xFFF2F5FC), // Light blue background
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  _buildSetupMenuItem(context),
                                  _buildMenuItem(
                                    context,
                                    'Site content',
                                    Icons.article_outlined,
                                    false,
                                    hasSubmenu: true,
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'Team',
                                    Icons.people_outlined,
                                    false,
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'Manage translations',
                                    Icons.edit_note_outlined,
                                    false,
                                  ),
                                  _buildSubMenuItem(context, 'Crawls', isSelected: true),
                                  _buildMenuItem(
                                    context,
                                    'Subscription',
                                    Icons.credit_card_outlined,
                                    false,
                                  ),
                                  _buildMenuItem(
                                    context,
                                    'Settings',
                                    Icons.settings_outlined,
                                    false,
                                    hasSubmenu: true,
                                  ),
                                  _buildBottomSection(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Main content area with fixed width based on panel state
                        Expanded(
                          child: GestureDetector(
                            // Stop propagation for main content to prevent panel closing when interacting with it
                            onTap: () {},
                            child: DefaultTabController(
                              length: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Page title header
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Crawls',
                                      style: AppTheme.textTheme.titleLarge?.copyWith(
                                        color: AppTheme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  
                                  // Thin divider
                                  Container(
                                    margin: const EdgeInsets.only(top: 0.5),
                                    height: 0.5,
                                    color: AppTheme.colorScheme.outlineVariant,
                                  ),
                                  
                                  // Add space above the tabs (24px)
                                  const SizedBox(height: 24),
                                  
                                  // Tabs row with button - place them in the same row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom of the row
                                    children: [
                                      // TabBar - make it take available space but leave room for button
                                      Expanded(
                                        child: TabBar(
                                          controller: _tabController,
                                          tabs: const [
                                            Tab(text: 'Crawl history'),
                                            Tab(text: 'Recurring crawls'),
                                          ],
                                          labelColor: AppTheme.colorScheme.primary,
                                          unselectedLabelColor: AppTheme.colorScheme.onSurfaceVariant,
                                          indicatorColor: AppTheme.colorScheme.primary,
                                          indicatorSize: TabBarIndicatorSize.tab, // Changed from label to tab to extend indicator
                                          dividerColor: Colors.transparent, // Hide default divider since we're using a custom one
                                          labelStyle: AppTheme.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          unselectedLabelStyle: AppTheme.textTheme.labelLarge,
                                          // Add these properties to make tabs more compact
                                          isScrollable: true,
                                          tabAlignment: TabAlignment.start,
                                          padding: const EdgeInsets.only(left: 24), // Add left padding to align with container
                                          labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                                        ),
                                      ),
                                      
                                      // Start new crawl button - right aligned
                                      Padding(
                                        padding: const EdgeInsets.only(right: 24, bottom: 4),
                                        child: ELButton(
                                          config: ELButtonConfig(
                                            title: 'Start new crawl',
                                            colorConfig: ButtonColorConfig(ButtonColorType.filledPrimary, context),
                                            icon: Icons.add,
                                          ),
                                          onPressed: () {
                                            // Handle start new crawl action
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Full-width divider for the tabs - this is a separate widget below the tabs
                                  Container(
                                    height: 1,
                                    color: AppTheme.colorScheme.outlineVariant,
                                  ),

                                  // TabBarView - Expanded to fill remaining space with properly nested scrolling
                                  Expanded(
                                    child: TabBarView(
                                      controller: _tabController,
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: [
                                        // Pass isPanelOpen state to the tab builders
                                        _buildCrawlHistoryTab(sortedItems, isPanelOpen),
                                        _buildRecurringCrawlsTab(isPanelOpen),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Right rail with integrated panel - wrapped in GestureDetector to stop propagation
                        GestureDetector(
                          // Stop propagation for right rail and panel to prevent closing when interacting with them
                          onTap: () {},
                          child: ELRightPanelRail<CrawlDetailsPanel>(
                            panelProvider: crawlDetailsPanelProvider,
                            availableOptions: CrawlDetailsPanel.values,
                            destinations: activePanelDestinations,
                            panelBuilders: panelBuilders,
                            onDestinationSelected: (index) {
                              // Only allow selecting enabled destinations
                              if (!activePanelDestinations[index].disabled) {
                                _handlePanelIconClick(CrawlDetailsPanel.values[index]);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bottom toolbar placeholder - 30px tall
                  Container(
                    height: 30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupMenuItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_box_outlined, size: 24, color: AppTheme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Setup',
                style: AppTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 36),
            child: Row(
              children: [
                Text(
                  '3 / 8 completed',
                  style: AppTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 36),
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: 3 / 8,
                backgroundColor: AppTheme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected, {
    bool hasSubmenu = false,
  }) {
    return Container(
      color: isSelected ? AppTheme.colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Icon(
          icon,
          size: 24,
          color: isSelected ? AppTheme.colorScheme.primary : AppTheme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: isSelected ? AppTheme.colorScheme.primary : AppTheme.colorScheme.onSurface,
          ),
        ),
        trailing: hasSubmenu
            ? Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.colorScheme.onSurfaceVariant,
                size: 20,
              )
            : null,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        onTap: () {},
      ),
    );
  }

  Widget _buildSubMenuItem(BuildContext context, String title, {required bool isSelected}) {
    return Container(
      color: isSelected ? AppTheme.colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 56, right: 16),
        title: Text(
          title,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            color: isSelected ? AppTheme.colorScheme.primary : AppTheme.colorScheme.onSurface,
          ),
        ),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        onTap: () {},
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Divider(color: AppTheme.colorScheme.outlineVariant, height: 1),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: Icon(Icons.open_in_new_outlined, size: 24, color: AppTheme.colorScheme.onSurfaceVariant),
          title: Row(
            children: [
              Text(
                'Open visual editor',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.open_in_new, size: 14, color: AppTheme.colorScheme.onSurfaceVariant),
            ],
          ),
          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
          onTap: () {},
        ),
        Divider(color: AppTheme.colorScheme.outlineVariant, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                height: 20,
                width: 36,
                child: Switch(
                  value: false,
                  onChanged: null,
                  activeColor: AppTheme.colorScheme.primary,
                  inactiveThumbColor: AppTheme.colorScheme.outline,
                  trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Advanced mode (admin only)',
                  style: AppTheme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Method to add item to the list and trigger rebuild ---
  void _addItem(CrawlItem item) {
    setState(() {
      _allCrawlItems.insert(0, item);
      _loadInitialItems(); // Reload displayed items
      _sortData();
    });
  }

  // Shows dialog, triggers parent state update via callback
  void _rerunWithSameSettings(BuildContext context, CrawlItem item, Function(CrawlItem) onAddItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rerun crawl', style: AppTheme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to rerun this crawl with the same settings?',
          style: AppTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.textTheme.labelLarge),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);
              
              final newItem = CrawlItem(
                 type: item.type,
                 status: CrawlStatus.queued, 
                 startDate: formattedDate, 
                 wordCount: 0, 
                 visitedPages: 0, 
                 pageLimit: item.pageLimit, 
                 recurrence: item.recurrence, // Keep recurrence setting from original
                 terminationReason: null,
                 warnings: null,
                 nextScheduledRun: null, 
              );
              
              // Call the actual add item callback from the parent
              onAddItem(newItem); 

              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text(
                     'Crawl restart requested', // Simplified message
                     style: AppTheme.textTheme.bodyMedium?.copyWith(
                       color: AppTheme.colorScheme.onPrimary,
                     ),
                   ),
                   backgroundColor: AppTheme.colorScheme.primary,
                 ),
               );
            },
            child: Text('Confirm', style: AppTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.colorScheme.primary,
            )),
          ),
        ],
      ),
    );
  }

  // Simple method to view crawl details
  void _viewCrawlDetails(BuildContext context, CrawlItem item, {bool isRecurringView = false}) {
    // Update the selected item
    setState(() {
      _selectedCrawlItem = item;
    });
    
    // If no panel is showing, open Settings by default (or use the appropriate panel for recurring view)
    final currentPanel = ref.read(crawlDetailsPanelProvider);
    if (currentPanel == null) {
      // Always use details panel for recurring view
      ref.read(crawlDetailsPanelProvider.notifier).state = CrawlDetailsPanel.details;
    }
    // If a panel is already open, keep it open but update the content with the new item
    // No need to change state in this case as we just want to update the displayed item
  }
  
  // Handle panel icon click with improved guidance for when no item is selected
  void _handlePanelIconClick(CrawlDetailsPanel panel) {
    // If clicking the same panel that's already open, close it
    final currentPanel = ref.read(crawlDetailsPanelProvider);
    if (currentPanel == panel) {
      ref.read(crawlDetailsPanelProvider.notifier).state = null;
      return;
    }
    
    // If no item is selected, show guidance to the user
    if (_selectedCrawlItem == null) {
      // Determine the appropriate message for the current tab
      final String message = _tabController.index == 0
          ? 'Please select a crawl item from the table to see details'
          : 'Please select a recurring crawl from the table to see details';
      
      // Show guidance snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: AppTheme.colorScheme.primary,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppTheme.colorScheme.onPrimary,
            onPressed: () {
              // Dismiss the snackbar
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }
    
    // Check if we're in the recurring tab
    final bool isRecurringTab = _tabController.index == 1;
    
    // In recurring tab, only allow details panel
    if (isRecurringTab && panel != CrawlDetailsPanel.details) {
      return; // Don't change the panel
    }
    
    // For queued crawls, only allow details panel
    if (_selectedCrawlItem?.status == CrawlStatus.queued && panel != CrawlDetailsPanel.details) {
      return; // Don't change the panel
    }
    
    // Open the requested panel
    ref.read(crawlDetailsPanelProvider.notifier).state = panel;
  }

  void _cancelCrawl(BuildContext context, CrawlItem item) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel crawl', style: AppTheme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to cancel this crawl?',
          style: AppTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: AppTheme.textTheme.labelLarge),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logic to cancel the crawl
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Crawl has been cancelled',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.onError,
                    ),
                  ),
                  backgroundColor: AppTheme.colorScheme.error,
                ),
              );
            },
            child: Text('Yes', style: AppTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.colorScheme.onPrimary,
            )),
          ),
        ],
      ),
    );
  }

  void _viewStatistics(BuildContext context, CrawlItem item) {
    // This might become redundant if summary panel is used, or could show more charts
    showDialog(
      context: context,
      builder: (context) => StatisticsDialog(crawlItem: item),
    );
  }

  // --- Method to handle cancelling recurrence ---
  void _cancelRecurrence(BuildContext context, CrawlItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel recurrence', style: AppTheme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to cancel the recurrence for ${item.type} (${item.recurrence})?',
          style: AppTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: AppTheme.textTheme.labelLarge),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final itemIndex = _allCrawlItems.indexWhere(
                    (crawl) => crawl.type == item.type && crawl.startDate == item.startDate);
                if (itemIndex != -1) {
                  final originalItem = _allCrawlItems[itemIndex];
                  final updatedItem = CrawlItem(
                    type: originalItem.type,
                    status: CrawlStatus.canceledSchedule,
                    startDate: originalItem.startDate,
                    wordCount: originalItem.wordCount,
                    visitedPages: originalItem.visitedPages,
                    pageLimit: originalItem.pageLimit,
                    recurrence: '',
                    nextScheduledRun: null,
                    terminationReason: originalItem.terminationReason,
                    warnings: originalItem.warnings,
                  );
                  // Create a new list instance to ensure Flutter detects the change
                  final newList = List<CrawlItem>.from(_allCrawlItems);
                  newList[itemIndex] = updatedItem;
                  _allCrawlItems = newList;
                }
                _sortData(); // Re-sort and refresh displayed items
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Recurrence cancelled and schedule updated in history',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.onPrimary, // Use primary for success
                    ),
                  ),
                  backgroundColor: AppTheme.colorScheme.primary, // Use primary for success
                ),
              );
            },
            child: Text('Yes', style: AppTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.colorScheme.onPrimary, // Use onPrimary for text on primary button
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, CrawlItem item, Function(CrawlItem) onAddItem) {
    return PopupMenuButton<String>(
      splashRadius: 20,
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
      ),
      onSelected: (value) {
        if (value == 'rerun') {
          _rerunWithSameSettings(context, item, onAddItem);
        } else if (value == 'cancel') {
          _cancelCrawl(context, item);
        } else if (value == 'refresh') { // Handle refresh action
          // TODO: Implement actual status refresh logic
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(
                 'Refreshing status...',
                 style: AppTheme.textTheme.bodyMedium?.copyWith(
                   color: AppTheme.colorScheme.onPrimary,
                 ),
               ),
               duration: const Duration(seconds: 1), // Short duration
               backgroundColor: AppTheme.colorScheme.primary,
             ),
           );
        } else if (value == 'stats') {
          _viewStatistics(context, item);
        } else if (value == 'crawl_details') {
          _viewCrawlDetails(context, item);
          ref.read(crawlDetailsPanelProvider.notifier).state = CrawlDetailsPanel.details;
        } else if (value == 'requests') {
          _viewCrawlDetails(context, item);
          ref.read(crawlDetailsPanelProvider.notifier).state = CrawlDetailsPanel.requestSummary;
        } else if (value == 'logs') {
          _viewCrawlDetails(context, item);
          ref.read(crawlDetailsPanelProvider.notifier).state = CrawlDetailsPanel.logs;
        }
      },
      itemBuilder: (context) {
        final bool isQueued = item.status == CrawlStatus.queued;
        final bool isRunningOrInProgress = item.status == CrawlStatus.running || item.status == CrawlStatus.inProgress;
        final bool showStats = item.status == CrawlStatus.completed || 
                      item.status == CrawlStatus.failed || 
                      item.status == CrawlStatus.inProgress || 
                      item.status == CrawlStatus.running ||
                      item.status == CrawlStatus.canceled;
        
        List<PopupMenuEntry<String>> menuItems = [];

        // 1. Word statistics - First item (if applicable)
        if (showStats) {
          menuItems.add(
            PopupMenuItem<String>(
              value: 'stats',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.data_info_alert,
                    color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Word statistics',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 2. Crawl details
        menuItems.add(
          PopupMenuItem<String>(
            value: 'crawl_details',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Crawl details',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );

        // 3. Requests (if not queued)
        if (!isQueued) {
          menuItems.add(
            PopupMenuItem<String>(
              value: 'requests',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_list_numbered_rtl_outlined,
                    color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requests',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 4. Logs (if not queued)
        if (!isQueued) {
          menuItems.add(
            PopupMenuItem<String>(
              value: 'logs',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.manage_search_outlined,
                    color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logs',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 5. Refresh status - For running/in progress
        if (isRunningOrInProgress) {
          menuItems.add(
            PopupMenuItem<String>(
              value: 'refresh',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Refresh status',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 6. Rerun with same settings - Only for completed, failed, or canceled crawls
        if (item.status == CrawlStatus.completed || 
            item.status == CrawlStatus.failed || 
            item.status == CrawlStatus.canceled || 
            item.status == CrawlStatus.canceledSchedule) {
          menuItems.add(
            PopupMenuItem<String>(
              value: 'rerun',
              enabled: !isRunningOrInProgress,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: !isRunningOrInProgress
                        ? AppTheme.colorScheme.onSurface.withOpacity(0.6)
                        : AppTheme.colorScheme.onSurface.withOpacity(0.3),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rerun with same settings',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: !isRunningOrInProgress
                          ? AppTheme.colorScheme.onSurface
                          : AppTheme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 7. Cancel crawl - Last item (if queued or running/in progress)
        if (isQueued || isRunningOrInProgress) {
          menuItems.add(
            PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: AppTheme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cancel crawl',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return menuItems;
      },
    );
  }
  
  // Add a dedicated popup menu builder for recurring crawls
  Widget _buildRecurringPopupMenu(BuildContext context, CrawlItem item) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
      ),
      onSelected: (value) {
        if (value == 'cancel') {
          _cancelRecurrence(context, item);
        } else if (value == 'crawl_details') {
          _viewCrawlDetails(context, item, isRecurringView: true);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'crawl_details',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded, // Changed icon
                size: 18,
                color: AppTheme.colorScheme.onSurface.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text('Crawl details'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'cancel',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: AppTheme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Cancel and delete',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Ensure _buildStatusIndicatorText is ONLY defined as a method below,
  // NOT as a field anywhere in this class.

  Widget _buildStatusIndicatorText(BuildContext context, CrawlStatus status) {
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case CrawlStatus.completed:
        label = 'Done';
        color = Colors.green;
        icon = Icons.check_circle;
            break;
      case CrawlStatus.inProgress:
      case CrawlStatus.running:
        label = 'Ongoing';
        color = AppTheme.colorScheme.primary;
        icon = Icons.sync;
        // For these statuses, we'll use the spinning icon in the return statement
            break;
      case CrawlStatus.queued:
        label = 'Queued';
        color = Colors.orange;
        icon = Icons.schedule;
            break;
      case CrawlStatus.failed:
        label = 'Failed';
        color = AppTheme.colorScheme.error;
        icon = Icons.error;
            break;
      case CrawlStatus.canceled:
        label = 'Canceled';
        color = AppTheme.colorScheme.onSurface;
        icon = Icons.cancel_outlined; // Added icon
            break;
      case CrawlStatus.canceledSchedule:
        label = 'Canceled schedule';
        color = AppTheme.colorScheme.onSurface;
        icon = Icons.event_busy_outlined; // Added icon
            break;
        }

    return Row(
      children: [
        // Use SpinningIcon for inProgress and running statuses, regular Icon for others
        status == CrawlStatus.inProgress || status == CrawlStatus.running
            ? SpinningIcon(iconData: icon, color: color, size: 16)
            : Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          _toSentenceCase(label),
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // --- Helper method to show warnings dialog ---
  void _showWarningsDialog(BuildContext context, List<String> warnings, [CrawlItem? item]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        // Remove icon parameter
        title: Text(
          'Crawl warnings',
          style: Theme.of(context).textTheme.headlineSmall,
          // Remove textAlign: TextAlign.center to default to left alignment
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The following issues were detected during the crawl:',
                style: Theme.of(context).textTheme.bodyMedium,
                // Remove textAlign: TextAlign.center to default to left alignment
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline, 
                            color: Theme.of(context).colorScheme.error,
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatWarningText(warning),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              // Remove the divider here
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Close'),
          ),
          if (item != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // Open the Request Summary panel
                setState(() {
                  _selectedCrawlItem = item;
                });
                ref.read(crawlDetailsPanelProvider.notifier).state = CrawlDetailsPanel.requestSummary;
              },
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('View details'),
            ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 24, 16),
        actionsAlignment: MainAxisAlignment.end,
      ),
    );
  }

  // Helper for formatting warning text with proper capitalization
  String _formatWarningText(String warning) {
    // Preserve HTTP status code capitalization
    if (warning.contains('HTTP')) {
      return warning;
    }
    
    // Ensure proper sentence capitalization
    final sentences = warning.split('. ');
    if (sentences.length > 1) {
      return sentences.map((sentence) => _toSentenceCase(sentence)).join('. ');
    }
    
    // For other warnings, ensure sentence case
    return _toSentenceCase(warning);
  }

  // New helper method to build the crawl history tab with proper scrolling
  Widget _buildCrawlHistoryTab(List<CrawlItem> sortedItems, bool isPanelOpen) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable table area - use Expanded to fill available space
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: _displayedCrawlItems.isEmpty 
                ? Center(child: Text('No crawl history found'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate ideal table width - this is the "default" width we want
                      const double idealTableWidth = 1000; // Minimum width to display all columns properly
                      
                      // Determine if we need scrolling based on available width
                      final bool needsHorizontalScroll = constraints.maxWidth < idealTableWidth;
                      
                      // Use full width of container if larger than ideal, otherwise use ideal width with scrolling
                      final double tableWidth = needsHorizontalScroll ? idealTableWidth : constraints.maxWidth;
                      
                      return Stack(
                        children: [
                          // The original table structure - don't change this
                          Column(
                            children: [
                              Expanded(
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (ScrollNotification scrollInfo) {
                                    // Auto-load more when scrolled to the bottom
                                    if (!_isLoadingMore && _hasMoreItems && 
                                        scrollInfo is ScrollUpdateNotification) {
                                      // Check if we're near the bottom
                                      final metrics = scrollInfo.metrics;
                                      final isNearBottom = metrics.pixels >= (metrics.maxScrollExtent - 50);
                                      
                                      if (isNearBottom) {
                                        // Auto-load more items
                                        _loadMoreItems();
                                      }
                                    }
                                    return false;
                                  },
                                  child: SingleChildScrollView(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: tableWidth,
                                        child: DataTable(
                                          columnSpacing: 20.0,
                                          dataRowMinHeight: 60.0,
                                          dataRowMaxHeight: 72.0,
                                          headingRowHeight: 48.0,
                                          showCheckboxColumn: false,
                                          horizontalMargin: 12.0, // Reduced from default 24.0
                                          headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                            return AppTheme.colorScheme.surfaceVariant.withOpacity(0.5);
                                          }),
                                          headingTextStyle: AppTheme.bodySmallSemiBold().copyWith(
                                            color: AppTheme.colorScheme.onSurfaceVariant,
                                          ),
                                          dataTextStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.colorScheme.onSurface,
                                          ),
                                          dividerThickness: 1.0,
                                          showBottomBorder: true,
                                          
                                          columns: [
                                            DataColumn(
                                              label: Container(
                                                width: 120, // Slightly wider
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Started',
                                                  style: AppTheme.bodySmallSemiBold().copyWith(
                                                    color: AppTheme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: 140, // Wider to match screenshot
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Type',
                                                  style: AppTheme.bodySmallSemiBold().copyWith(
                                                    color: AppTheme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: 120, // Slightly wider
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  'Visited pages',
                                                  style: AppTheme.bodySmallSemiBold().copyWith(
                                                    color: AppTheme.colorScheme.onSurfaceVariant,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              numeric: true,
                                            ),
                                            DataColumn(
                                              label: Container(
                                                // width: 100, // Removed fixed width
                                                alignment: Alignment.centerLeft,
                                                padding: const EdgeInsets.only(left: 12.0), // Align with ELButton's internal icon padding
                                                child: Text(
                                                  'Word count',
                                                  style: AppTheme.bodySmallSemiBold().copyWith(
                                                    color: AppTheme.colorScheme.onSurfaceVariant,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                              numeric: false, // Changed to false
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: 150,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Status',
                                                  style: AppTheme.bodySmallSemiBold().copyWith(
                                                    color: AppTheme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Container(
                                                width: 80, // Slightly wider for action buttons
                                                alignment: Alignment.center, // Changed to center alignment
                                                padding: const EdgeInsets.symmetric(horizontal: 16), // Added padding to match recurring table
                                                child: Text(
                                                  'Actions',
                                                  style: AppTheme.bodySmallSemiBold().copyWith(
                                                    color: AppTheme.colorScheme.onSurfaceVariant,
                                                  ),
                                                  textAlign: TextAlign.center, // Added to ensure text is centered
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: _displayedCrawlItems.map((item) {
                                            final index = _displayedCrawlItems.indexOf(item);
                                            return _buildDataRow(context, item, index);
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Only show loading indicator when loading more items
                              if (_isLoadingMore)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  // New helper method to build the recurring crawls tab with proper scrolling
  Widget _buildRecurringCrawlsTab([bool isPanelOpen = false]) {
    final recurringItems = _allCrawlItems.where((item) {
      final recurrenceLower = item.recurrence.toLowerCase();
      return (recurrenceLower == 'weekly' || recurrenceLower == 'monthly') 
             && item.nextScheduledRun != null;
    }).toList();
    
    // Take only the top three rows
    final limitedItems = recurringItems.take(3).toList();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Removed the Button row from here since it's now above the tabs
          
          // Scrollable table area with proper sizing
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: limitedItems.isEmpty 
                ? Center(child: Text('No recurring crawls found'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate widths based on percentages of available width
                      final double totalWidth = constraints.maxWidth;
                      final double repeatsWidth = totalWidth * 0.26; // 26%
                      final double dateWidth = totalWidth * 0.26;    // 26%
                      final double typeWidth = totalWidth * 0.34;    // 34%
                      final double actionsWidth = totalWidth * 0.14; // 14%

                      return SingleChildScrollView(
                        child: SizedBox(
                          width: totalWidth,
                          child: DataTable(
                            horizontalMargin: 0,
                            columnSpacing: 0,
                            headingRowHeight: 48,
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 64,
                            showCheckboxColumn: false,
                            headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                              return AppTheme.colorScheme.surfaceVariant.withOpacity(0.5);
                            }),
                            dividerThickness: 1,
                            showBottomBorder: true,
                            headingTextStyle: AppTheme.bodySmallSemiBold().copyWith(
                              color: AppTheme.colorScheme.onSurfaceVariant,
                            ),
                            columns: [
                              DataColumn(
                                label: Container(
                                  width: repeatsWidth,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Repeats every',
                                    style: AppTheme.bodySmallSemiBold().copyWith(
                                      color: AppTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Container(
                                  width: dateWidth,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Next run date',
                                    style: AppTheme.bodySmallSemiBold().copyWith(
                                      color: AppTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Container(
                                  width: typeWidth,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Type',
                                    style: AppTheme.bodySmallSemiBold().copyWith(
                                      color: AppTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Container(
                                  width: actionsWidth,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Actions',
                                    style: AppTheme.bodySmallSemiBold().copyWith(
                                      color: AppTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: limitedItems.map((item) => _buildFixedWidthDataRow(
                              context, 
                              item, 
                              repeatsWidth, 
                              dateWidth, 
                              typeWidth, 
                              actionsWidth
                            )).toList(),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Add a new helper method for building data rows with fixed widths
  DataRow _buildFixedWidthDataRow(
    BuildContext context, 
    CrawlItem item,
    double repeatsWidth,
    double dateWidth,
    double typeWidth,
    double actionsWidth,
  ) {
    final nextRunFormatted = item.nextScheduledRun != null
        ? DateFormat('MMM d, yyyy').format(item.nextScheduledRun!)
        : 'Not scheduled';

    // Determine display text for recurrence in days
    String recurrenceText;
    switch (item.recurrence.toLowerCase()) {
      case 'weekly':
        recurrenceText = 'Every 7 days';
        break;
      case 'monthly':
        // Calculate days based on current month, defaulting to 30 if we can't determine
        int days = 30; // Default
        if (item.nextScheduledRun != null) {
          final now = DateTime.now();
          final nextRun = item.nextScheduledRun!;
          if (now.month == nextRun.month && now.year == nextRun.year) {
            // Same month, so we can calculate more precisely
            // Get the number of days in the current month
            final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
            days = lastDayOfMonth;
          } else if (nextRun.isAfter(now)) {
            // Use the days from the next scheduled month
            final lastDayOfMonth = DateTime(nextRun.year, nextRun.month + 1, 0).day;
            days = lastDayOfMonth;
          }
        }
        recurrenceText = 'Every $days days';
        break;
      default:
        // If it's a custom recurrence, try to extract days from the string
        if (item.recurrence.contains('days')) {
          recurrenceText = item.recurrence;
        } else {
          recurrenceText = 'Every ${item.recurrence}';
        }
    }

    // Check if this item is selected
    final bool isSelected = _selectedCrawlItem?.type == item.type && 
                           _selectedCrawlItem?.startDate == item.startDate;

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (isSelected) return AppTheme.colorScheme.primaryContainer.withOpacity(0.3);
          if (states.contains(MaterialState.hovered)) return AppTheme.colorScheme.surfaceVariant.withOpacity(0.5);
          return null; // Use default value
        },
      ),
      onSelectChanged: (_) => _viewCrawlDetails(context, item, isRecurringView: true),
      cells: [
        // Repeats every cell
        DataCell(
          Container(
            width: repeatsWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              recurrenceText,
              style: AppTheme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Next run date cell
        DataCell(
          Container(
            width: dateWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              nextRunFormatted,
              style: AppTheme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Type cell
        DataCell(
          Container(
            width: typeWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              item.type,
              style: AppTheme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Actions cell - keep the popup menu unaffected by row clicks
        DataCell(
          Container(
            width: actionsWidth,
            alignment: Alignment.center,
            child: _buildRecurringPopupMenu(context, item),
          ),
          onTap: () {}, // Empty onTap to prevent row click from propagating
        ),
      ],
    );
  }

  // New helper method to build data rows for the crawl history tab
  DataRow _buildDataRow(BuildContext context, CrawlItem item, int index) {
    final bool isSelected = _selectedCrawlItem?.type == item.type && 
                            _selectedCrawlItem?.startDate == item.startDate;
    final showStats = item.status == CrawlStatus.completed || 
                      item.status == CrawlStatus.failed || 
                      item.status == CrawlStatus.inProgress || 
                      item.status == CrawlStatus.running ||
                      item.status == CrawlStatus.canceled;
    final hasWarnings = item.warnings != null && item.warnings!.isNotEmpty;
    final hasTerminationReason = item.terminationReason != null && item.terminationReason!.isNotEmpty;
    
    final numberFormat = NumberFormat.decimalPattern();
    String formattedVisitedPages;
    String pageLimitDisplay;
    
    // For queued or canceled schedule, show 0 visited pages
    if (item.status == CrawlStatus.queued || item.status == CrawlStatus.canceledSchedule) {
      formattedVisitedPages = "0";
      pageLimitDisplay = item.pageLimit != null ? " / ${numberFormat.format(item.pageLimit!)}" : "";
    } else if (item.status == CrawlStatus.failed && item.visitedPages == 73) {
      formattedVisitedPages = numberFormat.format(item.visitedPages);
      pageLimitDisplay = " / —";  // Format as "/ em-dash"
    } else if (item.terminationReason == "No more pages left" && item.pageLimit != null) {
      // When terminated due to no more pages, show full limit
      formattedVisitedPages = numberFormat.format(item.pageLimit!);
      pageLimitDisplay = " / ${numberFormat.format(item.pageLimit!)}";
    } else {
      formattedVisitedPages = numberFormat.format(item.visitedPages);
      pageLimitDisplay = item.pageLimit != null ? " / ${numberFormat.format(item.pageLimit!)}" : "";
    }
    
    // Only show word count if not queued or canceled schedule
    final formattedWordCount = (item.status == CrawlStatus.queued || item.status == CrawlStatus.canceledSchedule) 
        ? "" 
        : numberFormat.format(item.wordCount);

    // Parse datetime and format with time
    final DateTime startDateTime = DateTime.parse(item.startDate);
    final String dateDisplay = DateFormat('MMM d, yyyy').format(startDateTime);
    final String timeDisplay = DateFormat('HH:mm:ss').format(startDateTime);

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (isSelected) return AppTheme.colorScheme.primaryContainer.withOpacity(0.3);
          if (states.contains(MaterialState.hovered)) return AppTheme.colorScheme.surfaceVariant.withOpacity(0.5);
          return null; // Use default value
        },
      ),
      onSelectChanged: (_) => _viewCrawlDetails(context, item),
      cells: [
        // Start date cell
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateDisplay,
                style: AppTheme.textTheme.bodyMedium,
              ),
              Text(
                timeDisplay,
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Type cell
        DataCell(
          Text(item.type, overflow: TextOverflow.ellipsis),
        ),
        // Visited Pages cell
        DataCell(
          Container(
            alignment: Alignment.centerRight,
            child: Text('$formattedVisitedPages$pageLimitDisplay'),
          ),
        ),
        // Word Count cell - Special case with specific click behavior
        DataCell(
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12.0),
            child: item.wordCount > 0
              ? HoverableTextLink(
                  text: formattedWordCount,
                  icon: showStats ? Symbols.data_info_alert : null,
                  onTap: showStats ? () => _viewStatistics(context, item) : null,
                  enabled: showStats,
                  iconSize: (AppTheme.textTheme.bodyMedium?.fontSize ?? 14.0) + 8,
                  iconColor: AppTheme.colorScheme.primary,
                  textStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colorScheme.primary,
                  ),
                  makeBoldOnHover: true,
                )
              : Text(
                  '',
                  style: AppTheme.textTheme.bodyMedium,
                  textAlign: TextAlign.left,
                ),
          ),
        ),
        // Status cell
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusIndicatorText(context, item.status),
                ],
              ),
              if (hasTerminationReason)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    item.terminationReason!,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              if (hasWarnings)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: HoverableTextLink(
                    text: 'Warnings${item.warnings!.length > 1 ? " (${item.warnings!.length})" : ""}',
                    onTap: () => _showWarningsDialog(context, item.warnings!, item),
                    enabled: true,
                    textStyle: AppTheme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        // Actions cell - keep the popup menu unaffected by row clicks
        DataCell(
          Container(
            width: 80,
            alignment: Alignment.center,
            child: _buildPopupMenu(context, item, _addItem),
          ),
          onTap: () {}, // Empty onTap to prevent row click from propagating to this cell
        ),
      ],
    );
  }

  Widget _buildMobileTerminationOrWarning(BuildContext context, String text, {required bool isWarning}) {
    return Container(
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWarning) 
            Padding(
              padding: const EdgeInsets.only(right: 6.0, top: 2.0),
              child: Icon(Icons.warning_amber_outlined, size: 14, color: Colors.orange.shade700),
            ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, CrawlStatus status) {
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case CrawlStatus.completed:
        label = 'Done';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case CrawlStatus.inProgress:
      case CrawlStatus.running:
        label = 'Ongoing';
        color = AppTheme.colorScheme.primary;
        icon = Icons.sync;
        break;
      case CrawlStatus.queued:
        label = 'Queued';
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case CrawlStatus.failed:
        label = 'Failed';
        color = AppTheme.colorScheme.error;
        icon = Icons.error;
        break;
      case CrawlStatus.canceled:
        label = 'Canceled';
        color = AppTheme.colorScheme.onSurface;
        icon = Icons.cancel_outlined;
        break;
      case CrawlStatus.canceledSchedule:
        label = 'Canceled schedule';
        color = AppTheme.colorScheme.onSurface;
        icon = Icons.event_busy_outlined;
        break;
    }

    return Row(
      children: [
        // Use SpinningIcon for inProgress and running statuses, regular Icon for others
        status == CrawlStatus.inProgress || status == CrawlStatus.running
            ? SpinningIcon(iconData: icon, color: color, size: 16)
            : Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          _toSentenceCase(label),
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  // Load next page of items
  void _loadNextPage() {
    if (_isLoadingMore || !_hasMoreItems) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _currentPage++;
        _displayedCrawlItems = _allCrawlItems
          .skip((_currentPage - 1) * _itemsPerPage)
          .take(_itemsPerPage)
          .toList();
        _hasMoreItems = _currentPage * _itemsPerPage < _allCrawlItems.length;
        _isLoadingMore = false;
      });
    });
  }
  
  // Load previous page of items
  void _loadPreviousPage() {
    if (_isLoadingMore || _currentPage <= 1) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _currentPage--;
        _displayedCrawlItems = _allCrawlItems
          .skip((_currentPage - 1) * _itemsPerPage)
          .take(_itemsPerPage)
          .toList();
        _hasMoreItems = _currentPage * _itemsPerPage < _allCrawlItems.length;
        _isLoadingMore = false;
      });
    });
  }

  // New helper method to build a clickable word count cell
  Widget _buildClickableWordCountCell(BuildContext context, String wordCount, CrawlItem item, bool showStats) {
    // Check if word count is 0
    final bool hasWordCount = item.wordCount > 0;
    final formattedCount = hasWordCount ? wordCount : '';
    
    // Get the base font size to calculate icon size
    final baseFontSize = AppTheme.textTheme.bodyMedium?.fontSize ?? 14.0;
    
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 12.0),
      child: hasWordCount 
        ? HoverableTextLink(
            text: formattedCount,
            icon: showStats ? Symbols.data_info_alert : null,
            onTap: showStats ? () => _viewStatistics(context, item) : null,
            enabled: showStats,
            iconSize: baseFontSize + 8, // Increased from +6 to +8 to make it larger
            iconColor: AppTheme.colorScheme.primary,
            textStyle: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.colorScheme.primary,
            ),
            makeBoldOnHover: true,
          )
        : Text(
            '',
            style: AppTheme.textTheme.bodyMedium,
            textAlign: TextAlign.left,
          ),
    );
  }

  // Add method to handle ESC key press
  void _handleEscKeyPress() {
    final selectedPanel = ref.read(crawlDetailsPanelProvider);
    if (selectedPanel != null) {
      ref.read(crawlDetailsPanelProvider.notifier).state = null;
    }
  }
}

// --- Spinning Icon Widget ---
class SpinningIcon extends StatefulWidget {
  final IconData iconData;
  final Color color;
  final double size;

  const SpinningIcon({
    super.key,
    required this.iconData,
    required this.color,
    this.size = 16.0, // Default size
  });

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Speed of rotation
      vsync: this,
    )..repeat(); // Make it spin continuously
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        widget.iconData,
        color: widget.color,
        size: widget.size,
        ),
      );
  }
}

// --- Top-level Sentence Case Helper ---
String _toSentenceCase(String input) {
  if (input.isEmpty) return "";
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

// Add missing methods below

// Helper method to build a summary section with title and key-value pairs
Widget _buildSummarySection(BuildContext context, String title, List<Widget> rows) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      ...rows,
    ],
  );
}

// Helper method to build a key-value row for the summary sections
Widget _buildKeyValueRow(BuildContext context, String key, String value, {
  bool isBold = false, 
  int indent = 0, 
  bool isAdminOnly = false,
  String? tooltip,
}) {
  final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    color: isAdminOnly ? AppTheme.colorScheme.tertiary : null,
  );
  
  final keyWidget = tooltip != null
      ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              key,
              style: textStyle,
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: tooltip,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              preferBelow: true,
              textStyle: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        )
      : Text(
          key,
          style: textStyle,
        );
  
  return Padding(
    padding: EdgeInsets.only(left: indent * 16.0, bottom: 8.0),
    child: Row(
      children: [
        Expanded(
          child: keyWidget,
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: textStyle,
        ),
      ],
    ),
  );
}

// Helper to build a log file card with actions
Widget _buildLogFileCard(
  BuildContext context, {
  required String fileName,
  required bool hasParameters,
  required Function() onFilter,
}) {
  // Replace the example file names with the new format
  final String exampleFileName = "0be45hl6_0Tie9x_1745582270415_88960-00000.log";
  
  // Format the display of the file name
  final displayFileName = fileName.endsWith('.log') 
      ? fileName.substring(0, fileName.length - 4)
      : fileName;
      
  // Get just the file ID part for display (after the last underscore and before the extension)
  final parts = displayFileName.split('_');
  final fileId = parts.length > 3 ? parts[3] : displayFileName;
  
  // Truncate the displayed name if it's too long
  final truncatedFileName = parts.length > 3 
      ? '..._${parts[2]}_$fileId' 
      : displayFileName;
  
  // Sample parameters for display
  final Map<String, String> parameters = {
    'page': '5',
    'sort': 'desc',
    'limit': '20',
    'filter': 'active',
    'view': 'full'
  };
  
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Log file header - Now the entire row is clickable
          InkWell(
            onTap: onFilter,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, 
                    size: 18, 
                    color: AppTheme.colorScheme.onSurfaceVariant
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$truncatedFileName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    splashRadius: 20,
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                  color: AppTheme.colorScheme.onSurfaceVariant,
                ),
                    onSelected: (value) {
                      if (value == 'filter') {
                        onFilter();
                      } else if (value == 'download') {
                        // Handle download
                      } else if (value == 'analysis') {
                        _showLogAnalysisDialog(context, fileName, hasParameters, parameters);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'filter',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list, size: 18, color: AppTheme.colorScheme.onSurface),
                const SizedBox(width: 8),
                            Text('Filter'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download, size: 18, color: AppTheme.colorScheme.onSurface),
                            const SizedBox(width: 8),
                            Text('Download'),
              ],
            ),
          ),
                      PopupMenuItem<String>(
                        value: 'analysis',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
              children: [
                            Icon(Icons.analytics_outlined, size: 18, color: AppTheme.colorScheme.onSurface),
                            const SizedBox(width: 8),
                            Text('Crawl log analysis'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// New method to show log analysis dialog
void _showLogAnalysisDialog(
  BuildContext context, 
  String fileName,
  bool hasParameters,
  Map<String, String> parameters
) {
  // Create an expanded list of parameters to demonstrate scrolling
  final Map<String, String> expandedParameters = {
    'page': '5',
    'sort': 'desc',
    'limit': '20',
    'filter': 'active',
    'view': 'full',
    'mode': 'advanced',
    'include_images': 'true',
    'include_js': 'false',
    'include_css': 'true',
    'follow_redirects': 'true',
    'max_redirects': '3',
    'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'timeout': '30000',
    'retry_count': '2',
    'depth': '3',
    'crawl_delay': '500',
    'respect_robots_txt': 'true',
    'cookies_enabled': 'true',
    'skip_ssl_verification': 'false',
    'preserve_fragments': 'false',
    'log_level': 'info',
    'connection_timeout': '30000',
    'read_timeout': '30000',
    'accept_language': 'en-US,en;q=0.9',
    'capture_console': 'true',
    'wait_for_selector': '.main-content',
    'wait_time': '5000',
    'js_enabled': 'true',
    'ignore_ssl_errors': 'false',
    'max_concurrent_requests': '4',
    'max_request_retries': '3',
    'store_screenshots': 'false',
    'viewport_width': '1366',
    'viewport_height': '768',
    'emulate_mobile': 'false',
    'cache_ttl': '3600',
    'output_format': 'json',
    'parse_selectors': 'h1,h2,p.content',
    'extract_metadata': 'true',
    'follow_sitemap': 'true'
  };

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Crawl log analysis',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 400,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File name with semibold
              Text(
                fileName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              ),
              const SizedBox(height: 16),
                    
              // Analysis stats - Pages analyzed with semibold label (not number)
              Row(
                children: [
                  Text('Pages analysed: ', 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text('14', 
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
                    
              const SizedBox(height: 12),
                    
              // Parameters section with semibold label (not count)
              if (hasParameters) ...[
                Row(
                  children: [
                    Text(
                      'Parameters found', 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    ),
                    Text(
                      ' (${expandedParameters.length}): ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...expandedParameters.entries.map((entry) => 
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}: ', 
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                ).toList(),
              ] else ...[
                Text(
                  'Parameters found: 0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.primary,
                  )
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

  // Method for building checkmark items in the Fine-tune section
  Widget _buildCheckmarkItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: AppTheme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.textTheme.bodyMedium,
          ),
        ],
    ),
  );
}

// Method to show log filter dialog
void _showLogFilterDialog(BuildContext context) {
  // Filter options with preselection
  final Map<String, List<String>> filterOptions = {
    'Crawl status': ['processed', 'failed', 'skipped', 'other'],
    'Response type': ['html', 'js', 'json', 'xml', 'css', 'image', 'other'],
    'Response code': ['200-299', '300-399', '400-499', '500-599'],
    'Warning type': ['redirectionToSelf', 'resourceUnderEnforcedPath', 'other'],
  };
  
  // Track selected options (all pre-selected by default)
  final Map<String, List<String>> selectedOptions = {};
  
  // Initialize all options as selected
  filterOptions.forEach((key, options) {
    selectedOptions[key] = List.from(options); // All preselected
  });
  
  // Track regex value
  TextEditingController regexController = TextEditingController();
  final regexFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        // Function to toggle chip selection
        void toggleChip(String category, String option) {
          setState(() {
            if (selectedOptions[category]!.contains(option)) {
              selectedOptions[category]!.remove(option);
            } else {
              selectedOptions[category]!.add(option);
            }
          });
        }
        
        return AlertDialog(
          title: Text(
            'Crawl log visualization filter',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          content: SizedBox(
            width: 800, // Set a wider fixed width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Build filter sections with chips
                  ...filterOptions.entries.map((entry) {
                    final category = entry.key;
                    final options = entry.value;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        
                        // Chips for each option in the category
                        SizedBox(
                          width: double.infinity,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 56.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,
                                children: options.map((option) {
                                  final isSelected = selectedOptions[category]?.contains(option) ?? false;
                                  
                                  return FilterChip(
                                    label: Text(option),
                                    selected: isSelected,
                                    onSelected: (_) => toggleChip(category, option),
                                    avatar: isSelected ? const Icon(Icons.check, size: 18) : null,
                                    backgroundColor: isSelected 
                                      ? AppTheme.colorScheme.primaryContainer 
                                      : AppTheme.colorScheme.surface,
                                    selectedColor: AppTheme.colorScheme.primaryContainer,
                                    labelStyle: TextStyle(
                                      color: isSelected 
                                        ? AppTheme.colorScheme.onPrimaryContainer
                                        : AppTheme.colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                    showCheckmark: false,
                                    side: BorderSide(
                                      color: isSelected
                                        ? Colors.transparent
                                        : AppTheme.colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    padding: EdgeInsets.only(
                                      right: 16, 
                                      left: isSelected ? 8 : 16, 
                                      top: 12, 
                                      bottom: 12
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        
                        const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                  
                  // Regex section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Regex header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Regular expression filter',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Regex input field
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: regexController,
                          focusNode: regexFocusNode,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter pattern to filter log lines (leave empty to see all)',
                            helperText: null,
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),
                          ),
                        ),
                      ),
                      
                      // Remove the divider line
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: AppTheme.textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Here you would typically use the selectedOptions and regex pattern
                // to filter the logs before showing them
                
                // Get the regex pattern (if any)
                final regexPattern = regexController.text.trim();
                
                // Log the selected options and regex pattern (for demo purposes)
                if (regexPattern.isNotEmpty) {
                  print('Applied regex pattern: $regexPattern');
                }
                filterOptions.forEach((category, _) {
                  print('$category: ${selectedOptions[category]?.join(", ")}');
                });
                
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: AppTheme.textTheme.labelLarge,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Show log'),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 18),
                ],
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 24, 16),
          actionsAlignment: MainAxisAlignment.end,
        );
        },
    ),
  );
}

// Add this new widget for better hover handling
class HoverableTextLink extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? iconSize;
  final bool makeBoldOnHover;

  const HoverableTextLink({
    Key? key,
    required this.text,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.iconColor,
    this.textStyle,
    this.iconSize,
    this.makeBoldOnHover = false,
  }) : super(key: key);

  @override
  State<HoverableTextLink> createState() => _HoverableTextLinkState();
}

class _HoverableTextLinkState extends State<HoverableTextLink> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.enabled 
        ? (isHovering ? AppTheme.colorScheme.primary : (widget.textStyle?.color ?? AppTheme.colorScheme.onSurface))
        : AppTheme.colorScheme.onSurface;
        
    final TextStyle baseStyle = widget.textStyle ?? AppTheme.textTheme.bodyMedium!;
    
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => setState(() => isHovering = true) : null,
      onExit: widget.enabled ? (_) => setState(() => isHovering = false) : null,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Ensure center alignment
            children: [
              Text(
                widget.text,
                style: baseStyle.copyWith(
                  decoration: widget.enabled ? TextDecoration.underline : null,
                  color: textColor,
                  decorationColor: textColor,
                  fontWeight: widget.makeBoldOnHover && isHovering ? FontWeight.bold : baseStyle.fontWeight,
                ),
              ),
              if (widget.icon != null && widget.enabled) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2), // Small adjustment to align with text
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize ?? (baseStyle.fontSize! + 6), // Use provided size or calculate from text
                    color: widget.iconColor ?? textColor,
                    weight: widget.makeBoldOnHover && isHovering ? 700.0 : 400.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

