import 'package:flutter/foundation.dart';

class OrdersListRefreshNotifier extends ChangeNotifier {
  void requestRefresh() => notifyListeners();
}
