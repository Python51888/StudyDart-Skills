import 'dart:convert';
import 'dart:io';

import 'package:study_generator/src/services/metadata_service.dart';
import 'package:test/test.dart';

void main() {
  group('MetadataService', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('metadata_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('loadHash returns null when metadata.json does not exist', () {
      final service = MetadataService();
      final result = service.loadHash('nonexistent', tempDir.path);
      expect(result, isNull);
    });

    test('saveUpdateResult and loadHash round-trip', () {
      final service = MetadataService();
      service.saveUpdateResult('test-skill', tempDir.path, 'abc123hash', 92);

      final hash = service.loadHash('test-skill', tempDir.path);
      expect(hash, equals('abc123hash'));

      final meta = service.loadMetadata('test-skill', tempDir.path);
      expect(meta['skill_name'], equals('test-skill'));
      expect(meta['content_hash'], equals('abc123hash'));
      expect(meta['last_grade'], equals(92));
      expect(meta['last_updated'], isNotNull);
    });

    test('saveUpdateResult with null grade does not write last_grade', () {
      final service = MetadataService();
      service.saveUpdateResult('test-skill', tempDir.path, 'hash', null);

      final file = File('${tempDir.path}/test-skill/metadata.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(json.containsKey('last_grade'), isFalse);
    });

    test('loadMetadata returns empty map when file does not exist', () {
      final service = MetadataService();
      final result = service.loadMetadata('nonexistent', tempDir.path);
      expect(result, isEmpty);
    });

    test('saveUpdateResult overwrites existing metadata', () {
      final service = MetadataService();
      service.saveUpdateResult('test-skill', tempDir.path, 'old-hash', 80);
      service.saveUpdateResult('test-skill', tempDir.path, 'new-hash', 95);

      final hash = service.loadHash('test-skill', tempDir.path);
      expect(hash, equals('new-hash'));

      final meta = service.loadMetadata('test-skill', tempDir.path);
      expect(meta['last_grade'], equals(95));
    });
  });
}
