import 'package:elbaseapp/presentation/crawl_history/crawl_model.dart';
import 'package:elbaseapp/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CrawlDetailsPage extends StatefulWidget {
  final CrawlItem crawlItem;
  final bool isRecurringView; // Flag to hide tabs

  const CrawlDetailsPage({super.key, required this.crawlItem, this.isRecurringView = false});

  // Define route name for convenience
  static const String routeName = '/crawl-details'; 

  @override
  State<CrawlDetailsPage> createState() => _CrawlDetailsPageState();
}

class _CrawlDetailsPageState extends State<CrawlDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State for filter checkboxes
  final Map<String, Map<String, bool>> _filterSelections = {
    'Crawl status': {
      'processed': false,
      'failed': false,
      'skipped': false,
      'other': false,
    },
    'Response type': {
      'html': false,
      'js': false,
      'json': false,
      'xml': false,
      'css': false,
      'image': false,
      'other': false,
    },
    'Response code': {
      '200-299': false,
      '300-399': false,
      '400-499': false,
      '500-599': false,
    },
    'Warning type': {
      'redirectionToSelf': false,
      'resourceUnderEnforcedPath': false,
      'other': false,
    },
  };

  // State for regex chips
  final List<String> _regexFilters = [];
  final TextEditingController _regexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set TabController length based on the view type
    _tabController = TabController(
      length: widget.isRecurringView ? 1 : 3, // Only 1 tab for recurring view
      vsync: this
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the same layout structure as CrawlHistoryPage
    return Scaffold(
      body: Row(
        children: [
          // Left sidebar with blue background (match exact width and style)
          Container(
            width: 317,
            color: const Color(0xFFF2F5FC), // Light blue background
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top app bar - blue - only once at the top of the page
                Container(
                  height: 60,
                  color: AppTheme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.menu, color: AppTheme.colorScheme.onPrimary),
                ),
                // Side menu items - exactly as in main page
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Setup with completed indicator
                      _buildSetupMenuItem(context),
                      // Regular menu items
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
                      // Manage translations 
                      _buildMenuItem(
                        context,
                        'Manage translations',
                        Icons.edit_note_outlined,
                        false,
                      ),
                      // Crawl history (selected)
                      _buildSubMenuItem(context, 'Crawl history', isSelected: true),
                      // Subscription
                      _buildMenuItem(
                        context,
                        'Subscription',
                        Icons.credit_card_outlined,
                        false,
                      ),
                      // Settings with submenu
                      _buildMenuItem(
                        context,
                        'Settings',
                        Icons.settings_outlined,
                        false,
                        hasSubmenu: true,
                      ),
                      // Bottom section
                      _buildBottomSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top app bar - blue
                Container(
                  height: 60,
                  color: AppTheme.colorScheme.primary,
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
                      CircleAvatar(
                        backgroundColor: AppTheme.colorScheme.onPrimary,
                        radius: 16,
                        child: Icon(Icons.person, color: AppTheme.colorScheme.primary, size: 20),
                      ),
                    ],
                  ),
                ),
                // Page title header with back button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: AppTheme.colorScheme.primary),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 16),
                      // Page title
                      Text(
                        'Crawl details: ${widget.crawlItem.type} - ${widget.crawlItem.startDate}',
                        style: AppTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Indicator line using outlineVariant color
                Container(
                  margin: const EdgeInsets.only(top: 0.5),
                  height: 0.5,
                  color: AppTheme.colorScheme.outlineVariant,
                ),
                SizedBox(height: 4), // Space between the thin line and the content
                // TabBar (conditionally show fewer tabs)
                TabBar(
                  controller: _tabController,
                  tabs: widget.isRecurringView 
                    ? const [
                        Tab(text: 'Crawl settings'),
                      ]
                    : const [
                        Tab(text: 'Crawl settings'),
                        Tab(text: 'Logs'),
                        Tab(text: 'Request summary'),
                      ],
                  labelColor: AppTheme.colorScheme.primary,
                  unselectedLabelColor: AppTheme.colorScheme.onSurfaceVariant,
                  indicatorColor: AppTheme.colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppTheme.colorScheme.outlineVariant,
                  labelStyle: AppTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: AppTheme.textTheme.labelLarge,
                ),
                // Main content body - TabBarView (conditionally show fewer children)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: widget.isRecurringView
                      ? [
                          // Only show Settings tab
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _buildCrawlSettingsTab(),
                          ),
                        ]
                      : [
                          // Show all three tabs
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _buildCrawlSettingsTab(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _buildLogsTab(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: _buildRequestSummaryTab(),
                          ),
                        ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- The reused menu structure components ---
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
        onTap: () {
          // Navigate back to the relevant page
          if (title == 'Crawl history') {
            Navigator.of(context).pop();
          }
        },
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
        onTap: () {
          // Navigate back to crawl history
          Navigator.of(context).pop();
        },
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

  // --- Content for Tabs (Keep the existing implementation) ---

  Widget _buildCrawlSettingsTab() {
    // Use SingleChildScrollView for potentially long content
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSectionTitle('Crawl type'),
          const SizedBox(height: 8),
          _buildSettingsItem(widget.crawlItem.type), // Use actual data

          const Divider(height: 32),

          _buildTabSectionTitle('Scope'),
          const SizedBox(height: 8),
          _buildSettingsItem('Crawl entire website'), // Mock data - replace later if needed
          _buildSettingsItem('Page limit: 100'),     // Mock data - replace later if needed

          const Divider(height: 32),

          _buildTabSectionTitle('Restrictions'),
          const SizedBox(height: 8),
          _buildSettingsItem('Existing project restrictions'), // Mock data

          const SizedBox(height: 12),
          _buildSettingsItem('Crawl pages starting with:', isSubheader: true), // Mock data
          _buildSettingsItem('/blog*', indent: 1),                     // Mock data
          _buildSettingsItem('/news*', indent: 1),                     // Mock data

          const Divider(height: 32),

          _buildTabSectionTitle('Fine-tune'),
          const SizedBox(height: 8),
          _buildSettingsItem('Default fine-tune settings'), // Mock data

          const Divider(height: 32),

          _buildTabSectionTitle('Recurrence'),
          const SizedBox(height: 8),
          // Display actual recurrence data from the CrawlItem
          _buildSettingsItem(widget.crawlItem.recurrence.isNotEmpty
                             ? widget.crawlItem.recurrence
                             : 'No recurring crawls scheduled'),

          const Divider(height: 32),

          _buildTabSectionTitle('Snapshot'),
          const SizedBox(height: 8),
          _buildSettingsItem('Reuse existing pages and store new pages'), // Mock data
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    // Mock data for log downloads
    final logDates = [
      {'date': 'April 30, 2023', 'size': '2.4 MB'},
      // ... other mock log dates ...
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSectionTitle('Log analysis summary'),
          const SizedBox(height: 8),
          _buildInfoRow('Pages analysed', '14'), // Mock data
          _buildInfoRow('Pages found with parameter', '0'), // Mock data
          // ... other summary mock data ...

          const Divider(height: 32),

          _buildTabSectionTitle('Available logs'),
          const SizedBox(height: 8),
          ...logDates.map((log) => _buildLogLink(log)).toList(), // Mock data

          const Divider(height: 32),

          // --- Crawl Log Visualization --- Changed title and added description
          _buildTabSectionTitle('Crawl log visualization'), 
          const SizedBox(height: 4),
          Text(
            'Narrow down the log results using the filters below.',
            style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Padding( // Add padding inside the card, replacing the header's padding
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filter Chip Groups
                  _buildFilterChipGroup(
                    context,
                    'Crawl status',
                    _filterSelections['Crawl status']!,
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChipGroup(
                    context,
                    'Response type',
                    _filterSelections['Response type']!,
                  ),
                   const SizedBox(height: 16),
                  _buildFilterChipGroup(
                    context,
                    'Response code',
                    _filterSelections['Response code']!,
                  ),
                  const SizedBox(height: 24),
                  _buildFilterChipGroup(
                    context,
                    'Warning type',
                    _filterSelections['Warning type']!,
                  ),
                  const SizedBox(height: 24),
                  // Regex Input Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align items nicely if text wraps
                       children: [
                      Expanded(
                        child: TextField(
                          controller: _regexController,
                    decoration: InputDecoration(
                            hintText: 'Add regex filter', // Updated placeholder
                      hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: AppTheme.colorScheme.surfaceVariant.withOpacity(0.3),
                      border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                      ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: AppTheme.textTheme.bodyMedium,
                    maxLines: 1,
                          onSubmitted: (_) => _addRegexFilter(), // Add filter on submit
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addRegexFilter, // Call helper to add filter
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          minimumSize: const Size(0, 48), // Match TextField height approx
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Space between input and chips
                  // Display Regex Chips
                  if (_regexFilters.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _regexFilters.map((regex) {
                        return Chip(
                          label: Text(regex),
                          labelStyle: AppTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.colorScheme.primary,
                          ),
                          backgroundColor: AppTheme.colorScheme.primaryContainer.withOpacity(0.3),
                          side: BorderSide(
                            color: AppTheme.colorScheme.primary.withOpacity(0.5),
                            width: 1,
                          ),
                          onDeleted: () {
                            setState(() {
                              _regexFilters.remove(regex);
                            });
                          },
                          deleteIconColor: AppTheme.colorScheme.primary.withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon( // Use ElevatedButton.icon for consistency
                        onPressed: () {
                          // Handle Show Log action (apply filters and navigate/display)
                          // TODO: Implement log display logic based on _filterSelections and regex input
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Show Log functionality not implemented yet.'))
                          );
                        },
                        style: ElevatedButton.styleFrom( // Apply standard ElevatedButton style
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          textStyle: AppTheme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                          // Use default ElevatedButton colors from the theme
                        ),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Show log'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- End Filter ---

          const SizedBox(height: 24), // Padding after the filter card
        ],
      ),
    );
  }

  Widget _buildRequestSummaryTab() {
    // Build the request summary layout exactly as in the provided image
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visited response codes section
          _buildSectionHeader(context, 'Visited response codes'),
          _buildStatRow(context, 'HTTP 200', '10'),
          _buildStatRow(context, 'HTTP 301', '4'),
          const Divider(), // Add divider after section

          // Page views section
          _buildSectionHeader(context, 'Page views'),
          _buildStatRow(context, 'HTML pages', '10'),
          _buildStatRow(context, 'Images*', '0'),
          _buildStatRow(context, 'Resources (images are not included)', '4'),
          _buildStatRow(context, 'Without content type', '0'),
          const Divider(),
          _buildTotalRow(context, 'Total (billed requests)', '14'),
          _buildIndentedStatRow(context, 'Prerendered pages', '0'),
          _buildIndentedStatRow(context, 'Non-prerendered pages', '14'),
          const Divider(), // Add divider after section

          // Pages not processed section
          _buildSectionHeader(context, 'Pages not processed'),
          _buildStatRow(context, 'Redirection received, but redirections are not processed', '4'),
          _buildStatRow(context, 'URL points to a resource, but resource collection is disabled', '44'),
          const Divider(),
          _buildTotalRow(context, 'Total', '48'),
          const Divider(), // Add divider after section

          // Other statistics section
          _buildSectionHeader(context, 'Other statistics'),
          _buildStatRow(context, 'Words added', '0'),
          _buildStatRow(context, 'Pages skipped for any reason (not billed)', '0'),
          _buildHighlightedStatRow(context, 'Pages which translated', '10'),
          _buildHighlightedStatRow(context, 'Pages with added source entries', '10'),
          _buildHighlightedStatRow(context, 'Requests sent by reduce worker', '57'),
          _buildHighlightedStatRow(context, 'Preflight requests', '0'),
          _buildStatRow(context, 'Non-billable requests', '57'),
          const Divider(),
          _buildTotalRow(context, 'Total request count (not all billable)', '71'),

          // Image note at the bottom
          const SizedBox(height: 16),
          Text(
            '*Scanning images in order to add them to the Resources won\'t count as a Page view, only the content-type will be checked. However, when you build a Source cache, the image will be downloaded, counted as a page view.',
            style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24), // Add some padding at the end
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSettingsItem(String text, {int indent = 0, bool isSubheader = false}) {
    return Padding(
      padding: EdgeInsets.only(left: indent * 16.0, bottom: 4),
      child: Text(
        text,
        style: isSubheader
          ? AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
          : AppTheme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: Row(
         children: [
           Text('$label: ', style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
           Text(value, style: AppTheme.textTheme.bodyMedium),
         ],
       ),
     );
  }

  Widget _buildLogLink(Map<String, String> log) {
    // Placeholder for log download link
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text('Log - ${log['date']}'),
      subtitle: Text('Size: ${log['size']}'),
      trailing: const Icon(Icons.download_outlined),
      onTap: () { /* Handle log download */ },
    );
  }

  // New helper for Filter Chip Groups
  Widget _buildFilterChipGroup(
    BuildContext context,
    String title,
    Map<String, bool> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Title
        Text(
          title,
          style: AppTheme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        // Simplified Helper Text
        Text(
          _getHelperTextForFilter(title), // Get helper text based on title
          style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8), // Space before chips
        // Filter Chips
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: options.keys.map((option) {
            return FilterChip(
              label: Text(option),
              labelStyle: AppTheme.textTheme.bodySmall?.copyWith(
                color: options[option]! 
                  ? AppTheme.colorScheme.primary 
                  : AppTheme.colorScheme.onSurfaceVariant,
              ),
              selected: options[option]!,
              onSelected: (bool selected) {
                setState(() {
                  options[option] = selected;
                });
              },
              selectedColor: AppTheme.colorScheme.primaryContainer.withOpacity(0.3),
              checkmarkColor: AppTheme.colorScheme.primary,
              showCheckmark: true,
              backgroundColor: AppTheme.colorScheme.surfaceVariant.withOpacity(0.3),
              side: BorderSide(
                color: options[option]! 
                  ? AppTheme.colorScheme.primary.withOpacity(0.5)
                  : AppTheme.colorScheme.outlineVariant,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Helper function to get the correct helper text based on the filter title
  String _getHelperTextForFilter(String title) {
    switch (title) {
      case 'Crawl status':
        return 'Filter by page processing outcome';
      case 'Response type':
        return 'Filter by content type';
      case 'Response code':
        return 'Filter by HTTP status codes';
      case 'Warning type':
        return 'Filter by warning categories';
      default:
        return ''; // Should not happen
    }
  }

  // Helper to build a standard statistics row
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          Expanded(
            child: Text(label, style: AppTheme.textTheme.bodyMedium, softWrap: true),
          ),
          const SizedBox(width: 16), // Consistent spacing
          Text(value, style: AppTheme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // Helper to build an indented statistics row
  Widget _buildIndentedStatRow(BuildContext context, String label, String value) {
    return Padding(
      // Add left padding only
      padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: AppTheme.textTheme.bodyMedium, softWrap: true),
          ),
          const SizedBox(width: 16),
          Text(value, style: AppTheme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // Helper to build a highlighted statistics row
  Widget _buildHighlightedStatRow(BuildContext context, String label, String value) {
    return Container( // Use Container for background color
      color: const Color(0xFFE8E0F8), // Use the exact purple color from the image
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0), // Padding inside highlight
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: AppTheme.textTheme.bodyMedium, softWrap: true),
          ),
          const SizedBox(width: 16),
          Text(value, style: AppTheme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // Helper for section headers (adjust styling as needed)
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        // Use bold style like in the image
        style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper for total rows (adjust styling as needed)
  Widget _buildTotalRow(BuildContext context, String label, String value, {bool boldLabel = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              // Total label is not bold in the image
              style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
              softWrap: true,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            // Total value is not bold in the image
            style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  // Helper function to add regex filter
  void _addRegexFilter() {
    final text = _regexController.text.trim();
    if (text.isNotEmpty && !_regexFilters.contains(text)) {
      setState(() {
        _regexFilters.add(text);
        _regexController.clear();
      });
    }
  }
} 