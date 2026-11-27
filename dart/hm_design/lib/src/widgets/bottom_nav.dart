import 'package:material_ui/material_ui.dart';

import '../tokens.dart';
import 'art.dart';

/// One tab of [HmBottomNav].
@immutable
class HmNavItem {
  const HmNavItem({
    required this.label,
    required this.icon,
    IconData? selectedIcon,
    this.art,
  }) : selectedIcon = selectedIcon ?? icon;

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Bauhaus line icon (BOLT-0110). When set it replaces [icon] and [selectedIcon].
  final HmArtName? art;
}

/// The five-tab bar (§10.5). Bauhaus (BOLT-0110): a 3 px ink rule on top; the selected tab gets a
/// yellow block with an ink outline and a bold label, so selection is shown by shape and weight,
/// not colour alone (§10.9).
class HmBottomNav extends StatelessWidget {
  const HmBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<HmNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final text = Theme.of(context).textTheme;
    // Warm light (BOLT-0117): a floating white pill with a soft shadow; the selected tab sits on
    // an amber pill with a bold label, so selection shows by shape and weight, not colour alone.
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              HmSpace.lg,
              0,
              HmSpace.lg,
              HmSpace.md,
            ),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(HmRadius.pill),
              boxShadow: HmBauhaus.hardShadow(p, offset: const Offset(0, 6)),
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == currentIndex,
                      label:
                          '${items[i].label}, tab ${i + 1} of ${items.length}',
                      onTap: () => onSelect(i),
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(HmRadius.pill),
                        onTap: () => onSelect(i),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: HmSizes.minTapTarget + 8,
                          ),
                          child: _Tab(
                            item: items[i],
                            selected: i == currentIndex,
                            palette: p,
                            style: text.labelSmall,
                          ),
                        ),
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

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.palette,
    required this.style,
  });

  final HmNavItem item;
  final bool selected;
  final HmPalette palette;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final fg = selected ? p.onPrimary : p.textMuted;
    return AnimatedContainer(
      duration: HmMotion.fast,
      curve: HmMotion.standard,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? p.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(HmRadius.pill),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: HmMotion.pop,
            curve: HmMotion.spring,
            scale: selected ? 1.1 : 1,
            child: item.art != null
                ? HmArt(item.art!, size: 24, color: fg)
                : Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: fg,
                    size: 24,
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: selected ? p.onPrimary : p.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
