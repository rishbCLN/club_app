import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/nexus_text_field.dart';
import '../widgets/event_type_selector.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  const EditEventScreen({
    super.key,
    required this.clubId,
    required this.eventId,
  });

  final String clubId;
  final String eventId;

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _regLinkCtrl = TextEditingController();
  final _tagInput = TextEditingController();

  bool _initialized = false;
  EventType? _selectedType;
  bool _recruitmentOpen = false;
  bool _isOnline = false;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7, hours: 2));
  List<String> _collabClubIds = [];
  List<String> _tags = [];
  bool _isLoading = false;
  bool _shake = false;

  void _initFromEvent(EventModel event) {
    if (_initialized) return;
    _initialized = true;
    _titleCtrl.text = event.title;
    _descCtrl.text = event.description;
    _venueCtrl.text = event.venue == 'Online' ? '' : event.venue;
    _regLinkCtrl.text = event.registrationLink ?? '';
    _selectedType = EventType.fromString(event.eventType);
    _startDate = event.startDate;
    _endDate = event.endDate;
    _isOnline = event.venue == 'Online';
    _collabClubIds = List<String>.from(event.collaboratingClubs);
    _tags = List<String>.from(event.tags);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _venueCtrl.dispose();
    _descCtrl.dispose();
    _regLinkCtrl.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart,
      Color clubColor) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: clubColor,
            surface: NexusColors.surface,
            onSurface: NexusColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final picked2 = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: clubColor,
            surface: NexusColors.surface,
            onSurface: NexusColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked2 == null || !mounted) return;
    final dt = DateTime(picked.year, picked.month, picked.day, picked2.hour,
        picked2.minute);
    setState(() {
      if (isStart) {
        _startDate = dt;
        if (_endDate.isBefore(dt)) _endDate = dt.add(const Duration(hours: 2));
      } else {
        _endDate = dt;
      }
    });
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagInput.clear();
    });
  }

  Future<void> _save(EventModel original, ClubModel club) async {
    if (!(_formKey.currentState?.validate() ?? false) ||
        _selectedType == null) {
      setState(() => _shake = true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => _shake = false);
      return;
    }
    setState(() => _isLoading = true);

    final updated = EventModel(
      id: original.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      clubId: widget.clubId,
      clubName: club.name,
      clubColorHex: club.colorHex,
      eventType: _selectedType!.name,
      startDate: _startDate,
      endDate: _endDate,
      venue: _isOnline ? 'Online' : _venueCtrl.text.trim(),
      registrationLink: _regLinkCtrl.text.trim().isEmpty
          ? null
          : _regLinkCtrl.text.trim(),
      collaboratingClubs: _collabClubIds,
      tags: _tags,
    );

    ref.read(demoCreatedEventsProvider.notifier).updateEvent(updated);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NexusColors.emerald.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text('Changes saved',
            style: GoogleFonts.dmSans(
                color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    );
    context.go('/club/${widget.clubId}/admin');
  }

  void _confirmDelete(BuildContext context, String eventId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NexusColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: NexusColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.delete_outline_rounded,
                color: NexusColors.rose, size: 40),
            const SizedBox(height: 12),
            Text('Delete Event?', style: NexusText.cardTitle),
            const SizedBox(height: 8),
            Text(
              'This will permanently remove the event. Members will no longer see it.',
              style: NexusText.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: NexusColors.border),
                      foregroundColor: NexusColors.textSecondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel',
                        style: GoogleFonts.dmSans(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusColors.rose,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      ref
                          .read(demoCreatedEventsProvider.notifier)
                          .deleteEvent(eventId);
                      Navigator.pop(ctx);
                      context.go('/club/${widget.clubId}/admin');
                    },
                    child: Text('Delete',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubProvider(widget.clubId));
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final club = clubAsync.valueOrNull;
    final clubColor = club != null ? club.colorHex.toColor() : NexusColors.cyan;
    final event = eventAsync.valueOrNull;
    final allClubs = kMockClubs.where((c) => c.id != widget.clubId).toList();

    if (event == null) {
      return Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(
          child: Text('Event not found', style: NexusText.body),
        ),
      );
    }

    // Initialize form once event data arrives
    _initFromEvent(event);

    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: NexusColors.textSecondary, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '— EDIT EVENT',
                      style: NexusText.sectionLabel
                          .copyWith(color: clubColor, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _confirmDelete(context, event.id),
                    child: Text('Delete',
                        style: GoogleFonts.dmSans(
                            color: NexusColors.rose, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildSection(
                      label: '— WHAT IS IT',
                      accentColor: clubColor,
                      child: Column(
                        children: [
                          NexusTextField(
                            controller: _titleCtrl,
                            label: 'Event Title',
                            maxLength: 80,
                            accentColor: clubColor,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Title is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          NexusTextField(
                            controller: _taglineCtrl,
                            label: 'Tagline',
                            maxLength: 120,
                            accentColor: clubColor,
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      label: '— CATEGORY',
                      accentColor: clubColor,
                      child: EventTypeSelector(
                        selected: _selectedType,
                        onChanged: (t) => setState(() => _selectedType = t),
                        accentColor: clubColor,
                        recruitmentOpenToAll: _recruitmentOpen,
                        onRecruitmentToggle: (v) =>
                            setState(() => _recruitmentOpen = v),
                      ),
                    ),
                    _buildSection(
                      label: '— WHEN',
                      accentColor: clubColor,
                      child: Column(
                        children: [
                          _DateTile(
                            label: 'Start',
                            dt: _startDate,
                            accentColor: clubColor,
                            onTap: () => _pickDate(context, true, clubColor),
                          ),
                          const SizedBox(height: 10),
                          _DateTile(
                            label: 'End',
                            dt: _endDate,
                            accentColor: clubColor,
                            onTap: () => _pickDate(context, false, clubColor),
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      label: '— WHERE',
                      accentColor: clubColor,
                      child: Column(
                        children: [
                          if (!_isOnline)
                            NexusTextField(
                              controller: _venueCtrl,
                              label: 'Venue',
                              prefixIcon: Icons.location_on_outlined,
                              accentColor: clubColor,
                              validator: (v) {
                                if (_isOnline) return null;
                                return (v == null || v.trim().isEmpty)
                                    ? 'Venue required'
                                    : null;
                              },
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text('Online Event?',
                                  style: NexusText.body
                                      .copyWith(fontSize: 13)),
                              const Spacer(),
                              Switch(
                                value: _isOnline,
                                onChanged: (v) =>
                                    setState(() => _isOnline = v),
                                activeColor: clubColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      label: '— DETAILS',
                      accentColor: clubColor,
                      child: Column(
                        children: [
                          NexusTextField(
                            controller: _descCtrl,
                            label: 'Description',
                            maxLines: 6,
                            accentColor: clubColor,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Description is required'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          NexusTextField(
                            controller: _regLinkCtrl,
                            label: 'Registration Link',
                            prefixIcon: Icons.link_rounded,
                            accentColor: clubColor,
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      label: '— COLLABORATING CLUBS',
                      accentColor: clubColor,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allClubs.map((c) {
                          final selected = _collabClubIds.contains(c.id);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (selected) {
                                _collabClubIds.remove(c.id);
                              } else {
                                _collabClubIds.add(c.id);
                              }
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? c.colorHex
                                        .toColor()
                                        .withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? c.colorHex
                                          .toColor()
                                          .withOpacity(0.6)
                                      : NexusColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClubOrb(
                                      clubColor: c.colorHex.toColor(),
                                      clubName: c.name,
                                      logoUrl: c.logoUrl,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Text(c.name,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: selected
                                            ? NexusColors.textPrimary
                                            : NexusColors.textSecondary,
                                      )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    _buildSection(
                      label: '— TAGS',
                      accentColor: clubColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _tags
                                .map(
                                  (t) => GestureDetector(
                                    onTap: () =>
                                        setState(() => _tags.remove(t)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: clubColor.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                            color: clubColor.withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(t,
                                              style: GoogleFonts.spaceMono(
                                                  fontSize: 10,
                                                  color: clubColor)),
                                          const SizedBox(width: 4),
                                          Icon(Icons.close_rounded,
                                              size: 10,
                                              color:
                                                  clubColor.withOpacity(0.7)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: NexusTextField(
                                  controller: _tagInput,
                                  label: 'Add tag',
                                  hint: 'Type and press →',
                                  accentColor: clubColor,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: _addTag,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _addTag(_tagInput.text),
                                icon: const Icon(Icons.add_circle_rounded,
                                    color: NexusColors.cyan),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlowingButton(
                      label: 'Save Changes',
                      icon: Icons.check_rounded,
                      color1: clubColor,
                      color2: clubColor.withOpacity(0.6),
                      isLoading: _isLoading,
                      fullWidth: true,
                      onTap: () {
                        if (club != null) _save(event, club);
                      },
                    )
                        .animate(target: _shake ? 1 : 0)
                        .shake(hz: 6, duration: 400.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required Color accentColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: NexusText.sectionLabel
                  .copyWith(color: accentColor, fontSize: 10)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NexusColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NexusColors.border),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.dt,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final DateTime dt;
  final Color accentColor;
  final VoidCallback onTap;

  String _format(DateTime d) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: NexusColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: accentColor, size: 16),
            const SizedBox(width: 10),
            Text('$label: ',
                style: GoogleFonts.spaceMono(
                    fontSize: 11, color: NexusColors.textMuted)),
            Text(_format(dt),
                style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: NexusColors.textPrimary,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.edit_outlined,
                color: NexusColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
