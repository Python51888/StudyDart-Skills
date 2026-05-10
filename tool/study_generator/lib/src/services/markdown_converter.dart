import 'package:html/dom.dart';
import 'package:html/parser.dart';

/// Converts HTML content to Markdown.
class MarkdownConverter {
  /// Converts HTML content to Markdown.
  String convert(String htmlContent) {
    final document = parse(htmlContent);
    final body = document.body;
    if (body == null) return '';
    return _convertElement(body).trim();
  }

  String _convertElement(Element element) {
    final buffer = StringBuffer();
    for (final node in element.nodes) {
      if (node is Text) {
        buffer.write(node.text);
      } else if (node is Element) {
        buffer.write(_processTag(node));
      }
    }
    return buffer.toString();
  }

  String _processTag(Element element) {
    final content = _convertElement(element);
    switch (element.localName) {
      case 'h1': return '\n# $content\n\n';
      case 'h2': return '\n## $content\n\n';
      case 'h3': return '\n### $content\n\n';
      case 'h4': return '\n#### $content\n\n';
      case 'h5': return '\n##### $content\n\n';
      case 'h6': return '\n###### $content\n\n';
      case 'p': return '$content\n\n';
      case 'a':
        final href = element.attributes['href'];
        return '[$content]($href)';
      case 'strong': case 'b': return '**$content**';
      case 'em': case 'i': return '*$content*';
      case 'del': case 's': case 'strike': return '~~$content~~';
      case 'code': return '`$content`';
      case 'pre': return '\n```\n${element.text}\n```\n\n';
      case 'blockquote': return '\n> $content\n\n';
      case 'hr': return '\n---\n\n';
      case 'ul': return '\n$content\n';
      case 'ol': return '\n$content\n';
      case 'li': return '- $content\n';
      case 'img':
        final src = element.attributes['src'] ?? '';
        final alt = element.attributes['alt'] ?? '';
        return '![$alt]($src)';
      case 'video':
        final src = element.attributes['src'] ?? '';
        final poster = element.attributes['poster'] ?? '';
        final title = element.attributes['title'] ?? 'Video';
        String? videoUrl;
        if (src.isNotEmpty) {
          videoUrl = src;
        } else {
          videoUrl = element.children
              .where((e) => e.localName == 'source')
              .map((e) => e.attributes['src'])
              .firstWhere((s) => s != null, orElse: () => null);
        }
        if (videoUrl != null) {
          if (poster.isNotEmpty) {
            return '[![$title]($poster)]($videoUrl)';
          }
          return '[$title]($videoUrl)';
        }
        return '';
      case 'iframe':
        final src = element.attributes['src'] ?? '';
        final title = element.attributes['title'] ?? 'Iframe';
        if (src.isNotEmpty) {
          return '[$title]($src)';
        }
        return '';
      case 'table': return _processTable(element);
      case 'dl': return _processDefinitionList(element);
      case 'dt': return '\n**$content**\n';
      case 'dd': return ': $content\n';
      case 'details': return '\n<details>\n$content\n</details>\n';
      case 'summary': return '<summary>$content</summary>';
      case 'br': return '\n';
      case 'div': case 'section': case 'main': case 'article': return '$content\n';
      default: return content;
    }
  }

  String _processTable(Element table) {
    final buffer = StringBuffer('\n');
    var headerCells = <Element>[];
    final bodyRows = <Element>[];
    final theads = table.children.where((e) => e.localName == 'thead').toList();
    if (theads.isNotEmpty) {
      final headerRows = theads.first.children.where((e) => e.localName == 'tr').toList();
      if (headerRows.isNotEmpty) {
        final headerRow = headerRows.first;
        headerCells = headerRow.children.where((e) => e.localName == 'th').toList();
        if (headerCells.isEmpty) {
          headerCells = headerRow.children.where((e) => e.localName == 'td').toList();
        }
      }
    }
    for (final child in table.children) {
      if (child.localName == 'tbody' || child.localName == 'tfoot') {
        bodyRows.addAll(child.children.where((e) => e.localName == 'tr'));
      } else if (child.localName == 'tr') {
        bodyRows.add(child);
      }
    }
    if (headerCells.isEmpty && bodyRows.isNotEmpty) {
      final firstRow = bodyRows.first;
      headerCells = firstRow.children.where((e) => e.localName == 'th').toList();
      if (headerCells.isEmpty) {
        headerCells = firstRow.children.where((e) => e.localName == 'td').toList();
      }
      bodyRows.removeAt(0);
    }
    if (headerCells.isEmpty && bodyRows.isEmpty) return '';
    buffer.write('|');
    for (final cell in headerCells) {
      buffer.write(' ${_convertElement(cell).trim()} |');
    }
    buffer.write('\n|');
    for (var i = 0; i < headerCells.length; i++) {
      buffer.write('---|');
    }
    buffer.write('\n');
    for (final row in bodyRows) {
      final cells = row.children.where((e) => e.localName == 'td' || e.localName == 'th').toList();
      if (cells.isEmpty) continue;
      buffer.write('|');
      for (final cell in cells) {
        buffer.write(' ${_convertElement(cell).trim()} |');
      }
      buffer.write('\n');
    }
    buffer.write('\n');
    return buffer.toString();
  }

  String _processDefinitionList(Element dl) {
    final buffer = StringBuffer('\n');
    for (final child in dl.children) {
      buffer.write(_processTag(child));
    }
    buffer.write('\n\n');
    return buffer.toString();
  }
}
