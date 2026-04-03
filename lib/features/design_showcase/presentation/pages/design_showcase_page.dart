import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/widgets.dart';

/// Pantalla de demostración del sistema de diseño "Resonant Horizon"
/// Muestra todos los widgets atómicos con el nuevo tema púrpura/indigo
class DesignShowcasePage extends StatefulWidget {
  const DesignShowcasePage({super.key});

  @override
  State<DesignShowcasePage> createState() => _DesignShowcasePageState();
}

class _DesignShowcasePageState extends State<DesignShowcasePage> {
  int _selectedChip = 0;
  int _selectedToggle = 0;
  bool _switchValue = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppColors.bgPrimaryAdaptive(Theme.of(context).brightness);
    final textPrimary = AppColors.textPrimaryAdaptive(
      Theme.of(context).brightness,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Design System',
            style: AppTypography.appTitle.copyWith(color: Colors.white),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.lg,
        ),
        children: [
          // ── COLORES ──────────────────────────────────────────────────────
          _SectionTitle('Colores'),
          const SizedBox(height: AppSpacing.md),
          _ColorPalette(isDark: isDark),
          const SizedBox(height: AppSpacing.xl),

          // ── TIPOGRAFÍA ───────────────────────────────────────────────────
          _SectionTitle('Tipografía'),
          const SizedBox(height: AppSpacing.md),
          _TypographyShowcase(textPrimary: textPrimary),
          const SizedBox(height: AppSpacing.xl),

          // ── BOTONES ──────────────────────────────────────────────────────
          _SectionTitle('Botones'),
          const SizedBox(height: AppSpacing.md),
          _ButtonsShowcase(),
          const SizedBox(height: AppSpacing.xl),

          // ── SEARCH BAR ───────────────────────────────────────────────────
          _SectionTitle('Search Bar'),
          const SizedBox(height: AppSpacing.md),
          const LmkSearchBar(hint: 'Buscar recordatorios...'),
          const SizedBox(height: AppSpacing.xl),

          // ── CHIPS / FILTROS ───────────────────────────────────────────────
          _SectionTitle('Chips / Filtros'),
          const SizedBox(height: AppSpacing.md),
          LmkFilterChipGroup(
            labels: const ['Todos', 'Pendientes', 'Completados', 'Importantes'],
            selectedIndex: _selectedChip,
            onSelectionChanged: (i) => setState(() => _selectedChip = i),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── CARDS ────────────────────────────────────────────────────────
          _SectionTitle('Cards'),
          const SizedBox(height: AppSpacing.md),
          _CardsShowcase(isDark: isDark, textPrimary: textPrimary),
          const SizedBox(height: AppSpacing.xl),

          // ── SECTION HEADERS ───────────────────────────────────────────────
          _SectionTitle('Section Headers'),
          const SizedBox(height: AppSpacing.md),
          const LmkSectionHeader(title: 'Salud', badgeLabel: '2 Activos'),
          const SizedBox(height: AppSpacing.md),
          const LmkSectionHeader(
            title: 'Urgente',
            badgeLabel: 'Alta prioridad',
            badgeColor: AppColors.errorDeep,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── BADGES ───────────────────────────────────────────────────────
          _SectionTitle('Badges y Status Dots'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              LmkInfoBadge(label: 'Pendiente'),
              LmkInfoBadge(label: '2 Activos'),
              LmkInfoBadge(label: 'Alta', color: AppColors.errorDeep),
              LmkInfoBadge(label: 'Completado', color: Color(0xFF4CAF50)),
              SizedBox(width: AppSpacing.md),
              LmkStatusDot(color: AppColors.errorDeep),
              LmkStatusDot(color: AppColors.accentTertiary),
              LmkStatusDot(color: AppColors.accentPrimary),
              LmkStatusDot(color: AppColors.chipInactive),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── TOGGLE GROUP ─────────────────────────────────────────────────
          _SectionTitle('Selector Segmentado'),
          const SizedBox(height: AppSpacing.md),
          LmkToggleGroup(
            options: const ['Auto', 'Claro', 'Oscuro'],
            selectedIndex: _selectedToggle,
            onChanged: (i) => setState(() => _selectedToggle = i),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── FAB ──────────────────────────────────────────────────────────
          _SectionTitle('FAB'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              LmkFab(icon: Icons.add_rounded),
              const SizedBox(width: AppSpacing.md),
              LmkFab(
                icon: Icons.mic_rounded,
                backgroundColor: AppColors.accentPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── TEXT FIELD ─────────────────────────────────────────────────
          _SectionTitle('Text Field'),
          const SizedBox(height: AppSpacing.md),
          const LmkTextField(
            hint: 'Escribe algo...',
            prefixIcon: Icon(Icons.edit_outlined, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          const LmkTextField(
            hint: 'Buscar recordatorio...',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── AVATAR ────────────────────────────────────────────────────
          _SectionTitle('Avatar'),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              LmkAvatar(icon: Icons.person_rounded),
              SizedBox(width: AppSpacing.md),
              LmkAvatar(initial: 'A', radius: 24),
              SizedBox(width: AppSpacing.md),
              LmkAvatar(
                icon: Icons.smart_toy_rounded,
                radius: 20,
                backgroundColor: Color(0x1A007AFF),
                foregroundColor: AppColors.accentTertiary,
              ),
              SizedBox(width: AppSpacing.md),
              LmkAvatar(icon: Icons.account_circle_rounded, radius: 32),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── COUNTER ───────────────────────────────────────────────────
          _SectionTitle('Animated Counter'),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: LmkAnimatedCounter(
                  value: 5,
                  label: 'Pendientes',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LmkAnimatedCounter(
                  value: 2,
                  label: 'Vencidos',
                  color: AppColors.errorDeep,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: LmkAnimatedCounter(
                  value: 8,
                  label: 'Completados',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── PROGRESS BAR ──────────────────────────────────────────────
          _SectionTitle('Progress Bar'),
          const SizedBox(height: AppSpacing.md),
          const LmkProgressBar(progress: 0.75),
          const SizedBox(height: AppSpacing.sm),
          const LmkProgressBar(progress: 0.4, height: 8),
          const SizedBox(height: AppSpacing.sm),
          const LmkProgressBar(
            progress: 0.9,
            useGradient: false,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── LIST TILES ────────────────────────────────────────────────
          _SectionTitle('List Tiles'),
          const SizedBox(height: AppSpacing.md),
          LmkSettingsSection(
            title: 'Ejemplo Sección',
            icon: Icons.settings_outlined,
            children: [
              LmkNavTile(
                icon: Icons.palette_outlined,
                title: 'Apariencia',
                subtitle: 'Tema, colores, fuentes',
                onTap: () {},
              ),
              LmkSwitchTile(
                icon: Icons.vibration_rounded,
                title: 'Vibración',
                subtitle: 'Feedback táctil',
                value: _switchValue,
                onChanged: (v) => setState(() => _switchValue = v),
              ),
              const LmkInfoTile(
                icon: Icons.verified_rounded,
                title: 'Versión',
                subtitle: '1.0.0 (Build 1)',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── SHIMMER / SKELETON ────────────────────────────────────────
          _SectionTitle('Shimmer / Skeleton'),
          const SizedBox(height: AppSpacing.md),
          const LmkSkeletonBox(height: 80),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              Expanded(child: LmkSkeletonBox(height: 48)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: LmkSkeletonBox(height: 48)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── EMPTY STATE ───────────────────────────────────────────────
          _SectionTitle('Empty State'),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(
            height: 220,
            child: LmkEmptyState(
              icon: Icons.inbox_rounded,
              title: 'No tienes recordatorios',
              subtitle: 'Toca el micrófono para crear\ntu primer recordatorio',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── DIALOG & BOTTOM SHEET ─────────────────────────────────────
          _SectionTitle('Dialog & Bottom Sheet'),
          const SizedBox(height: AppSpacing.md),
          const _InteractiveShowcase(),
          const SizedBox(height: AppSpacing.xl),

          // ── SNACKBAR ──────────────────────────────────────────────────
          _SectionTitle('SnackBar'),
          const SizedBox(height: AppSpacing.md),
          LmkSecondaryButton(
            label: 'Mostrar SnackBar',
            icon: Icons.info_outline_rounded,
            onPressed: () {
              showLmkSnackBar(
                context,
                message: 'Recordatorio completado',
                actionLabel: 'DESHACER',
                onAction: () {},
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── ICON BOX ──────────────────────────────────────────────────
          _SectionTitle('Icon Box'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: const [
              LmkIconBox(
                icon: Icons.palette_outlined,
                color: AppColors.accentPrimary,
              ),
              LmkIconBox(
                icon: Icons.medication_rounded,
                color: AppColors.reminderMedication,
                size: 26,
                padding: 10,
              ),
              LmkIconBox(
                icon: Icons.alarm_on_rounded,
                color: AppColors.error,
                circle: true,
                size: 28,
                padding: 12,
              ),
              LmkIconBox(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              LmkIconBox(
                icon: Icons.event_rounded,
                color: AppColors.reminderAppointment,
              ),
              LmkIconBox(
                icon: Icons.shopping_cart_rounded,
                color: AppColors.reminderShopping,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── TYPE BADGE ────────────────────────────────────────────────
          _SectionTitle('Type Badge'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              LmkTypeBadge(
                label: 'Medicamento',
                color: AppColors.reminderMedication,
                icon: Icons.medication_rounded,
              ),
              LmkTypeBadge(
                label: 'Cita médica',
                color: AppColors.reminderAppointment,
                icon: Icons.event_rounded,
              ),
              LmkTypeBadge(label: 'Vencido', color: AppColors.error),
              LmkTypeBadge(
                label: 'Completado',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
              LmkTypeBadge(
                label: 'GRUPO',
                color: AppColors.accentPrimary,
                compact: true,
              ),
              LmkTypeBadge(
                label: 'NUEVO',
                color: AppColors.reminderCall,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── META ROW ──────────────────────────────────────────────────
          _SectionTitle('Meta Row'),
          const SizedBox(height: AppSpacing.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LmkMetaRow(icon: Icons.schedule_rounded, text: 'Hoy, 8:00 AM'),
              SizedBox(height: AppSpacing.sm),
              LmkMetaRow(
                icon: Icons.place_rounded,
                text: 'Farmacia Central',
                iconColor: AppColors.reminderLocation,
              ),
              SizedBox(height: AppSpacing.sm),
              LmkMetaRow(
                icon: Icons.repeat_rounded,
                text: 'Cada 12 horas',
                compact: true,
              ),
              SizedBox(height: AppSpacing.sm),
              LmkMetaRow(
                icon: Icons.person_rounded,
                text: 'Dr. García — Cardiólogo',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── GRADIENT TEXT ────────────────────────────────────────────
          _SectionTitle('Gradient Text'),
          const SizedBox(height: AppSpacing.md),
          LmkGradientText(
            'Avísame',
            style: AppTypography.appTitle.copyWith(fontSize: 40),
          ),
          const SizedBox(height: AppSpacing.sm),
          LmkGradientText('Resonant Horizon', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          LmkGradientText(
            '42',
            style: AppTypography.number.copyWith(fontSize: 48),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── PULSE CONTAINER ──────────────────────────────────────────
          _SectionTitle('Pulse Container'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              LmkPulseContainer(
                color: AppColors.error,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Icon(
                  Icons.alarm_on_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              LmkPulseContainer(
                color: AppColors.accentPrimary,
                maxScale: 1.08,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const Icon(
                  Icons.mic_rounded,
                  color: AppColors.accentPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              LmkPulseContainer(
                color: AppColors.success,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Helpers internos ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(), style: AppTypography.sectionHeader);
  }
}

class _ColorPalette extends StatelessWidget {
  final bool isDark;
  const _ColorPalette({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final swatches = [
      ('Primary', AppColors.accentPrimary, '#504DCD'),
      ('Secondary', AppColors.chipInactive, '#E2E2E7'),
      ('Tertiary', AppColors.accentTertiary, '#007AFF'),
      ('Neutral', const Color(0xFFF2F2F7), '#F2F2F7'),
      ('Error', AppColors.errorDeep, '#A83836'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: swatches.map((s) {
        final (name, color, hex) = s;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              name,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimaryAdaptive(
                  isDark ? Brightness.dark : Brightness.light,
                ),
              ),
            ),
            Text(hex, style: AppTypography.helper),
          ],
        );
      }).toList(),
    );
  }
}

class _TypographyShowcase extends StatelessWidget {
  final Color textPrimary;
  const _TypographyShowcase({required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aa',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Headline — 24px Bold',
          style: AppTypography.titleLarge.copyWith(color: textPrimary),
        ),
        Text(
          'Body — 16px Regular',
          style: AppTypography.bodyMedium.copyWith(color: textPrimary),
        ),
        Text('LABEL — 12PX BOLD UPPERCASE', style: AppTypography.sectionHeader),
        Text('Helper / Caption — 14px', style: AppTypography.helper),
        const SizedBox(height: AppSpacing.sm),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Avísame',
            style: AppTypography.appTitle.copyWith(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LmkPrimaryButton(label: 'Finalizar', onPressed: () {}),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            LmkSecondaryButton(
              label: 'Imagen',
              icon: Icons.image_outlined,
              onPressed: () {},
            ),
            const SizedBox(width: AppSpacing.sm),
            LmkSecondaryButton(
              label: 'Escribir',
              icon: Icons.edit_outlined,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LmkTextIconButton(
          label: 'Nuevo Chat',
          icon: Icons.refresh_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _CardsShowcase extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  const _CardsShowcase({required this.isDark, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Glass card con accent
        LmkGlassCard(
          accentColor: AppColors.errorDeep,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tomar Vitamina D',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hoy, 09:00 AM',
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Glass card sin accent
        LmkGlassCard(
          accentColor: AppColors.accentTertiary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cita con el Dentista',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mañana, 16:30 PM',
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Bento cards en grid
        Row(
          children: [
            Expanded(
              child: LmkBentoCard(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.accentTertiary,
                  size: 20,
                ),
                title: 'Supermercado',
                subtitle: 'Lista de 12 productos',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: LmkBentoCard(
                icon: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.accentPrimary,
                  size: 20,
                ),
                title: 'Recoger Paquete',
                subtitle: 'Antes de las 19:00',
                statusDotColor: AppColors.errorDeep,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InteractiveShowcase extends StatelessWidget {
  const _InteractiveShowcase();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LmkSecondaryButton(
            label: 'Dialog',
            icon: Icons.open_in_new_rounded,
            onPressed: () {
              showLmkConfirmDialog(
                context,
                title: '¿Eliminar recordatorio?',
                message: 'Esta acción no se puede deshacer.',
                confirmLabel: 'Eliminar',
                cancelLabel: 'Cancelar',
                confirmColor: AppColors.errorDeep,
                icon: Icons.delete_outline_rounded,
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: LmkSecondaryButton(
            label: 'Bottom Sheet',
            icon: Icons.expand_less_rounded,
            onPressed: () {
              showLmkBottomSheet(
                context,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LmkBottomSheetOption(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Completar',
                      subtitle: 'Marcar como completado',
                      onTap: () {},
                    ),
                    LmkBottomSheetOption(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      onTap: () {},
                    ),
                    LmkBottomSheetOption(
                      icon: Icons.delete_outline_rounded,
                      label: 'Eliminar',
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
