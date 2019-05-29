import 'dart:math';

class RandomGenerator {
  static final int seed = new DateTime.now().millisecondsSinceEpoch;
  static final markList =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  static final Random _random = new Random(seed);

  static String str([int len]) {
    len ??= 5;
    String re = '';
    for (var i = 0; i < len; i++) {
      re += markList[_random.nextInt(markList.length)];
    }
    return re;
  }
}
