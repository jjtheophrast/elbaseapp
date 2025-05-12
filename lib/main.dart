import 'package:elbaseapp/presentation/crawl_history/crawl_history_page.dart';
import 'package:elbaseapp/presentation/crawl_history/crawl_model.dart'; // Needed for CrawlItem argument
import 'package:elbaseapp/presentation/language_table/language_table_page.dart';
import 'package:elbaseapp/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the new details page
import 'package:elbaseapp/presentation/crawl_details/crawl_details_page.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load NotoSans font
  GoogleFonts.notoSans();
  await AppTheme.initialize();
  runApp(
    // Wrap the root widget with ProviderScope
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easyling Crawl Wizard',
      theme: AppTheme.lightTheme,
      // Remove initialRoute if /crawl-history is the only main page
      // initialRoute: '/crawl-history',
      home: const CrawlHistoryPage(), // Set home directly
      routes: {
        // Keep named routes if needed for other navigation, 
        // but remove /crawl-details if panel replaces it.
        // '/crawl-history': (context) => const CrawlHistoryPage(), // Redundant if home is set
        '/languages': (context) => const LanguageTablePage(),
      },
      // Remove onGenerateRoute if CrawlDetailsPage is no longer used
      // onGenerateRoute: (settings) {
      //   // ... existing logic ...
      // },
      debugShowCheckedModeBanner: false,
    );
  }
}

// HomeScreen can likely be removed if /crawl-details was its only purpose
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easyling base app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Easyling Base app',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/crawl-history');
              },
              child: const Text('Go to Crawl History'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/languages');
              },
              child: const Text('Go to Languages'),
            ),
          ],
        ), 
      ),
    );
  }
}

