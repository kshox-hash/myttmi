import 'package:flutter/material.dart';

import 'package:myttmi/core/constants/app_colors.dart';
import 'package:myttmi/core/storage/session_storage.dart';
import 'package:myttmi/core/ui/prism_background.dart';
import 'package:myttmi/features/shell/splash_gate.dart';

import '../../../routes/app_routes.dart';
import '../../data/audio_service.dart';
import '../../domain/song.dart';

import '../widget/top_bar.dart';
import '../widget/next_match_card.dart';
import '../widget/swipe_cards_banner.dart';
import '../widget/ef_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _cardController;
  final AudioService _audio = AudioService();

  final List<String> _cards = const [
    "assets/images/background.png",
    "assets/images/background1.png",
    "assets/images/background2.png",
    "assets/images/background3.png",
  ];

  final List<Song> _playlist = const [
    Song(title: "ali madisson - carnaval", assetPath: "audio/carnaval.mp3"),
    Song(title: "shakira - soltera", assetPath: "audio/soltera.mp3"),
  ];

  int _currentIndex = 0;
  final ValueNotifier<String> _nowPlayingTitle = ValueNotifier<String>("");
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _cardController = PageController(viewportFraction: 1.0);

    _audio.init(onComplete: _playNext);

    Future.delayed(const Duration(seconds: 1), () async {
      if (_playlist.isNotEmpty) await _playAt(0);
    });
  }

  Future<void> _playAt(int index) async {
    if (_playlist.isEmpty) return;

    _currentIndex = index.clamp(0, _playlist.length - 1);
    final song = _playlist[_currentIndex];

    _nowPlayingTitle.value = song.title;
    await _audio.play(song, volume: 0.5);
  }

  Future<void> _playNext() async {
    if (_playlist.isEmpty) return;
    final next = (_currentIndex + 1) % _playlist.length;
    await _playAt(next);
  }

  @override
  void dispose() {
    _nowPlayingTitle.dispose();
    _cardController.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    setState(() => _navIndex = i);

    switch (i) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.calendar);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.ranking);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.stats);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.tournaments);
        break;
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Cerrar sesión", style: TextStyle(color: AppColors.text)),
        content: Text(
          "¿Quieres cerrar sesión y volver al login?",
          style: TextStyle(color: AppColors.text.withOpacity(0.85)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: AppColors.text.withOpacity(0.85))),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electric.withOpacity(0.18),
              foregroundColor: AppColors.text,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SessionStorage().clearAll();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashGate()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String meta = "jueves 05 febrero • 19:30 • Club Deportivo San Miguel";
    const String tickerText = "mesa 5";

    return Scaffold(
      backgroundColor: AppColors.dark,
      extendBody: true,

      bottomNavigationBar: EFBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        items: const [
          EFNavItem(label: "Calendario", icon: Icons.calendar_month_rounded),
          EFNavItem(label: "Ranking", icon: Icons.emoji_events_rounded),
          EFNavItem(label: "Estadísticas", icon: Icons.bar_chart_rounded),
          EFNavItem(label: "Campeonatos", icon: Icons.sports_tennis_rounded),
        ],
      ),

      // ✅ BACKGROUND EXACTO CONCEPTO (deep blue glow)
      body: PrismBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TopBar(
                  playerName: "Jose Curihual",
                  playerRanking: "Ranking 60",
                  onMessages: () {},
                  onNotifications: () {},
                  onSettings: () async {
                    final action = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: AppColors.surface.withOpacity(0.95),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              ListTile(
                                leading: const Icon(Icons.person_outline, color: AppColors.text),
                                title: const Text("Perfil", style: TextStyle(color: AppColors.text)),
                                onTap: () => Navigator.pop(context, "profile"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout, color: AppColors.text),
                                title: const Text("Cerrar sesión", style: TextStyle(color: AppColors.text)),
                                onTap: () => Navigator.pop(context, "logout"),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        );
                      },
                    );

                    if (!mounted) return;

                    if (action == "profile") {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    } else if (action == "logout") {
                      await _confirmLogout();
                    }
                  },
                  messagesCount: 3,
                  notificationsCount: 8,
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: Column(
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: _nowPlayingTitle,
                        builder: (context, title, _) {
                          final songLine = title.isEmpty ? "🎵 —" : "🎵 $title";

                          return NextMatchCard(
                            title: "Próximo Partido",
                            playerName: "Ignacio Peña",
                            rankingAndPlace: "Ranking(54) - MyTTM Team",
                            meta: meta,
                            tickerText: tickerText,
                            nowPlayingText: songLine,
                            liquidEvery: const Duration(seconds: 3),
                            onTap: () {},
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      Expanded(
                        child: SwipeCardsBanner(
                          controller: _cardController,
                          images: _cards,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
