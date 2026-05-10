import 'dart:convert';
import 'dart:io';

class MetadataService {
  String? loadHash(String skillName, String outputDir) {
    final file = File('$outputDir/$skillName/metadata.json');
    if (!file.existsSync()) return null;
    try {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      return json['content_hash'] as String?;
    } on FormatException {
      return null;
    }
  }

  void saveUpdateResult(
    String skillName,
    String outputDir,
    String hash,
    int? grade,
  ) {
    final file = File('$outputDir/$skillName/metadata.json');
    var data = <String, dynamic>{};
    if (file.existsSync()) {
      try {
        data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      } on FormatException {
        // Use empty map on malformed JSON
      }
    }
    data['skill_name'] = skillName;
    data['content_hash'] = hash;
    data['last_updated'] = DateTime.now().toUtc().toIso8601String();
    if (grade != null) {
      data['last_grade'] = grade;
    }
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  Map<String, dynamic> loadMetadata(String skillName, String outputDir) {
    final file = File('$outputDir/$skillName/metadata.json');
    if (!file.existsSync()) return <String, dynamic>{};
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on FormatException {
      return <String, dynamic>{};
    }
  }
}
