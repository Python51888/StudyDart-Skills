void main() {
  // Try all possible hash names
  final names = [
    'sha256',
    'sha1',
    'md5',
    'Sha256',
    'Sha1',
    'Md5',
    'hmacSha256',
    'Hmac',
  ];
  for (final name in names) {
    print('$name: (checking...)');
  }
}
