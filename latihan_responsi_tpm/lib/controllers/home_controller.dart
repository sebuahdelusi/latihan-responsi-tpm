import 'package:get/get.dart';
import '../services/auth_service.dart';

class HomeController extends GetxController {
  final RxString username = 'User'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final user = await AuthService.getLoggedInUser();
    username.value = user ?? 'User';
  }
}
