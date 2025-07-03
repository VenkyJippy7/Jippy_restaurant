import 'package:get/get.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class ProductListController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    getCategories();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  RxBool isLoading = true.obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          Constant.userModel = value;
          userModel.value = value;
        }
      },
    );
    await getProduct();
    isLoading.value = false;
  }

  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
  Rx<VendorCategoryModel?> selectedCategory = Rx<VendorCategoryModel?>(null);

  Future<void> getProduct() async {
    await FireStoreUtils.getProduct().then(
      (value) {
        if (value != null) {
          productList.value = value;
        }
      },
    );
    await refreshCategoriesWithProducts();
  }

  Future<void> refreshCategoriesWithProducts() async {
    final categories = await FireStoreUtils.getVendorCategoryById();
    if (categories != null) {
      // Show all categories that have ever had products for this vendor
      final allProductCategoryIds = productList.map((p) => p.categoryID).toSet();
      categoryList.value = categories
        .where((cat) => allProductCategoryIds.contains(cat.id))
        .toList()
        ..sort((a, b) => (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
    }
  }

  void getCategories() async {
    await refreshCategoriesWithProducts();
  }

  updateList(String productId, bool isPublish) async {
    int mainIndex = productList.indexWhere((p) => p.id == productId);
    if (mainIndex != -1) {
      ProductModel productModel = productList[mainIndex];
      productModel.publish = !isPublish;
      productList[mainIndex] = productModel;
      update();
      await FireStoreUtils.setProduct(productModel);
    }
  }

  updateAvailableStatus(String productId, bool isAvailable) async {
    int mainIndex = productList.indexWhere((p) => p.id == productId);
    if (mainIndex != -1) {
      ProductModel productModel = productList[mainIndex];
      productModel.isAvailable = !isAvailable;
      productList[mainIndex] = productModel;
      update();
      await FireStoreUtils.updateProductIsAvailable(productModel.id!, productModel.isAvailable!);
    }
  }

  Future<void> deleteProduct(int index) async {
    final product = productList[index];
    await FireStoreUtils.deleteProduct(product);
    productList.removeAt(index);
    update();
  }

  List<ProductModel> get filteredProductList {
    if (selectedCategory.value == null) {
      return productList;
    } else {
      return productList
          .where((product) => product.categoryID == selectedCategory.value!.id)
          .toList();
    }
  }

  Future<void> toggleCategoryActive(int index) async {
    final category = categoryList[index];
    final newStatus = !(category.isActive ?? true);
    categoryList[index] = VendorCategoryModel(
      reviewAttributes: category.reviewAttributes,
      photo: category.photo,
      description: category.description,
      id: category.id,
      title: category.title,
      isActive: newStatus,
    );
    update();
    await FireStoreUtils.updateCategoryIsActive(category.id!, newStatus);
    // Set all products in this category to available/unavailable based on newStatus
    await FireStoreUtils.setAllProductsAvailabilityForCategory(category.id!, newStatus);
    await getProduct(); // Refresh product list
    getCategories(); // Refresh list from Firestore
  }
}
