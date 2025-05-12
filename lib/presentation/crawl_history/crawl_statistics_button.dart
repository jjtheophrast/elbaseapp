import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'crawl_model.dart';
import 'statistics_dialog.dart';

class CrawlStatisticsButton extends StatelessWidget {
  final CrawlItem crawlItem;

  const CrawlStatisticsButton({
    super.key,
    required this.crawlItem,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showStatisticsDialog(context),
      icon: Icon(
        Icons.analytics_outlined,
        size: 16,
        color: AppTheme.colorScheme.primary,
      ),
      label: Text(
        'Statistics',
        style: AppTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.colorScheme.primary,
        ),
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatisticsDialog(crawlItem: crawlItem),
    );
  }
} 