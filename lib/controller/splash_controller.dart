import 'dart:async';
import 'package:restaurant/app/auth_screen/login_screen.dart';
import 'package:restaurant/app/dash_board_screens/app_not_access_screen.dart';
import 'package:restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant/app/on_boarding_screen.dart';
import 'package:restaurant/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/notification_service.dart';
import 'package:restaurant/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';

class SplashController extends GetxController {
  bool isRedirecting = false;

  @override
  void onInit() {
    // Comment out old timer implementation
    // Timer(const Duration(seconds: 3), () => redirectScreen());
    
    // New implementation with error handling
    Future.delayed(const Duration(seconds: 3), () {
      if (!isRedirecting) {
        redirectScreen();
      }
    });
    super.onInit();
  }

  redirectScreen() async {
    try {
      if (isRedirecting) return;
      isRedirecting = true;

      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(() => const OnBoardingScreen());
        return;
      }

      bool isLogin = await FireStoreUtils.isLogin();
      if (!isLogin) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(() => const LoginScreen());
        return;
      }

      final userProfile = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
      if (userProfile == null) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(() => const LoginScreen());
        return;
      }

      Constant.userModel = userProfile;
      
      if (Constant.userModel?.role != Constant.userRoleVendor) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(() => const LoginScreen());
        return;
      }

      if (Constant.userModel?.active != true) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(() => const LoginScreen());
        return;
      }

      // Update FCM token
      try {
        Constant.userModel?.fcmToken = await NotificationService.getToken();
        await FireStoreUtils.updateUser(Constant.userModel!);
      } catch (e) {
        print('Error updating FCM token: $e');
        // Continue even if FCM token update fails
      }

      bool isPlanExpire = false;
      if (Constant.userModel?.subscriptionPlan?.id != null) {
        if (Constant.userModel?.subscriptionExpiryDate == null) {
          isPlanExpire = Constant.userModel?.subscriptionPlan?.expiryDay != '-1';
        } else {
          DateTime expiryDate = Constant.userModel!.subscriptionExpiryDate!.toDate();
          isPlanExpire = expiryDate.isBefore(DateTime.now());
        }
      } else {
        isPlanExpire = true;
      }

      if (Constant.userModel?.subscriptionPlanId == null || isPlanExpire) {
        if (Constant.adminCommission?.isEnabled == false && 
            Constant.isSubscriptionModelApplied == false) {
          Get.offAll(() => const DashBoardScreen());
        } else {
          Get.offAll(() => const SubscriptionPlanScreen());
        }
      } else if (Constant.userModel?.subscriptionPlan?.features?.restaurantMobileApp == true) {
        Get.offAll(() => const DashBoardScreen());
      } else {
        Get.offAll(() => const AppNotAccessScreen());
      }
    } catch (e) {
      print('Error in redirectScreen: $e');
      ShowToastDialog.showToast('An error occurred. Please try again.');
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } finally {
      isRedirecting = false;
    }
  }
}
