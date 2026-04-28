import 'dart:math';

final _rng = Random();

/// 8-char base-36 random string. Mirrors the prototype's
/// `Math.random().toString(36).slice(2,10)`.
String uid() {
  final buf = StringBuffer();
  while (buf.length < 8) {
    buf.write(_rng.nextInt(1 << 32).toRadixString(36));
  }
  return buf.toString().substring(0, 8);
}
