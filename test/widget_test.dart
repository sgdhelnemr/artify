import 'package:flutter_test/flutter_test.dart';
import 'package:artify/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('password needs at least 6 chars', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('price must be positive', () {
      expect(Validators.price('0'), isNotNull);
      expect(Validators.price('100'), isNull);
    });
  });
}
