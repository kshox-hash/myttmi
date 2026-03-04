import "package:flutter/material.dart";

import "package:myttmi/features/home/presentation/home_screen.dart";
import "package:myttmi/features/profile/presentation/profile_screen.dart";
import "package:myttmi/features/ranking/presentation/ranking_screen.dart";
import "package:myttmi/features/calendar/presentation/calendar_screen.dart";
import "package:myttmi/features/stats/presentation/stats_screen.dart";

import "package:myttmi/features/tournament/presentation/tournaments_screen.dart";
import "package:myttmi/features/tournament/presentation/tournament_create_screen.dart";
import "package:myttmi/features/tournament/presentation/tournament_detail_screen.dart";

import "package:myttmi/features/shell/splash_gate.dart";
import "package:myttmi/features/auth/presentation/login_screen.dart";

import "package:myttmi/features/competition/presentation/admin_generate_groups_screen.dart";
import "package:myttmi/features/competition/presentation/groups_view_screen.dart";

import "package:myttmi/features/tournament/presentation/admin_tournaments_screen.dart";
import "package:myttmi/features/tournament/presentation/admin_tournament_detail_screen.dart";

import "package:myttmi/features/tournament/models/tournament_models.dart";

class AppRoutes {
  static const splash = "/splash";
  static const login = "/login";

  static const home = "/home";
  static const calendar = "/calendar";
  static const ranking = "/ranking";
  static const stats = "/stats";
  static const profile = "/profile";

  // tournaments routes
  static const tournaments = "/tournaments";
  static const tournamentDetail = "/tournament/detail"; // ✅ AGREGADO (faltaba)

  static const adminTournaments = "/admin/tournaments";
  static const adminTournamentDetail = "/admin/tournament/detail";

  static const createTournament = "/admin/tournament/create"; // ✅ con "/" al inicio

  // competition routes
  static const adminGenerateGroups = "/competition/admin-generate-groups";
  static const groupsView = "/competition/groups-view";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashGate());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());

      case ranking:
        return MaterialPageRoute(builder: (_) => const RankingScreen());

      case stats:
        return MaterialPageRoute(builder: (_) => const StatsScreen());

      case tournaments:
        return MaterialPageRoute(builder: (_) => const TournamentsScreen());

      case tournamentDetail: {
        final t = settings.arguments as Tournament;
        return MaterialPageRoute(
          builder: (_) => TournamentDetailScreen(tournament: t),
        );
      }

      case adminTournaments:
        return MaterialPageRoute(builder: (_) => const AdminTournamentsScreen());

      case adminTournamentDetail: {
        final t = settings.arguments as Tournament;
        return MaterialPageRoute(
          builder: (_) => TournamentAdminDetailScreen(tournament: t),
        );
      }

      case createTournament:
        return MaterialPageRoute(builder: (_) => const TournamentCreateScreen());

      // ADMIN GENERAR GRUPOS
      case adminGenerateGroups: {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AdminGenerateGroupsScreen(
            tournamentId: args["tournamentId"],
            categoryId: args["categoryId"],
            adminId: args["adminId"],
          ),
        );
      }

      // VER GRUPOS
      case groupsView: {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GroupsViewScreen(
            tournamentId: args["tournamentId"],
            categoryId: args["categoryId"],
          ),
        );
      }

      default:
        return MaterialPageRoute(
          builder: (_) =>
              _PlaceholderScreen(title: "Ruta no encontrada: ${settings.name}"),
        );
    }
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}