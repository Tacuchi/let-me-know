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
