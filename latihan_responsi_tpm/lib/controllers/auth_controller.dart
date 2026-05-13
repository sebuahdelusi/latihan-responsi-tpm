import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final success = await AuthService.login(username, password);
      if (!success) {
        errorMessage.value = 'Username atau password salah';
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final success = await AuthService.register(username, password);
      if (!success) {
        errorMessage.value = 'Username sudah terdaftar';
      }
      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
