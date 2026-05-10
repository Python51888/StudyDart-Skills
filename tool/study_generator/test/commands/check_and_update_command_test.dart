import 'package:study_generator/src/commands/check_and_update_command.dart';
import 'package:test/test.dart';

void main() {
  group('SkillResult', () {
    test('fromGrade auto_merged when grade above threshold', () {
      final result = SkillResult.fromGrade(
        skillName: 'test-skill',
        grade: 90,
        threshold: 85,
        validationPath: 'validation/test-skill/validation.md',
      );
      expect(result.status, equals(UpdateStatus.autoMerged));
    });

    test('fromGrade needsReview when grade below threshold', () {
      final result = SkillResult.fromGrade(
        skillName: 'test-skill',
        grade: 70,
        threshold: 85,
        validationPath: 'validation/test-skill/validation.md',
      );
      expect(result.status, equals(UpdateStatus.needsReview));
    });

    test('fromGrade auto_merged when grade equals threshold', () {
      final result = SkillResult.fromGrade(
        skillName: 'test-skill',
        grade: 85,
        threshold: 85,
        validationPath: 'validation/test-skill/validation.md',
      );
      expect(result.status, equals(UpdateStatus.autoMerged));
    });

    test('gradeRegex matches valid format', () {
      final regex = RegExp(r'Grade:\s*(\d+)');
      final match = regex.firstMatch('Some text\nGrade: 89\nMore text');
      expect(match, isNotNull);
      expect(match!.group(1), equals('89'));
    });

    test('gradeRegex does not match invalid format', () {
      final regex = RegExp(r'Grade:\s*(\d+)');
      expect(regex.hasMatch('Grade: ABC'), isFalse);
      expect(regex.hasMatch('No grade here'), isFalse);
    });
  });
}
