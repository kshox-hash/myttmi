import "package:flutter/material.dart";
import "package:myttmi/core/constants/app_colors.dart";
import "package:myttmi/features/calendar/api/calendar_api.dart";
import "package:myttmi/features/calendar/models/calendar_event.dart";

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDay = DateTime.now();

  final CalendarApi _api = CalendarApi();

  bool _loading = false;
  String? _error;

  // ✅ ahora se llena desde backend
  final Map<DateTime, List<_CalendarItem>> _itemsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadMonth(_focusedMonth);
  }

  Future<void> _loadMonth(DateTime month) async {
    setState(() {
      _loading = true;
      _error = null;
      _itemsByDay.clear();
    });

    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    try {
      final events = await _api.myEvents(from: first, to: last);

      for (final e in events) {
        final key = _dayKey(e.date);
        _itemsByDay.putIfAbsent(key, () => []);
        _itemsByDay[key]!.add(_CalendarItem.fromEvent(e));
      }

      setState(() {});
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = _monthLabel(_focusedMonth);
    final dayItems = _itemsByDay[_dayKey(_selectedDay)] ?? const [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary, AppColors.deep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // TOP BAR
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Calendario",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _GlassIconButton(
                      icon: Icons.refresh_rounded,
                      onTap: () => _loadMonth(_focusedMonth),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // HEADER MES + controles
                _GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              monthLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _MiniButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: () {
                              setState(() {
                                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                                _selectedDay = _clampSelectedToMonth(_selectedDay, _focusedMonth);
                              });
                              _loadMonth(_focusedMonth);
                            },
                          ),
                          const SizedBox(width: 8),
                          _MiniButton(
                            icon: Icons.today_rounded,
                            onTap: () {
                              final now = DateTime.now();
                              setState(() {
                                _focusedMonth = DateTime(now.year, now.month, 1);
                                _selectedDay = now;
                              });
                              _loadMonth(_focusedMonth);
                            },
                          ),
                          const SizedBox(width: 8),
                          _MiniButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: () {
                              setState(() {
                                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                                _selectedDay = _clampSelectedToMonth(_selectedDay, _focusedMonth);
                              });
                              _loadMonth(_focusedMonth);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: const [
                          _WeekLabel("L"),
                          _WeekLabel("M"),
                          _WeekLabel("M"),
                          _WeekLabel("J"),
                          _WeekLabel("V"),
                          _WeekLabel("S"),
                          _WeekLabel("D"),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _CalendarMonthGrid(
                        month: _focusedMonth,
                        selectedDay: _selectedDay,
                        hasItems: (d) => (_itemsByDay[_dayKey(d)]?.isNotEmpty ?? false),
                        onSelectDay: (d) => setState(() => _selectedDay = d),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Agenda • ${_dayTitle(_selectedDay)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Text(
                              _loading ? "..." : "${dayItems.length} item(s)",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_error != null)
                        _GlassCard(
                          child: Text(
                            "Error:\n$_error",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800),
                          ),
                        )
                      else if (_loading)
                        const _GlassCard(
                          child: Center(child: Padding(
                            padding: EdgeInsets.all(18),
                            child: CircularProgressIndicator(),
                          )),
                        )
                      else if (dayItems.isEmpty)
                        _GlassCard(
                          child: Column(
                            children: [
                              Icon(Icons.event_available_rounded, color: Colors.white.withOpacity(0.85), size: 26),
                              const SizedBox(height: 10),
                              Text(
                                "No tienes campeonatos este día.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...dayItems.map((e) => _AgendaCard(item: e)).toList(),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  String _monthLabel(DateTime d) {
    const months = [
      "Enero","Febrero","Marzo","Abril","Mayo","Junio",
      "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"
    ];
    return "${months[d.month - 1]} ${d.year}";
  }

  String _dayTitle(DateTime d) {
    const wd = ["Lun","Mar","Mié","Jue","Vie","Sáb","Dom"];
    final w = wd[(d.weekday - 1).clamp(0, 6)];
    return "$w ${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}";
  }

  DateTime _clampSelectedToMonth(DateTime selected, DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    if (selected.isBefore(first)) return first;
    if (selected.isAfter(last)) return last;
    return selected;
  }
}

/* ------------------------------ MODELO UI ------------------------------ */

enum _CalendarItemType { tournament }

class _CalendarItem {
  final _CalendarItemType type;
  final String title;
  final String subtitle;
  final String meta;

  const _CalendarItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  factory _CalendarItem.fromEvent(CalendarEvent e) {
    String genderLabel(String g) {
      switch (g) {
        case "male":
          return "Masculino";
        case "female":
          return "Femenino";
        case "mixed":
          return "Mixto";
        default:
          return g;
      }
    }

    final loc = (e.location ?? "").trim();
    return _CalendarItem(
      type: _CalendarItemType.tournament,
      title: "🏆 ${e.tournamentName}",
      subtitle: "Categoría: ${e.categoryName} • ${genderLabel(e.gender)}",
      meta: loc.isEmpty ? "Inscrito" : "📍 $loc",
    );
  }
}

/* ------------------------------ GRID MES ------------------------------ */

class _CalendarMonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final bool Function(DateTime day) hasItems;
  final ValueChanged<DateTime> onSelectDay;

  const _CalendarMonthGrid({
    required this.month,
    required this.selectedDay,
    required this.hasItems,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final leadingEmpty = (firstOfMonth.weekday - 1) % 7;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final cellCount = rows * 7;

    return Column(
      children: List.generate(rows, (r) {
        return Row(
          children: List.generate(7, (c) {
            final index = r * 7 + c;
            final dayNum = index - leadingEmpty + 1;

            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 44));
            }

            final date = DateTime(month.year, month.month, dayNum);
            final isSelected = _sameDay(date, selectedDay);
            final isToday = _sameDay(date, DateTime.now());
            final dot = hasItems(date);

            return Expanded(
              child: _DayCell(
                day: dayNum,
                isSelected: isSelected,
                isToday: isToday,
                hasItems: dot,
                onTap: () => onSelectDay(date),
              ),
            );
          }),
        );
      }),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final bool hasItems;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.accent.withOpacity(0.18) : Colors.white.withOpacity(0.06);
    final border = isSelected ? AppColors.accent.withOpacity(0.40) : Colors.white.withOpacity(0.10);
    final textColor = isSelected ? Colors.white : Colors.white.withOpacity(0.92);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  "$day",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                if (isToday)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                if (hasItems)
                  Positioned(
                    bottom: 8,
                    child: Container(
                      width: 18,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  final String t;
  const _WeekLabel(this.t);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          t,
          style: TextStyle(
            color: Colors.white.withOpacity(0.70),
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ UI ------------------------------ */

class _AgendaCard extends StatelessWidget {
  final _CalendarItem item;
  const _AgendaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withOpacity(0.28)),
              ),
              child: Icon(Icons.emoji_events_outlined, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.60)),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 40, height: 40, child: Icon(icon, color: Colors.white.withOpacity(0.95))),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: Colors.white.withOpacity(0.95))),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}
