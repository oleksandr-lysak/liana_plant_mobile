import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/widgets/animated_dropdown_field.dart';
import 'package:liana_plant/models/service.dart';
import 'dart:ui';

class MapFilterDialog extends StatefulWidget {
  final List<Service> services;
  final String? initialName;
  final int? initialServiceId;
  final double? initialRating;
  final bool? initialAvailable;
  final String? initialSort;
  final void Function({String? name, int? serviceId, double? rating, bool? available, String? sort}) onApply;

  const MapFilterDialog({
    super.key,
    required this.services,
    this.initialName,
    this.initialServiceId,
    this.initialRating,
    this.initialAvailable,
    this.initialSort,
    required this.onApply,
  });

  @override
  State<MapFilterDialog> createState() => _MapFilterDialogState();
}

class _MapFilterDialogState extends State<MapFilterDialog> {
  late TextEditingController nameController;
  DropdownItem? selectedService;
  double? selectedRating;
  bool? selectedAvailable;
  String? selectedSort;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    final items = widget.services.map((s) => DropdownItem(id: s.id, name: s.name)).toList();
    selectedService = widget.initialServiceId != null
        ? (items.where((item) => item.id == widget.initialServiceId).isNotEmpty
            ? items.firstWhere((item) => item.id == widget.initialServiceId)
            : null)
        : null;
    selectedRating = widget.initialRating;
    selectedAvailable = widget.initialAvailable;
    selectedSort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.12),
                    blurRadius: 32,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.12),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: theme.hintColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.filter_alt_rounded, color: theme.primaryColor, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          FlutterI18n.translate(context, 'map_view.filter_title'),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.hintColor, size: 26),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: nameController,
                    style: theme.textTheme.titleMedium,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      labelText: FlutterI18n.translate(context, 'map_view.filter_name'),
                      labelStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.hoverColor.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedDropdownField(
                    labelText: FlutterI18n.translate(context, 'map_view.filter_service'),
                    items: widget.services
                        .map((s) => DropdownItem(id: s.id, name: s.name))
                        .toList(),
                    selectedItem: selectedService,
                    onChanged: (item) {
                      setState(() {
                        selectedService = item;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<double>(
                    value: selectedRating,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.star_rounded, color: Colors.amber),
                      labelText: FlutterI18n.translate(context, 'map_view.filter_rating'),
                      labelStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.hoverColor.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    style: theme.textTheme.titleMedium,
                    items: [null, 1, 2, 3, 4, 5]
                        .map((r) => DropdownMenuItem<double>(
                              value: r?.toDouble(),
                              child: Row(
                                children: [
                                  Icon(Icons.star_rounded, color: r == null ? theme.hintColor : Colors.amber, size: 20),
                                  const SizedBox(width: 6),
                                  Text(r == null ? '-' : r.toString()),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedRating = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    value: selectedAvailable ?? false,
                    onChanged: (val) {
                      setState(() {
                        selectedAvailable = val;
                      });
                    },
                    title: Text(FlutterI18n.translate(context, 'map_view.filter_available'),
                        style: theme.textTheme.titleMedium),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: theme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedSort,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.sort_rounded),
                      labelText: FlutterI18n.translate(context, 'map_view.filter_sort'),
                      labelStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.hoverColor.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    style: theme.textTheme.titleMedium,
                    items: [
                      DropdownMenuItem(value: null, child: Text('-')),
                      DropdownMenuItem(value: 'name', child: Text(FlutterI18n.translate(context, 'map_view.sort_name'))),
                      DropdownMenuItem(value: 'rating', child: Text(FlutterI18n.translate(context, 'map_view.sort_rating'))),
                      DropdownMenuItem(value: 'distance', child: Text(FlutterI18n.translate(context, 'map_view.sort_distance'))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedSort = val;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.primaryColor,
                            side: BorderSide(color: theme.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(FlutterI18n.translate(context, 'cancel')),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          onPressed: () {
                            widget.onApply(
                              name: nameController.text.isNotEmpty ? nameController.text : null,
                              serviceId: selectedService?.id,
                              rating: selectedRating,
                              available: selectedAvailable,
                              sort: selectedSort,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(FlutterI18n.translate(context, 'apply')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 