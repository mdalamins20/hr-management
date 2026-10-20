import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

/// Binary local storage for the whole app.
///
/// Every record of the app is serialised into ONE binary blob with this
/// layout (the ".hrmb" format) and stored in a Hive box, which itself keeps
/// the bytes in a binary file on the device (IndexedDB on web):
///
///   bytes 0-3   magic "HRMB"
///   byte  4     format version (1)
///   bytes 5-8   payload length, big-endian
///   bytes 9..   payload (UTF-8 JSON)
///   last 4      checksum (sum of payload bytes mod 2^32), big-endian
///
/// The same blob is used for Backup export / import in Settings, so a
/// backup file is a real binary file, not plain text.
class BinaryCodec {
  static const List<int> magic = [0x48, 0x52, 0x4D, 0x42]; // HRMB
  static const int version = 1;

  static Uint8List encode(Map<String, dynamic> data) {
    final payload = utf8.encode(jsonEncode(data));
    final out = Uint8List(9 + payload.length + 4);
    out.setAll(0, magic);
    out[4] = version;
    final bd = ByteData.sublistView(out);
    bd.setUint32(5, payload.length);
    out.setAll(9, payload);
    var sum = 0;
    for (final b in payload) {
      sum = (sum + b) & 0xFFFFFFFF;
    }
    bd.setUint32(9 + payload.length, sum);
    return out;
  }

  /// Returns null when the blob is missing, corrupted or from an
  /// incompatible format version.
  static Map<String, dynamic>? decode(Uint8List bytes) {
    try {
      if (bytes.length < 13) return null;
      for (var i = 0; i < 4; i++) {
        if (bytes[i] != magic[i]) return null;
      }
      if (bytes[4] != version) return null;
      final bd = ByteData.sublistView(bytes);
      final len = bd.getUint32(5);
      if (bytes.length != 9 + len + 4) return null;
      final payload = bytes.sublist(9, 9 + len);
      var sum = 0;
      for (final b in payload) {
        sum = (sum + b) & 0xFFFFFFFF;
      }
      if (bd.getUint32(9 + len) != sum) return null;
      final decoded = jsonDecode(utf8.decode(payload));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static String encodeToBase64(Map<String, dynamic> data) =>
      base64Encode(encode(data));

  static Map<String, dynamic>? decodeFromBase64(String text) {
    try {
      return decode(base64Decode(text.trim()));
    } catch (_) {
      return null;
    }
  }
}

/// Thin wrapper over the Hive box that holds the binary state blob.
class LocalStore {
  static const String boxName = 'hr_management_box';
  static const String stateKey = 'state_v1';
  static bool ready = false;

  static Future<void> init() async {
    if (ready) return;
    await Hive.initFlutter();
    await Hive.openBox(boxName);
    ready = true;
  }

  static Box get _box => Hive.box(boxName);

  static Map<String, dynamic>? load() {
    if (!ready) return null;
    final raw = _box.get(stateKey);
    if (raw is Uint8List) return BinaryCodec.decode(raw);
    if (raw is List) {
      return BinaryCodec.decode(Uint8List.fromList(raw.cast<int>()));
    }
    return null;
  }

  static Future<void> save(Map<String, dynamic> data) async {
    if (!ready) return;
    await _box.put(stateKey, BinaryCodec.encode(data));
  }

  static Future<void> clear() async {
    if (!ready) return;
    await _box.delete(stateKey);
  }
}
