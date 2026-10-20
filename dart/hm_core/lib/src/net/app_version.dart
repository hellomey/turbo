/// True when [version] is lower than [minimum] (both `major.minor.patch`, extra parts such as
/// `+build` or `-pre` are ignored). Unparseable minimums never block the app.
bool isVersionLower(String version, String minimum) {
  final a = _parts(version);
  final b = _parts(minimum);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] < b[i];
  }
  return false;
}

List<int>? _parts(String v) {
  final core = v.trim().split(RegExp('[+-]')).first;
  final pieces = core.split('.');
  final out = <int>[];
  for (var i = 0; i < 3; i++) {
    final n = i < pieces.length ? int.tryParse(pieces[i]) : 0;
    if (n == null) return null;
    out.add(n);
  }
  return out;
}
