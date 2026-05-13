import 'package:get/get.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';

class ListController extends GetxController {
  ListController({required this.category});

  final String category;

  final RxList<ArticleModel> items = <ArticleModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await ApiService.fetchList(category);
      items.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
