import 'package:money_book/localDB/service/keeper.dart';

class KeeperAPI {
  static Future<void> initializingKeeper() async {
    final keepers = await KeeperService.getAll();
    if (keepers.length == 0) {
      await KeeperService.createKeeper(0);
    }
  }

  static Future<int> checkAndUpdateKeeper(int notificationNumber) async {
    final keepers = await KeeperService.getAll();
    await KeeperService.update(keepers[0] + notificationNumber);
    return keepers[0];
  }
}