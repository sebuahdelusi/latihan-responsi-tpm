import 'package:get/get.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';

class DetailController extends GetxController {
  DetailController({required this.category, required this.itemId});

  final String category;
  final int itemId;

  final Rxn<ArticleModel> item = Rxn<ArticleModel>();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await ApiService.fetchDetail(category, itemId);
      item.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
