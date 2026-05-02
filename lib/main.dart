import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/DI/dependency_injection.dart';
import 'core/auth/token_storage.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/data/datasources/auth_remote_ds.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DependencyInjection.init();

  runApp(const Xepa());
}

class Xepa extends StatelessWidget {
  const Xepa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xepa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF42A5F5)),
        useMaterial3: true,
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.black87), 
          bodyLarge: TextStyle(color: Colors.black87), 
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: Colors.black54),
          floatingLabelStyle: TextStyle(color: Color(0xFF42A5F5), fontWeight: FontWeight.bold),
          prefixIconColor: Color(0xFF42A5F5),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final tokenStorage = getIt<TokenStorage>();
      final authDataSource = getIt<AuthRemoteDataSource>();
      
      final token = await tokenStorage.getToken();
      
      if (token != null && token.isNotEmpty) {
        final isValid = await authDataSource.verifyToken();
        
        if (isValid) {
          if (mounted) {
            setState(() {
              _isAuthenticated = true;
              _isLoading = false;
            });
          }
          return;
        } else {
          await tokenStorage.clearAll();
        }
      }
      
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF42A5F5)),
        ),
      );
    }
    
    if (_isAuthenticated) {
      return const DashboardScreen();
    }
    
    return const LoginScreen();
  }
}
