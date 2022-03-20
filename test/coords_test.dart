import 'package:mr_blue_sky/models/coords.dart';
import 'package:test/test.dart';

void main() {
  group('Coordinates', () {
    test('test lat getter', () {
      var a = Coordinates(100, 50);
      expect(a.lat, 100);
    });

    test('test long getter', () {
      var a = Coordinates(100, 50);
      expect(a.long, 50);
    });

    test('subtract coordinate pairs', () {
      var a = Coordinates(100, 50);
      var b = Coordinates(50, 100);
      var c = a - b;
      expect(c.lat, 50);
      expect(c.long, -50);
    });

    test('get absolute coordinates', () {
      var a = Coordinates(-100, -5).absolute;
      expect(a.lat, 100);
      expect(a.long, 5);
    });

    test('get coordinates distance (6,8)', () {
      var a = Coordinates(6, 8);
      expect(a.distance, 10);
    });

    test('get coordinates distance (5,12)', () {
      var a = Coordinates(5, 12);
      expect(a.distance, 13);
    });

    test('get coordinates distance when mixed signs', () {
      var a = Coordinates(6, -8);
      expect(a.distance, 10);
    });
  });
}
