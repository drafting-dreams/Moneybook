import 'package:money_book/localDB/service/theme.dart';

class ThemeAPI {
  static Future<void> initializingThemes() async {
    final List<String> themes = await ThemeService.list();
    if (themes.length ==0) {
      const themeData = {
        'alien blue': 1,
        'tree': 0,
        'pony': 0,
        'noble purple': 0,
        'chocolate': 0,
        'dark': 0
      };
      List<Future> futures = [];
      themeData.forEach((k, v) {
        futures.add(ThemeService.add(k, v));
      });
      await Future.wait(futures);
    }
  }

  static Future<void> setTheme(String name) async {
    await ThemeService.setTheme(name);
  }

  static Future<String> getUsing() async {
    final result = await ThemeService.getUsing();
    return result;
  }
}