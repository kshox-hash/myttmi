import "package:flutter/material.dart";
import "package:myttmi/core/constants/app_colors.dart";
import "package:myttmi/routes/app_routes.dart";

import "package:myttmi/features/competition/api/competition_api.dart";

class AdminGenerateGroupsScreen extends StatefulWidget {
  final String tournamentId;
  final String categoryId;
  final String adminId;

  const AdminGenerateGroupsScreen({
    super.key,
    required this.tournamentId,
    required this.categoryId,
    required this.adminId,
  });

  @override
  State<AdminGenerateGroupsScreen> createState() => _AdminGenerateGroupsScreenState();
}

class _AdminGenerateGroupsScreenState extends State<AdminGenerateGroupsScreen> {
  bool loading = false;

  Future<void> _generate() async {
    setState(() => loading = true);
    try {
      await CompetitionApi.generateGroups(
        tournamentId: widget.tournamentId,
        categoryId: widget.categoryId,
        adminId: widget.adminId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Grupos generados")),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.groupsView,
        arguments: {
          "tournamentId": widget.tournamentId,
          "categoryId": widget.categoryId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Admin · Generar grupos"),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: loading ? null : _generate,
          child: Text(loading ? "Generando..." : "Generar grupos"),
        ),
      ),
    );
  }
}
