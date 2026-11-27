import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Bundled avatars: DiceBear "Lorelei" by Lisa Wischofsky, CC0 1.0. Fetched once with fixed seeds and shipped in
/// the app, so nothing about the user is sent to DiceBear.
abstract final class HmAvatars {
  static const count = 12;

  static String asset(int id) => 'packages/hm_design/assets/avatars/a$id.svg';

  static bool valid(int? id) => id != null && id >= 1 && id <= count;
}

/// A round avatar: the chosen picture, or the name's first letter on amber when none is chosen.
class HmAvatar extends StatelessWidget {
  const HmAvatar({
    super.key,
    this.id,
    this.name = '',
    this.size = 64,
    this.ring = true,
  });

  final int? id;
  final String name;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final p = context.hm;
    final inner = HmAvatars.valid(id)
        ? ClipOval(
            child: SvgPicture.asset(
              HmAvatars.asset(id!),
              width: size,
              height: size,
            ),
          )
        : Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFEFD5),
            ),
            child: Text(
              name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w900,
                color: p.primaryText,
              ),
            ),
          );
    if (!ring) return ExcludeSemantics(child: inner);
    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.all(size * 0.05),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [p.primary, const Color(0xFFFFD36E), p.primary],
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(size * 0.03),
          decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface),
          child: inner,
        ),
      ),
    );
  }
}
