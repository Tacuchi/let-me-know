import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/services/feedback_service.dart';
import '../../application/cubit/notes_cubit.dart';
import '../../application/cubit/notes_state.dart';
import '../../../reminders/domain/entities/reminder.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final FeedbackService _feedbackService;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    _feedbackService = getIt<FeedbackService>();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimary;
    final appBarBgColor = isDark
        ? AppColors.bgSecondaryDark
        : AppColors.bgSecondary;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final filter = switch (state) {
          NotesLoaded(:final filter) => filter,
          _ => NotesFilter.all,
        };

        final filtered = state is NotesLoaded
            ? state.filtered
            : const <Reminder>[];

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: appBarBgColor,
            title: Text(
              'Mis Notas',
              style: AppTypography.titleMedium.copyWith(color: textColor),
            ),
            actions: [
              if (kDebugMode) ...[
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'DEBUG: Refrescar',
                  onPressed: () {
                    _feedbackService.light();
                    context.read<NotesCubit>().refresh();
                  },
                ),
              ],
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Buscar',
                onPressed: () {
                  _feedbackService.light();
                  _showSearchSheet(context, isDark);
                },
              ),
              IconButton(
                icon: const Icon(Icons.mic_rounded),
                tooltip: 'Consultar por voz',
                onPressed: () {
                  _feedbackService.light();
                  context.pushNamed('record');
                },
              ),
            ],
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildFilters(isDark, filter),
                  Expanded(
                    child: switch (state) {
                      NotesLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      NotesError(:final message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(message),
                        ),
                      ),
                      NotesLoaded() =>
                        filtered.isEmpty
                            ? _buildEmptyState(isDark, filter: filter)
                            : _buildNotesList(isDark, filtered),
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(bool isDark, NotesFilter currentFilter) {
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final selectedColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;
    final unselectedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    const filters = NotesFilter.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) {
                _feedbackService.light();
                context.read<NotesCubit>().setFilter(filter);
              },
              backgroundColor: bgColor,
              selectedColor: selectedColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? selectedColor : Colors.transparent,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotesList(bool isDark, List<Reminder> notes) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NoteCard(
            note: note,
            onTap: () {
              _feedbackService.light();
              context.push('/reminders/${note.id}');
            },
            onDelete: () {
              _feedbackService.medium();
              context.read<NotesCubit>().delete(note.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, {NotesFilter filter = NotesFilter.all}) {
    final textColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final helperColor = isDark
        ? AppColors.textHelperDark
        : AppColors.textHelper;
    final primaryColor = isDark
        ? AppColors.accentPrimaryDark
        : AppColors.accentPrimary;

    final (title, subtitle, icon) = switch (filter) {
      NotesFilter.recent => (
        'Sin notas recientes',
        'No has guardado notas\nen la última semana',
        Icons.schedule_rounded,
      ),
      NotesFilter.byObject => (
        'Sin notas de objetos',
        'Guarda notas como:\n"Dejé las llaves en la cocina"',
        Icons.category_rounded,
      ),
      NotesFilter.byLocation => (
        'Sin notas de lugares',
        'Guarda notas con ubicaciones\npara encontrarlas aquí',
        Icons.place_rounded,
      ),
      _ => (
        'Sin notas aún',
        'Pregunta: "¿Dónde dejé mis llaves?"\no guarda una nota por voz',
        Icons.sticky_note_2_rounded,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 56,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: helperColor),
              textAlign: TextAlign.center,
            ),
            if (filter == NotesFilter.all) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swipe_rounded, size: 20, color: helperColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Desliza para eliminar',
                    style: AppTypography.helper.copyWith(color: helperColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext outerContext, bool isDark) {
    final cubit = outerContext.read<NotesCubit>();

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: cubit,
          child: _SearchSheetContent(isDark: isDark),
        );
      },
    ).whenComplete(() {
      cubit.clearSearch();
    });
  }
}

class _SearchSheetContent extends StatefulWidget {
  final bool isDark;

  const _SearchSheetContent({required this.isDark});

  @override
  State<_SearchSheetContent> createState() => _SearchSheetContentState();
}

class _SearchSheetContentState extends State<_SearchSheetContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.dividerDark : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar nota... ej: llaves, cocina',
                        hintStyle: TextStyle(color: hintColor),
                        prefixIcon: Icon(Icons.search_rounded, color: hintColor),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: hintColor),
                                onPressed: () {
                                  _controller.clear();
                                  context.read<NotesCubit>().clearSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? AppColors.bgTertiaryDark : AppColors.bgTertiary,
                      ),
                      style: TextStyle(color: textColor),
                      onChanged: (value) {
                        context.read<NotesCubit>().search(value);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<NotesCubit, NotesState>(
                  builder: (context, state) {
                    if (state is! NotesLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!state.isSearching) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Escribe para buscar',
                              style: AppTypography.label.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Icon(
                              Icons.search_rounded,
                              size: 64,
                              color: hintColor.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      );
                    }

                    final results = state.searchResults ?? [];

                    if (results.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: hintColor,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Sin resultados para "${state.searchQuery}"',
                              style: AppTypography.bodyMedium.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final note = results[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: NoteCard(
                            note: note,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/reminders/${note.id}');
                            },
                            onDelete: () {
                              getIt<FeedbackService>().medium();
                              context.read<NotesCubit>().delete(note.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final Reminder note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgSecondaryDark : AppColors.bgSecondary;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final helperColor = isDark ? AppColors.textHelperDark : AppColors.textHelper;

    final formatter = DateFormat('d MMM, h:mm a', 'es_ES');

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.overdue,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.reminderLocation
                      .withValues(alpha: isDark ? 0.3 : 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Center(
                  child: Text('📌', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (note.object != null || note.location != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (note.object != null) ...[
                            Icon(Icons.category_rounded,
                                size: 14, color: secondaryColor),
                            const SizedBox(width: 4),
                            Text(
                              note.object!,
                              style: AppTypography.helper
                                  .copyWith(color: secondaryColor),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          if (note.location != null) ...[
                            Icon(Icons.place_rounded,
                                size: 14, color: secondaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                note.location!,
                                style: AppTypography.helper
                                    .copyWith(color: secondaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      formatter.format(note.createdAt),
                      style: AppTypography.helper.copyWith(color: helperColor),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
