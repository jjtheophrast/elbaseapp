import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/button_styles.dart';
import 'crawl_model.dart';
import 'crawl_details_modal.dart';
import 'statistics_dialog.dart';

class CrawlHistoryPage extends StatelessWidget {
  const CrawlHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left sidebar with blue background (match exact width and style)
          Container(
            width: 240,
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
                // Side menu items - exactly as in screenshot
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
                // Page title header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Crawl history',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: AppTheme.colorScheme.outlineVariant),
                // Main content body - scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CrawlHistoryContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
}

class CrawlHistoryContent extends StatelessWidget {
  const CrawlHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final crawlItems = getMockCrawlItems();
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with action button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Use AppButtonStyles directly
            ElevatedButton(
              onPressed: () {
                // Handle start new crawl action
              },
              style: AppButtonStyles.primaryFilledButton,
              child: AppButtonStyles.buttonWithIcon(
                text: 'Start new crawl',
                icon: Icons.add,
                iconLeading: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Table content
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppTheme.colorScheme.outlineVariant, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: isDesktop
            ? _buildDesktopTable(context, crawlItems)
            : _buildMobileList(context, crawlItems),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<CrawlItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Type',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Status',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Termination reason',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Started',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Word count',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Visited pages',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Recurrence',
                  style: AppTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: 40), // Space for actions
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: AppTheme.colorScheme.outlineVariant),
        // Content rows - no scroll container anymore
        Column(
          children: items.map((item) {
            return Column(
              children: [
                _buildCrawlItemRow(context, item),
                if (item != items.last)
                  Divider(
                    height: 1, 
                    thickness: 1, 
                    color: AppTheme.colorScheme.outlineVariant,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCrawlItemRow(BuildContext context, CrawlItem item) {
    final showStats = item.status == CrawlStatus.completed || item.status == CrawlStatus.failed;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item.type,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: _buildStatusIndicator(context, item.status),
              ),
              Expanded(
                flex: 2,
                child: _buildTerminationReason(context, item),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  item.startDate,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      item.wordCount.toString(),
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.colorScheme.onSurface,
                      ),
                    ),
                    if (showStats) 
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: () => _viewStatistics(context, item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 14,
                                  color: AppTheme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stats',
                                  style: AppTheme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  item.visitedPages.toString(),
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  item.recurrence,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: _buildPopupMenu(context, item),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTerminationReason(BuildContext context, CrawlItem item) {
    if (item.terminationReason == null) {
      return const Text('-');
    }
    
    return Text(
      item.terminationReason!,
      style: AppTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.colorScheme.onSurface,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMobileList(BuildContext context, List<CrawlItem> items) {
    // No scroll container anymore
    return Column(
      children: items.map((item) {
        return Column(
          children: [
            _buildMobileCrawlItem(context, item),
            if (item != items.last)
              Divider(
                height: 1,
                thickness: 1,
                color: AppTheme.colorScheme.outlineVariant,
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMobileCrawlItem(BuildContext context, CrawlItem item) {
    final showStats = item.status == CrawlStatus.completed || item.status == CrawlStatus.failed;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.type,
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.colorScheme.onSurface,
                ),
              ),
              _buildPopupMenu(context, item),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusIndicator(context, item.status),
          
          // Termination reason 
          if (item.terminationReason != null) ...[
            const SizedBox(height: 8),
            _buildMobileTerminationReason(context, item),
          ],
          
          const SizedBox(height: 12),
          _buildMobileInfoRow(context, 'Started:', item.startDate),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Word count:',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.wordCount.toString(),
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colorScheme.onSurface,
                ),
              ),
              if (showStats) 
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: InkWell(
                    onTap: () => _viewStatistics(context, item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 16,
                            color: AppTheme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View Statistics',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          _buildMobileInfoRow(context, 'Visited pages:', item.visitedPages.toString()),
          _buildMobileInfoRow(context, 'Recurrence:', item.recurrence),
        ],
      ),
    );
  }

  Widget _buildMobileTerminationReason(BuildContext context, CrawlItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        item.terminationReason!,
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.colorScheme.onSurface,
        ),
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
        label = 'In progress';
        color = Colors.blue;
        icon = Icons.sync;
        break;
      case CrawlStatus.scheduled:
        label = 'Scheduled';
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case CrawlStatus.failed:
        label = 'Failed';
        color = Colors.red;
        icon = Icons.error;
        break;
      case CrawlStatus.canceled:
        label = 'Canceled';
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      case CrawlStatus.canceledSchedule:
        label = 'Canceled schedule';
        color = Colors.grey;
        icon = Icons.event_busy;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context, CrawlItem item) {
    final actionsEnabled = item.status != CrawlStatus.running && item.status != CrawlStatus.inProgress;
    final showStats = item.status == CrawlStatus.completed || item.status == CrawlStatus.failed;
    
    return PopupMenuButton<String>(
      splashRadius: 20,
      icon: Icon(
        Icons.more_vert,
        color: AppTheme.colorScheme.onSurface.withOpacity(0.6),
      ),
      onSelected: (value) {
        if (value == 'details') {
          _viewCrawlDetails(context, item);
        } else if (value == 'rerun') {
          _rerunWithSameSettings(context, item);
        } else if (value == 'cancel') {
          _cancelCrawl(context, item);
        } else if (value == 'stats') {
          _viewStatistics(context, item);
        }
      },
      itemBuilder: (context) => [
        // Statistics - show for completed or failed crawls
        if (showStats)
          PopupMenuItem<String>(
            value: 'stats',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.analytics_outlined, color: AppTheme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text('View statistics', style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colorScheme.primary,
                )),
              ],
            ),
          ),
        // Crawl details - always show
        PopupMenuItem<String>(
          value: 'details',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.article_outlined, color: AppTheme.colorScheme.onSurface.withOpacity(0.6), size: 18),
              const SizedBox(width: 8),
              Text('Crawl settings & logs', style: AppTheme.textTheme.bodyMedium),
            ],
          ),
        ),
        // Rerun with same settings - always show but disable if running
        PopupMenuItem<String>(
          value: 'rerun',
          enabled: item.status != CrawlStatus.running && item.status != CrawlStatus.inProgress,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh, 
                color: item.status != CrawlStatus.running && item.status != CrawlStatus.inProgress
                    ? AppTheme.colorScheme.onSurface.withOpacity(0.6)
                    : AppTheme.colorScheme.onSurface.withOpacity(0.3), 
                size: 18
              ),
              const SizedBox(width: 8),
              Text(
                'Rerun with same settings', 
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: item.status != CrawlStatus.running && item.status != CrawlStatus.inProgress
                      ? AppTheme.colorScheme.onSurface
                      : AppTheme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        // Cancel - always show but disable if not running
        PopupMenuItem<String>(
          value: 'cancel',
          enabled: item.status == CrawlStatus.running || item.status == CrawlStatus.inProgress,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel_outlined, 
                color: item.status == CrawlStatus.running || item.status == CrawlStatus.inProgress
                    ? AppTheme.colorScheme.error
                    : AppTheme.colorScheme.error.withOpacity(0.3), 
                size: 18
              ),
              const SizedBox(width: 8),
              Text(
                'Cancel crawl',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: item.status == CrawlStatus.running || item.status == CrawlStatus.inProgress
                      ? AppTheme.colorScheme.error
                      : AppTheme.colorScheme.error.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _viewCrawlDetails(BuildContext context, CrawlItem item) {
    // Show the crawl details modal
    showDialog(
      context: context,
      builder: (context) => CrawlDetailsModal(crawlItem: item),
    );
  }

  void _rerunWithSameSettings(BuildContext context, CrawlItem item) {
    // Show confirmation dialog
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
              // Add logic to rerun the crawl
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Crawl has been restarted',
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
          TextButton(
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
              color: AppTheme.colorScheme.error,
            )),
          ),
        ],
      ),
    );
  }

  void _viewStatistics(BuildContext context, CrawlItem item) {
    showDialog(
      context: context,
      builder: (context) => StatisticsDialog(crawlItem: item),
    );
  }
} 