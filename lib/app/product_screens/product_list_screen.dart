import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant/app/product_screens/add_product_screen.dart';
import 'package:restaurant/app/verification_screen/verification_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/product_list_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/network_image_widget.dart';

class ProductToggles extends StatelessWidget {
  final bool isPublished;
  final bool isAvailable;
  final ValueChanged<bool> onPublishChanged;
  final ValueChanged<bool> onAvailableChanged;

  const ProductToggles({
    required this.isPublished,
    required this.isAvailable,
    required this.onPublishChanged,
    required this.onAvailableChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 350;
    return isSmall
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _toggleRow('Publish', isPublished, onPublishChanged),
              _toggleRow('Available', isAvailable, onAvailableChanged),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _toggleRow('Publish', isPublished, onPublishChanged),
              SizedBox(width: 12),
              _toggleRow('Available', isAvailable, onAvailableChanged),
            ],
          );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ProductListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              title: Text(
                "Manage Products".tr,
                style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    fontSize: 18,
                    fontFamily: AppThemeData.medium),
              ),
              actions: [
                (Constant.isRestaurantVerification == true &&
                            controller.userModel.value.isDocumentVerify ==
                                false) ||
                        (controller.userModel.value.vendorID == null ||
                            controller.userModel.value.vendorID!.isEmpty)
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          if ((Constant.isSubscriptionModelApplied == true ||
                                  Constant.adminCommission?.isEnabled ==
                                      true) &&
                              Constant.userModel?.subscriptionPlan?.itemLimit !=
                                  '-1' &&
                              int.parse(Constant.userModel?.subscriptionPlan
                                                  ?.itemLimit !=
                                              null &&
                                          Constant.userModel?.subscriptionPlan
                                                  ?.itemLimit
                                                  .toString() !=
                                              "null"
                                      ? "${Constant.userModel?.subscriptionPlan?.itemLimit}"
                                      : '0') <=
                                  controller.productList.length) {
                            ShowToastDialog.showToast(
                                "Your current subscription plan has reached its maximum product limit. Upgrade now to add more products."
                                    .tr);
                          } else {
                            Get.to(const AddProductScreen())!.then(
                              (value) {
                                if (value == true) {
                                  controller.getProduct();
                                }
                              },
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey50,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Add".tr,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey50,
                                    fontSize: 18,
                                    fontFamily: AppThemeData.medium),
                              )
                            ],
                          ),
                        ),
                      )
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Constant.isRestaurantVerification == true &&
                        controller.userModel.value.isDocumentVerify == false
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey700
                                    : AppThemeData.grey200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(120),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                    "assets/icons/ic_document.svg"),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Document Verification in Pending".tr,
                              style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                  fontSize: 22,
                                  fontFamily: AppThemeData.semiBold),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Your documents are being reviewed. We will notify you once the verification is complete."
                                  .tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey500,
                                  fontSize: 16,
                                  fontFamily: AppThemeData.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedButtonFill(
                              title: "View Status".tr,
                              width: 55,
                              height: 5.5,
                              color: AppThemeData.secondary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                Get.to(const VerificationScreen());
                              },
                            ),
                          ],
                        ),
                      )
                    : controller.userModel.value.vendorID == null ||
                            controller.userModel.value.vendorID!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey700
                                        : AppThemeData.grey200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(120),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: SvgPicture.asset(
                                        "assets/icons/ic_building_two.svg"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "Add Your First Restaurant".tr,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey100
                                          : AppThemeData.grey800,
                                      fontSize: 22,
                                      fontFamily: AppThemeData.semiBold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Get started by adding your restaurant details to manage your menu, orders, and reservations."
                                      .tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey500,
                                      fontSize: 16,
                                      fontFamily: AppThemeData.bold),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                RoundedButtonFill(
                                  title: "Add Restaurant".tr,
                                  width: 55,
                                  height: 5.5,
                                  color: AppThemeData.secondary300,
                                  textColor: AppThemeData.grey50,
                                  onPress: () async {
                                    Get.to(const AddRestaurantScreen());
                                  },
                                ),
                              ],
                            ),
                          )
                        : controller.productList.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey700
                                            : AppThemeData.grey200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_knife_fork.svg",
                                          colorFilter: ColorFilter.mode(
                                              themeChange.getThem()
                                                  ? AppThemeData.grey400
                                                  : AppThemeData.grey500,
                                              BlendMode.srcIn),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      "No Products Available".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey100
                                              : AppThemeData.grey800,
                                          fontSize: 22,
                                          fontFamily: AppThemeData.semiBold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Your menu is currently empty. Create your first product to start showcasing your offerings."
                                          .tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey500,
                                          fontSize: 16,
                                          fontFamily: AppThemeData.bold),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    RoundedButtonFill(
                                      title: "Add Product".tr,
                                      width: 55,
                                      height: 5.5,
                                      color: AppThemeData.secondary300,
                                      textColor: AppThemeData.grey50,
                                      onPress: () async {
                                        if ((Constant
                                                        .isSubscriptionModelApplied ==
                                                    true ||
                                                Constant.adminCommission
                                                        ?.isEnabled ==
                                                    true) &&
                                            Constant.userModel?.subscriptionPlan
                                                    ?.itemLimit !=
                                                '-1' &&
                                            int.parse(Constant
                                                                .userModel
                                                                ?.subscriptionPlan
                                                                ?.itemLimit !=
                                                            null &&
                                                        Constant
                                                                .userModel
                                                                ?.subscriptionPlan
                                                                ?.itemLimit
                                                                .toString() !=
                                                            "null"
                                                    ? "${Constant.userModel?.subscriptionPlan?.itemLimit}"
                                                    : '0') <=
                                                controller.productList.length) {
                                          ShowToastDialog.showToast(
                                              "Your current subscription plan has reached its maximum product limit. Upgrade now to add more products."
                                                  .tr);
                                        } else {
                                          Get.to(const AddProductScreen())!
                                              .then(
                                            (value) {
                                              if (value == true) {
                                                controller.getProduct();
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: ListView.builder(
                                  itemCount: controller.productList.length,
                                  itemBuilder: (context, index) {
                                    String price = "0.0";
                                    String disPrice = "0.0";
                                    List<String> selectedVariants = [];
                                    List<String> selectedIndexVariants = [];
                                    List<String> selectedIndexArray = [];
                                    if (controller
                                            .productList[index].itemAttribute !=
                                        null) {
                                      if (controller
                                          .productList[index]
                                          .itemAttribute!
                                          .attributes!
                                          .isNotEmpty) {
                                        for (var element in controller
                                            .productList[index]
                                            .itemAttribute!
                                            .attributes!) {
                                          if (element
                                              .attributeOptions!.isNotEmpty) {
                                            selectedVariants.add(controller
                                                .productList[index]
                                                .itemAttribute!
                                                .attributes![controller
                                                    .productList[index]
                                                    .itemAttribute!
                                                    .attributes!
                                                    .indexOf(element)]
                                                .attributeOptions![0]
                                                .toString());
                                            selectedIndexVariants.add(
                                                '${controller.productList[index].itemAttribute!.attributes!.indexOf(element)} _${controller.productList[index].itemAttribute!.attributes![0].attributeOptions![0].toString()}');
                                            selectedIndexArray.add(
                                                '${controller.productList[index].itemAttribute!.attributes!.indexOf(element)}_0');
                                          }
                                        }
                                      }
                                      if (controller.productList[index]
                                          .itemAttribute!.variants!
                                          .where((element) =>
                                              element.variantSku ==
                                              selectedVariants.join('-'))
                                          .isNotEmpty) {
                                        price = controller.productList[index]
                                                .itemAttribute!.variants!
                                                .where((element) =>
                                                    element.variantSku ==
                                                    selectedVariants.join('-'))
                                                .first
                                                .variantPrice ??
                                            '0';
                                        disPrice = '0';
                                      }
                                    } else {
                                      price = controller
                                          .productList[index].price
                                          .toString();
                                      disPrice = controller
                                          .productList[index].disPrice
                                          .toString();
                                    }

                                    bool isDisplayItemAlert = false;
                                    if ((Constant.isSubscriptionModelApplied ==
                                            true ||
                                        Constant.adminCommission?.isEnabled ==
                                            true)) {
                                      if (controller.userModel.value
                                              .subscriptionPlan?.itemLimit ==
                                          '-1') {
                                        isDisplayItemAlert = false;
                                      } else {
                                        isDisplayItemAlert = (index <
                                                    int.parse(controller
                                                            .userModel
                                                            .value
                                                            .subscriptionPlan
                                                            ?.itemLimit ??
                                                        '0') ==
                                                true)
                                            ? false
                                            : true;
                                      }
                                    }

                                    return InkWell(
                                      onTap: controller.productList[index].isAvailable == false
                                          ? null
                                          : () {
                                        Get.to(const AddProductScreen(),
                                                arguments: {
                                              "productModel":
                                                  controller.productList[index]
                                            })!
                                            .then(
                                          (value) {
                                            if (value == true) {
                                              controller.getProduct();
                                            }
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Opacity(
                                          opacity: controller.productList[index].isAvailable == false ? 0.5 : 1.0,
                                        child: Container(
                                          decoration: ShapeDecoration(
                                              color: controller.productList[index].isAvailable == false
                                                  ? Colors.grey[300]
                                                  : themeChange.getThem()
                                                ? AppThemeData.grey900
                                                : AppThemeData.grey50,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  16)),
                                                      child: Stack(
                                                        children: [
                                                          NetworkImageWidget(
                                                            imageUrl: controller
                                                                .productList[
                                                                    index]
                                                                .photo
                                                                .toString(),
                                                            fit: BoxFit.cover,
                                                            height: Responsive
                                                                .height(12,
                                                                    context),
                                                            width: Responsive
                                                                .width(24,
                                                                    context),
                                                          ),
                                                          Container(
                                                            height: Responsive
                                                                .height(12,
                                                                    context),
                                                            width: Responsive
                                                                .width(24,
                                                                    context),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                begin:
                                                                    const Alignment(
                                                                        -0.00,
                                                                        -1.00),
                                                                end:
                                                                    const Alignment(
                                                                        0, 1),
                                                                colors: [
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0),
                                                                  const Color(
                                                                      0xFF111827)
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            controller
                                                                .productList[
                                                                    index]
                                                                .name
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .semiBold,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          double.parse(
                                                                      disPrice) <=
                                                                  0
                                                              ? Text(
                                                                  Constant.amountShow(
                                                                      amount:
                                                                          price),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey900,
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .semiBold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                )
                                                              : Row(
                                                                  children: [
                                                                    Text(
                                                                      Constant.amountShow(
                                                                          amount:
                                                                              disPrice),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.grey50
                                                                            : AppThemeData.grey900,
                                                                        fontFamily:
                                                                            AppThemeData.semiBold,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Text(
                                                                      Constant.amountShow(
                                                                          amount:
                                                                              price),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        decoration:
                                                                            TextDecoration.lineThrough,
                                                                        decorationColor: themeChange.getThem()
                                                                            ? AppThemeData.grey500
                                                                            : AppThemeData.grey400,
                                                                        color: themeChange.getThem()
                                                                            ? AppThemeData.grey500
                                                                            : AppThemeData.grey400,
                                                                        fontFamily:
                                                                            AppThemeData.semiBold,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                          Row(
                                                            children: [
                                                              SvgPicture.asset(
                                                                "assets/icons/ic_star.svg",
                                                                colorFilter: const ColorFilter
                                                                    .mode(
                                                                    AppThemeData
                                                                        .warning300,
                                                                    BlendMode
                                                                        .srcIn),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "${Constant.calculateReview(reviewCount: controller.productList[index].reviewsCount!.toStringAsFixed(0), reviewSum: controller.productList[index].reviewsSum.toString())} (${controller.productList[index].reviewsCount!.toStringAsFixed(0)})",
                                                                style:
                                                                    TextStyle(
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey50
                                                                      : AppThemeData
                                                                          .grey900,
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .regular,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            controller
                                                                .productList[
                                                                    index]
                                                                .description
                                                                .toString(),
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .regular,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete, color: AppThemeData.danger300),
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              title: Text('Delete Product?'),
                                                              content: Text('Are you sure you want to delete this product?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.of(context).pop(),
                                                                  child: Text('Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                    controller.deleteProduct(index);
                                                                  },
                                                                  child: Text('Delete', style: TextStyle(color: AppThemeData.danger300)),
                                                          ),
                                                              ],
                                                            ),
                                                          );
                                                              },
                                                          ),
                                                        ],
                                                      ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  ProductToggles(
                                                    isPublished: controller.productList[index].publish ?? false,
                                                    isAvailable: controller.productList[index].isAvailable ?? true,
                                                    onPublishChanged: (val) => controller.updateList(index, controller.productList[index].publish!),
                                                    onAvailableChanged: (val) => controller.updateAvailableStatus(index, controller.productList[index].isAvailable ?? true),
                                                ),
                                                Visibility(
                                                  visible: isDisplayItemAlert,
                                                  child: Text(
                                                    "This product will not be displayed to customers due to your current subscription limitations."
                                                        .tr,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color:
                                                            themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .danger300
                                                                : AppThemeData
                                                                    .danger300,
                                                        fontSize: 12,
                                                        fontFamily: AppThemeData
                                                            .regular),
                                                  ),
                                                ),
                                              ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
          );
        });
  }
}
