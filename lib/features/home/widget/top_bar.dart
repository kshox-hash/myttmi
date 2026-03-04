import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String playerName;
  final String playerRanking;

  final VoidCallback onMessages;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  final int messagesCount;
  final int notificationsCount;

  const TopBar({
    super.key,
    required this.playerName,
    required this.playerRanking,
    required this.onMessages,
    required this.onNotifications,
    required this.onSettings,
    this.messagesCount = 0,
    this.notificationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFB388FF),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  playerRanking,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _BadgeIconButton(
            icon: Icons.chat_bubble_outline,
            count: messagesCount,
            onTap: onMessages,
          ),
          const SizedBox(width: 8),
          _BadgeIconButton(
            icon: Icons.notifications_none_outlined,
            count: notificationsCount,
            onTap: onNotifications,
          ),
          const SizedBox(width: 8),
          _TopIconButton(icon: Icons.settings_outlined, onTap: onSettings),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white.withOpacity(0.95)),
        ),
      ),
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _BadgeIconButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _TopIconButton(icon: icon, onTap: onTap),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFF2D2D),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                count > 9 ? "9+" : "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
