import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'crawl_model.dart';

class CrawlDetailsModal extends StatefulWidget {
  final CrawlItem crawlItem;

  const CrawlDetailsModal({
    super.key,
    required this.crawlItem,
  });

  @override
  State<CrawlDetailsModal> createState() => _CrawlDetailsModalState();
}

class _CrawlDetailsModalState extends State<CrawlDetailsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Discovery crawl - April 30, 2025',
                    style: AppTheme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              tabs: const [
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
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return AppTheme.colorScheme.primary.withOpacity(0.08);
                  }
                  if (states.contains(MaterialState.pressed)) {
                    return AppTheme.colorScheme.primary.withOpacity(0.12);
                  }
                  return null;
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCrawlSettingsTab(),
                  _buildLogsTab(),
                  _buildRequestSummaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrawlSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSectionTitle('Crawl settings'),
          const SizedBox(height: 16),
          
          _buildTabSectionTitle('Crawl type'),
          const SizedBox(height: 8),
          _buildSettingsItem('Discovery crawl'),
          
          const Divider(height: 32),
          
          _buildTabSectionTitle('Scope'),
          const SizedBox(height: 8),
          _buildSettingsItem('Crawl entire website'),
          _buildSettingsItem('Page limit: 100'),
          
          const Divider(height: 32),
          
          _buildTabSectionTitle('Restrictions'),
          const SizedBox(height: 8),
          _buildSettingsItem('Existing project restrictions'),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Crawl pages starting with:', isSubheader: true),
          _buildSettingsItem('/blog*', indent: 1),
          _buildSettingsItem('/news*', indent: 1),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Don\'t crawl pages starting with:', isSubheader: true),
          _buildSettingsItem('/de_de*', indent: 1),
          _buildSettingsItem('/about*', indent: 1),
          _buildSettingsItem('/contact*', indent: 1),
          
          const SizedBox(height: 16),
          _buildSettingsItem('Temporary restrictions for this crawl:', isSubheader: true),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Crawl pages starting with:', isSubheader: true, indent: 1),
          _buildSettingsItem('/product*', indent: 2),
          _buildSettingsItem('/category*', indent: 2),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Don\'t crawl pages starting with:', isSubheader: true, indent: 1),
          _buildSettingsItem('/admin*', indent: 2),
          _buildSettingsItem('/login*', indent: 2),
          
          const Divider(height: 32),
          
          _buildTabSectionTitle('Fine-tune'),
          const SizedBox(height: 8),
          _buildSettingsItem('Resources to collect:', isSubheader: true),
          _buildSettingsItem('HTML pages', indent: 1),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Collection of non-standard pages:', isSubheader: true),
          _buildSettingsItem('Error pages', indent: 1),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Tweaks:', isSubheader: true),
          _buildSettingsItem('Skip content-type check', indent: 1),
          _buildSettingsItem('Do not reload existing resources', indent: 1),
          
          const SizedBox(height: 12),
          _buildSettingsItem('Simultaneous requests: 8'),
          
          const Divider(height: 32),
          
          _buildTabSectionTitle('Recurrence'),
          const SizedBox(height: 8),
          _buildSettingsItem('No recurring crawls scheduled'),
          
          const Divider(height: 32),
          
          _buildTabSectionTitle('Snapshot'),
          const SizedBox(height: 8),
          _buildSettingsItem('Reuse existing pages and store new pages'),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    // Mock data for log downloads from different dates
    final logDates = [
      {'date': 'April 30, 2023', 'size': '2.4 MB'},
      {'date': 'April 29, 2023', 'size': '1.8 MB'},
      {'date': 'April 28, 2023', 'size': '3.2 MB'},
      {'date': 'April 27, 2023', 'size': '1.5 MB'},
      {'date': 'April 26, 2023', 'size': '2.1 MB'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for the logs tab
          _buildTabSectionTitle('Crawl logs'),
          const SizedBox(height: 16),

          // Log Analysis Summary section
          _buildTabSectionTitle('Log analysis summary'),
          const SizedBox(height: 8),
          _buildInfoRow('Pages analysed', '14'),
          _buildInfoRow('Pages found with parameter', '0'),
          _buildInfoRow('Pages skipped', '2'),
          _buildInfoRow('Errors encountered', '3'),
          
          const Divider(height: 32),
          
          // Available Logs section
          _buildTabSectionTitle('Available logs'),
          const SizedBox(height: 8),
          
          // Simple list of log files
          ...logDates.map((log) => _buildLogLink(log)).toList(),
          
          const Divider(height: 32),
          
          // Visualization Filter section
          _buildTabSectionTitle('Crawl log visualization filter'),
          const SizedBox(height: 8),
          
          // Expandable filters
          _buildExpandableFilterDropdown(
            'Crawl status',
            ['Processed', 'Failed', 'Skipped', 'Other'],
          ),
          
          _buildExpandableFilterDropdown(
            'Response type',
            ['HTML', 'JS', 'JSON', 'XML', 'CSS', 'Image', 'Other'],
          ),
          
          _buildExpandableFilterDropdown(
            'Response code',
            ['200-299', '300-399', '400-499', '500-599'],
          ),
          
          _buildExpandableFilterDropdown(
            'Warning type',
            ['redirectionToSelf', 'resourceUnderEnforcedPath', 'Other'],
          ),
          
          const SizedBox(height: 16),
          
          // Text filter and Show log button
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Optional regex filter',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: AppTheme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Reset filters'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open log in new tab (would use url_launcher in a real app)
                      // In this prototype we'll just show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening log in new tab'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Show log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorScheme.primary,
                      foregroundColor: AppTheme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSectionTitle('Request summary'),
          const SizedBox(height: 16),
          
          _buildTableSection('Visited response codes', [
            ['HTTP 200', '10'],
            ['HTTP 301', '4'],
          ]),
          
          const SizedBox(height: 24),
          _buildTableSection('Page views', [
            ['HTML pages', '10'],
            ['Images*', '0'],
            ['Resources (images are not included)', '4'],
            ['Without content type', '0'],
            ['Total (billed requests)', '14', true],
            ['   Prerendered pages', '0'],
            ['   Non-prerendered pages', '14'],
          ]),
          
          const SizedBox(height: 24),
          _buildTableSection('Pages not processed', [
            ['Redirection received, but redirections are not processed', '4'],
            ['URL points to a resource, but resource collection is disabled', '44'],
            ['Total', '48', true],
          ]),
          
          const SizedBox(height: 24),
          _buildTableSection('Other statistics', [
            ['Words added', '0'],
            ['Pages skipped for any reason (not billed)', '0'],
            ['Pages which translated', '10', false, true],
            ['Pages with added source entries', '10', false, true],
            ['Requests sent by reduce worker', '57', false, true],
            ['Preflight requests', '0', false, true],
            ['Non-billable requests', '57'],
            ['Total request count (not all billable)', '71', true],
          ]),
          
          const SizedBox(height: 24),
          Text(
            '*Scanning images in order to add them to the Resources won\'t count as a Page view, only the content-type will be checked. However, when you build a Source cache, the image will be downloaded, counted as a page view.',
            style: AppTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection(String title, List<List<dynamic>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionHeader(title),
        ...rows.map((row) {
          bool isBold = row.length > 2 && row[2] != null ? row[2] as bool : false;
          bool isAdminOnly = row.length > 3 && row[3] != null ? row[3] as bool : false;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: isAdminOnly 
                ? BoxDecoration(
                    color: AppTheme.colorScheme.tertiaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Stack(
              children: [
                // Label text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 52),
                  child: Text(
                    row[0].toString(),
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                      color: isAdminOnly
                          ? AppTheme.colorScheme.tertiary
                          : AppTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // Value text - positioned at the right
                Positioned(
                  right: 0,
                  child: Container(
                    width: 45,
                    alignment: Alignment.centerRight,
                    child: Text(
                      row[1].toString(),
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                        color: isAdminOnly
                            ? AppTheme.colorScheme.tertiary
                            : AppTheme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTabSectionTitle(String title) {
    return Text(
      title, 
      style: AppTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubsectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title, 
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String text, {bool isSubheader = false, int indent = 0}) {
    double leftPadding = indent * 16.0;
    
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 6),
      child: Text(
        text,
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSubheader ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildExpandableFilterDropdown(String label, List<String> options) {
    return ExpansionTile(
      title: Text(
        label,
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: null,
      childrenPadding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.centerLeft,
      children: [
        Column(
          children: options.map((option) {
            return CheckboxListTile(
              title: Text(
                option,
                style: AppTheme.textTheme.bodySmall,
              ),
              value: false,
              onChanged: (value) {},
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogLink(Map<String, String> log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined, 
            size: 16, 
            color: AppTheme.colorScheme.primary
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${log['date']} log file (${log['size']})',
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getStatusText(CrawlStatus status) {
    switch (status) {
      case CrawlStatus.completed:
        return 'Completed';
      case CrawlStatus.inProgress:
        return 'In progress';
      case CrawlStatus.scheduled:
        return 'Scheduled';
      case CrawlStatus.failed:
        return 'Failed';
      case CrawlStatus.canceled:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }
} 