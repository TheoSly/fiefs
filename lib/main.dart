import 'package:feffs/core/services/notification_services.dart';
import 'package:feffs/features/auth/domain/movie_viewmodel.dart';
import 'package:feffs/features/auth/domain/theme_viewmodel.dart';
import 'package:feffs/features/auth/domain/ticket_viewmodel.dart';
import 'package:feffs/features/auth/ui/ticket_screen.dart';
import 'package:feffs/features/auth/ui/scanner_screen.dart';
import 'package:feffs/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/domain/auth_viewmodel.dart';
import 'features/auth/ui/home_screen.dart';
import 'features/auth/ui/auth_screen.dart';
import 'core/services/appwrite_services.dart';
import 'features/auth/ui/listaffiche_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFD35446),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, 
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.black), 
      elevation: 0, 
    ),
    colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFFD35446),
          primary: const Color(0xFFD35446),
        ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFFD35446),
      unselectedItemColor: Colors.grey,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFD35446),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFFD35446),
        primary: const Color(0xFFD35446),
     ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFFD35446),
      unselectedItemColor: Colors.grey,
    ),
  );
}

void main() async {
  await dotenv.load();
  AppwriteService.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService().initializeNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..loadCurrentUser()),
        ChangeNotifierProvider(create: (_) => TicketViewModel(AppwriteService.database, AppwriteService.storage)),
        ChangeNotifierProvider(create: (_) => MovieViewModel()..loadMovie()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return MaterialApp(
      title: 'FEFFS',
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode:  themeViewModel.themeMode,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    List<Widget> screens = [];
    if (authViewModel.currentUser != null) {
      screens = [
        HomeScreen(),
        MovieScheduleScreen(),
        ScannerScreen(),
        const TicketScreen(),
        AuthScreen(
          resetNavigationIndex: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
      ];
    } else {
      screens = [
        HomeScreen(),
        MovieScheduleScreen(),
        ScannerScreen(),
        AuthScreen(
          resetNavigationIndex: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
      ];
    }

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home_rounded),
            title: const Text("Accueil"),
            selectedColor: Theme.of(context).primaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.toc_rounded),
            title: const Text("Affiche"),
            selectedColor: Theme.of(context).primaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.qr_code_2_rounded),
            title: const Text("QR"),
            selectedColor: Theme.of(context).primaryColor,
          ),
          if (authViewModel.currentUser != null)
            SalomonBottomBarItem(
              icon: const Icon(Icons.file_copy),
              title: const Text("Ticket"),
              selectedColor: Theme.of(context).primaryColor,
            ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profil"),
            selectedColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
