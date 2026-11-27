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
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(
          top: BorderSide(color: p.outline, width: HmBauhaus.stroke),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HmSpace.xs,
            vertical: HmSpace.xs,
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == currentIndex,
                    label: '${items[i].label}, tab ${i + 1} of ${items.length}',
                    onTap: () => onSelect(i),
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(HmRadius.md),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: HmMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? p.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(HmRadius.sm),
            border: Border.all(
              color: selected ? p.outline : Colors.transparent,
              width: HmBauhaus.strokeSmall,
            ),
          ),
          child: item.art != null
              ? HmArt(
                  item.art!,
                  size: 24,
                  color: selected ? p.onGold : p.textMuted,
                )
              : Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected ? p.onGold : p.textMuted,
                  size: 24,
                ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: style?.copyWith(
            color: selected ? p.text : p.textMuted,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
