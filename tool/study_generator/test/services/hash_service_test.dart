import 'package:study_generator/src/services/hash_service.dart';
import 'package:test/test.dart';

void main() {
  group('HashService', () {
    final hashService = HashService();

    test('computeHash returns 64-char hex string', () {
      final result = hashService.computeHash('hello world');
      expect(result, hasLength(64));
      expect(result, matches(RegExp(r'^[a-f0-9]{64}$')));
    });

    test('computeHash same input produces same output', () {
      final a = hashService.computeHash('hello');
      final b = hashService.computeHash('hello');
      expect(a, equals(b));
    });

    test('computeHash different input produces different output', () {
      final a = hashService.computeHash('hello');
      final b = hashService.computeHash('world');
      expect(a, isNot(equals(b)));
    });
  });
}
