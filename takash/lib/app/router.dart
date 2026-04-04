import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/providers.dart';

// Screens — Placeholder'lar
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/listings/presentation/home_screen.dart';
import '../features/listings/presentation/create_listing_screen.dart';
import '../features/listings/presentation/edit_listing_screen.dart';
import '../features/listings/presentation/listing_detail_screen.dart';
import '../features/listings/presentation/my_listings_screen.dart';
import '../features/listings/presentation/favorites_screen.dart';
import '../features/chat/presentation/chat_list_screen.dart';
import '../features/chat/presentation/chat_detail_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/notifications/presentation/notification_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/public_profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';

/// Router Provider — GoRouter ile 5 tab'lı navigation
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!onboardingCompleted) return '/onboarding';
      if (onboardingCompleted && isOnboarding) return '/login';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Public Profile Route
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PublicProfileScreen(userId: id);
        },
      ),

      // Edit Profile Route (Full Screen)
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Bildirimler Route
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // Favoriler Route
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),

      // Ayarlar Route
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Ana Uygulama (Tab Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Keşfet Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'listing/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ListingDetailScreen(listingId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Harita Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          // İlan Ver Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create-listing',
                builder: (context, state) => const CreateListingScreen(),
              ),
            ],
          ),
          // Sohbetler Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ChatDetailScreen(chatId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Profil Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'my-listings',
                    builder: (context, state) => const MyListingsScreen(),
                  ),
                  GoRoute(
                    path: 'favorites',
                    builder: (context, state) => const FavoritesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Edit Listing Route (Full Screen)
      GoRoute(
        path: '/edit-listing/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditListingScreen(listingId: id);
        },
      ),
    ],
  );
});

/// Ana ekran — 5 tab'lı bottom navigation bar
class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'İlan Ver',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Sohbetler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
