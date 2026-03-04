import "package:flutter/material.dart";
import "package:myttmi/features/tournament/api/admin_tournament_api.dart";
import "package:myttmi/core/storage/session_storage.dart";

class AdminTournamentCreateScreen extends StatefulWidget {
  const AdminTournamentCreateScreen({super.key});

  @override
  State<AdminTournamentCreateScreen> createState() => _AdminTournamentCreateScreenState();
}

class _AdminTournamentCreateScreenState extends State<AdminTournamentCreateScreen> {
  final _api = AdminTournamentApi();

  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _loc = TextEditingController();

  DateTime _eventDate = DateTime.now();
  TimeOfDay? _eventTime;

  bool _loading = false;

  // ✅ Ciudades grandes
  static const List<String> chileCities = [
    "Santiago",
    "Valparaíso",
    "Viña del Mar",
    "Concepción",
    "Antofagasta",
    "La Serena",
    "Iquique",
    "Arica",
    "Copiapó",
    "Temuco",
    "Valdivia",
    "Osorno",
    "Puerto Montt",
    "Chillán",
    "Punta Arenas",
  ];

  String? _selectedCity;

  // ✅ Tipos de categoría (nombres limpios)
  static const List<String> categoryTypes = [
    "Peneca",
    "Preinfantil",
    "Infantil",
    "Juvenil",
    "U23",
    "Todo Competidor",
    "Master",
  ];

  // ✅ Rangos master (dropdown)
  static const List<String> masterRanges = [
    "35–39",
    "40–44",
    "45–49",
    "50–54",
    "55–59",
    "60–64",
    "65–69",
    "70–74",
    "75+",
    "Personalizado",
  ];

  final List<_CatForm> _cats = [
    _CatForm(gender: "male", price: 5000),
    _CatForm(gender: "female", price: 5000),
    _CatForm(gender: "mixed", price: 6000),
  ];

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _loc.dispose();
    for (final c in _cats) c.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked != null) setState(() => _eventTime = picked);
  }

  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, "0")}/${d.month.toString().padLeft(2, "0")}/${d.year}";

  String _fmtTime(TimeOfDay? t) =>
      t == null ? "—" : "${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}";

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      _toast("Falta el nombre del campeonato");
      return;
    }
    if (_selectedCity == null) {
      _toast("Selecciona la ciudad");
      return;
    }

    // Validar categorías
    for (final c in _cats) {
      if (c.type == null) {
        _toast("Selecciona el tipo de categoría en todas las categorías");
        return;
      }

      if (c.type == "Master") {
        if (c.masterRange == null) {
          _toast("Selecciona el rango Master");
          return;
        }
        if (c.masterRange == "Personalizado") {
          final txt = c.masterCustomCtrl.text.trim();
          if (txt.isEmpty) {
            _toast("Escribe el rango Master personalizado (ej: 52–58 o 60+)");
            return;
          }
        }
      }
    }

    final storage = SessionStorage();
    final userId = await storage.getUserId();
    if (userId == null || userId.isEmpty) {
      _toast("No hay sesión activa");
      return;
    }

    final cats = _cats.map((c) => c.toJson()).toList();

    setState(() => _loading = true);
    try {
      await _api.adminCreateTournament(
        createdBy: userId,
        tournamentName: _name.text,
        description: _desc.text,
        location: _loc.text,
        city: _selectedCity,
        eventDate: _eventDate,
        eventTime: _eventTime,
        categories: cats,
      );

      if (!mounted) return;
      _toast("✅ Campeonato creado");
      Navigator.pop(context, true);
    } catch (e) {
      _toast("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear campeonato"),
        actions: [
          TextButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Guardar"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Field(label: "Nombre", child: TextField(controller: _name)),
          const SizedBox(height: 12),

          _Field(
            label: "Descripción",
            child: TextField(controller: _desc, maxLines: 3),
          ),
          const SizedBox(height: 12),

          _Field(
            label: "Ciudad",
            child: DropdownButtonFormField<String>(
              value: _selectedCity,
              isExpanded: true,
              items: chileCities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: _loading ? null : (v) => setState(() => _selectedCity = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Selecciona ciudad",
              ),
            ),
          ),
          const SizedBox(height: 12),

          _Field(
            label: "Club / Dirección (opcional)",
            child: TextField(
              controller: _loc,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ej: Club San Miguel, Gran Avenida 5550",
              ),
            ),
          ),
          const SizedBox(height: 12),

          _Field(
            label: "Fecha / Hora",
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _pickDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(_fmtDate(_eventDate)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _pickTime,
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(_fmtTime(_eventTime)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Text(
            "Categorías",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          ..._cats.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: c.type,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Categoría",
                              border: OutlineInputBorder(),
                            ),
                            items: categoryTypes
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: _loading
                                ? null
                                : (v) {
                                    setState(() {
                                      c.type = v;
                                      if (c.type != "Master") {
                                        c.masterRange = null;
                                        c.masterCustomCtrl.text = "";
                                      }
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: c.gender,
                          items: const [
                            DropdownMenuItem(value: "male", child: Text("Masculino")),
                            DropdownMenuItem(value: "female", child: Text("Femenino")),
                            DropdownMenuItem(value: "mixed", child: Text("Mixto")),
                          ],
                          onChanged: _loading ? null : (v) => setState(() => c.gender = v ?? "male"),
                        ),
                        IconButton(
                          onPressed: _loading || _cats.length <= 1 ? null : () => setState(() => _cats.removeAt(i)),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),

                    if (c.type == "Master") ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: c.masterRange,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Rango Master",
                          border: OutlineInputBorder(),
                        ),
                        items: masterRanges
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: _loading ? null : (v) => setState(() => c.masterRange = v),
                      ),

                      if (c.masterRange == "Personalizado") ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: c.masterCustomCtrl,
                          decoration: const InputDecoration(
                            labelText: "Rango personalizado",
                            hintText: "Ej: 52–58  |  60+",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 10),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Cupos ilimitados"),
                      value: c.unlimited,
                      onChanged: _loading ? null : (v) => setState(() => c.unlimited = v),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: "Precio",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: c.priceCtrl,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (!c.unlimited)
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: "Cupos",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              controller: c.quotasCtrl,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          OutlinedButton.icon(
            onPressed: _loading ? null : () => setState(() => _cats.add(_CatForm(gender: "male", price: 0))),
            icon: const Icon(Icons.add),
            label: const Text("Agregar categoría"),
          ),

          const SizedBox(height: 18),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: const Text("Crear campeonato"),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _CatForm {
  String? type; // Peneca / Infantil / ... / Master
  String gender;

  String? masterRange; // 35–39 ... 75+ ... Personalizado
  final TextEditingController masterCustomCtrl = TextEditingController();

  final TextEditingController priceCtrl;

  bool unlimited;
  final TextEditingController quotasCtrl;

  _CatForm({
    required this.gender,
    required int price,
  })  : priceCtrl = TextEditingController(text: price.toString()),
        unlimited = true,
        quotasCtrl = TextEditingController(text: "32");

  Map<String, dynamic> toJson() {
    int toInt(TextEditingController c, int fallback) {
      final v = int.tryParse(c.text.trim());
      return v ?? fallback;
    }

    String buildCategoryName() {
      final t = type ?? "Todo Competidor";

      if (t == "Master") {
        final r = masterRange ?? "";
        if (r == "Personalizado") {
          final custom = masterCustomCtrl.text.trim();
          return custom.isEmpty ? "Master" : "Master $custom";
        }
        return r.isEmpty ? "Master" : "Master $r";
      }

      return t;
    }

    return {
      "category_name": buildCategoryName(),
      "gender": gender,
      "inscription_price": toInt(priceCtrl, 0),
      "quotas": unlimited ? null : toInt(quotasCtrl, 32),
    };
  }

  void dispose() {
    masterCustomCtrl.dispose();
    priceCtrl.dispose();
    quotasCtrl.dispose();
  }
}