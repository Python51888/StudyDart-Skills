class SkillParams {
  final String name;
  final String description;
  final String? examplePrompt;
  final String? instructions;
  final List<String> resources;

  const SkillParams({
    required this.name,
    required this.description,
    this.examplePrompt,
    this.instructions,
    required this.resources,
  });

  factory SkillParams.fromJson(Map<String, dynamic> json) {
    return SkillParams(
      name: json['name'] as String,
      description: json['description'] as String,
      examplePrompt: json['examplePrompt'] as String?,
      instructions: json['instructions'] as String?,
      resources: (json['resources'] as List).cast<String>(),
    );
  }
}
