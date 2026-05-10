import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'package:study_generator/src/commands/generate_skill_command.dart';
import 'package:study_generator/src/commands/update_skill_command.dart';
import 'package:study_generator/src/commands/validate_skill_command.dart';
import 'package:study_generator/src/commands/update_readme_command.dart';

void main(List<String> arguments) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    final out = record.level >= Level.SEVERE ? stderr : stdout;
    out.writeln('[${record.level.name}] ${record.message}');
  });

  final logger = Logger('study_generator');

  runZonedGuarded(
    () async {
      final client = http.Client();
      try {
        final runner = CommandRunner<void>(
          'study_generator',
          'AI-powered skill generator for Dart CN documentation',
        )
          ..addCommand(GenerateSkillCommand(
            logger: logger,
            httpClient: client,
          ))
          ..addCommand(UpdateSkillCommand(
            logger: logger,
            httpClient: client,
          ))
          ..addCommand(ValidateSkillCommand(
            logger: logger,
            httpClient: client,
          ))
          ..addCommand(UpdateReadmeCommand(
            logger: logger,
          ));

        await runner.run(arguments);
        exit(0);
      } on UsageException catch (e) {
        stderr.writeln(e);
        exit(64);
      } on Exception catch (e) {
        stderr.writeln(e);
        exit(1);
      } finally {
        client.close();
      }
    },
    (error, stack) {
      logger.severe('Unhandled error: $error\n$stack');
      exit(1);
    },
  );
}
