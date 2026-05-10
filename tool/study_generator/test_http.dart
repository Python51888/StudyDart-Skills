import 'package:http/http.dart' as http;

void main() async {
  final c = http.Client();
  try {
    print('Fetching https://dart.cn/null-safety ...');
    final r = await c.get(Uri.parse('https://dart.cn/null-safety'));
    print('Status: ${r.statusCode}');
    print('Body length: ${r.body.length}');
  } catch (e) {
    print('Error: $e');
  } finally {
    c.close();
  }
}
