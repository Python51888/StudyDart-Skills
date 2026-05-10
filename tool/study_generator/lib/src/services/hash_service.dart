import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashService {
  String computeHash(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
