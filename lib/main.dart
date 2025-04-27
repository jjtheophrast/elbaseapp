import 'package:elbaseapp/presentation/crawl_history/crawl_history_page.dart';
import 'package:elbaseapp/presentation/language_table/language_table_page.dart';
import 'package:elbaseapp/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load NotoSans font
  GoogleFonts.notoSans();
  await AppTheme.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easyling Crawl Wizard',
      theme: AppTheme.lightTheme,
      initialRoute: '/crawl-history',
      routes: {
        '/crawl-history': (context) => const CrawlHistoryPage(),
        '/languages': (context) => const LanguageTablePage(),
        '/crawl-details': (context) => const HomeScreen(), // Placeholder for now
      },
      home: const CrawlHistoryPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

