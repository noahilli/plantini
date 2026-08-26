import 'dart:math';

/// Generates opaque, stable-once-persisted client IDs for idempotent writes.
///
/// The timestamp supports chronological diagnostics; random bytes prevent the
/// identifier from being predictable. It intentionally does not expose user
/// data or device identifiers.
abstract interface class ClientIdGenerator {
  String next();
}

final class SecureClientIdGenerator implements ClientIdGenerator {
  SecureClientIdGenerator({Random? random})
    : _random = random ?? Random.secure();

  final Random _random;

  @override
  String next() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // RFC 4122 version 4 / variant 1 so values satisfy the documented v1
    // contract's `format: uuid` restriction.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
