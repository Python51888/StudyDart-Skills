class Prompts {
  static String createSkillPrompt(String markdown, String? instructions) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Rewrite the following technical documentation into a high-quality '
      'SKILL.md file.',
    );
    buffer.writeln();
    buffer.writeln(
      'Return ONLY the SKILL.md content as raw markdown. Do NOT wrap in '
      'triple backticks. Do NOT include YAML frontmatter.',
    );
    buffer.writeln();
    if (instructions != null && instructions.isNotEmpty) {
      buffer.writeln('Additional instructions:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    buffer.writeln('--- SOURCE DOCUMENTATION ---');
    buffer.writeln(markdown);
    return buffer.toString();
  }

  static String updateSkillPrompt(
    String existingContent,
    String markdown,
    String? instructions,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Update the following existing SKILL.md file by incorporating new '
      'information from the source documentation below.',
    );
    buffer.writeln(
      'Preserve existing content that is still accurate. Update what has '
      'changed. Add what is new. Maintain the same structure and style.',
    );
    buffer.writeln();
    buffer.writeln(
      'Return ONLY the updated SKILL.md content as raw markdown. Do NOT '
      'wrap in triple backticks. Do NOT include YAML frontmatter.',
    );
    buffer.writeln();
    if (instructions != null && instructions.isNotEmpty) {
      buffer.writeln('Additional instructions:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    buffer.writeln('--- EXISTING SKILL.md ---');
    buffer.writeln(existingContent);
    buffer.writeln();
    buffer.writeln('--- NEW SOURCE DOCUMENTATION ---');
    buffer.writeln(markdown);
    return buffer.toString();
  }

  static String validateSkillPrompt(
    String markdown,
    String? instructions,
    String generationDate,
    String modelName,
    String currentContent,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Validate the following skill document against the provided source '
      'material.',
    );
    buffer.writeln();
    buffer.writeln(
      'Context: This skill was generated on $generationDate using model '
      '$modelName.',
    );
    buffer.writeln();
    if (instructions != null && instructions.isNotEmpty) {
      buffer.writeln('Original generation instructions:');
      buffer.writeln(instructions);
      buffer.writeln();
    }
    buffer.writeln('Evaluate the following criteria:');
    buffer.writeln(
      '1. Does the skill accurately reflect the source documentation?',
    );
    buffer.writeln('2. Are there any factual errors or omissions?');
    buffer.writeln(
      '3. Does the skill follow best practices for agent skills '
      '(workflows, checklists, conditional logic)?',
    );
    buffer.writeln('4. Are the code examples correct, complete, and runnable?');
    buffer.writeln();
    buffer.writeln(
      'Provide a detailed validation report. The VERY LAST LINE of your '
      'response must be: Grade: [0-100]',
    );
    buffer.writeln();
    buffer.writeln('--- SOURCE DOCUMENTATION ---');
    buffer.writeln(markdown);
    buffer.writeln();
    buffer.writeln('--- SKILL TO VALIDATE ---');
    buffer.writeln(currentContent);
    return buffer.toString();
  }
}
