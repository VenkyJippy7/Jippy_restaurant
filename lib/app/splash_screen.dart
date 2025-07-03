import 'package:restaurant/app/auth_screen/login_screen.dart';
import 'package:restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant/app/on_boarding_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/notification_service.dart';
import 'package:restaurant/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer;

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      developer.log('VideoSplashScreen: Initializing video player...');
      _videoPlayerController = VideoPlayerController.asset('assets/videos/output_splash.mp4');
      developer.log('VideoSplashScreen: Video controller created, initializing...');
      await _videoPlayerController.initialize();
      developer.log('VideoSplashScreen: Video initialized successfully');
      setState(() {
        _isVideoInitialized = true;
      });
      // Start playing the video
      await _videoPlayerController.play();
      developer.log('VideoSplashScreen: Video started playing');
      // Listen for video completion
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.position >= _videoPlayerController.value.duration) {
          developer.log('VideoSplashScreen: Video completed, waiting 2 seconds before navigating');
          // Add 2 second delay after video completion
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              developer.log('VideoSplashScreen: 2 seconds passed, navigating to main app');
              _navigateToMainApp();
            }
          });
        }
      });
      // Add a timeout fallback (in case video doesn't complete properly)
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isVideoInitialized) {
          developer.log('VideoSplashScreen: Timeout reached, navigating to main app');
          _navigateToMainApp();
        }
      });
    } catch (e) {
      developer.log('VideoSplashScreen: Error initializing video: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      // Wait a bit then navigate to main app
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToMainApp();
        }
      });
    }
  }

  void _navigateToMainApp() async {
    try {
      // Dispose the video controller
      if (_isVideoInitialized) {
        _videoPlayerController.dispose();
      }
      developer.log('VideoSplashScreen: Navigating to main app');
      // Use the same logic as SplashController to determine where to go
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(
          () => const OnBoardingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200),
        );
      } else {
        bool isLogin = await FireStoreUtils.isLogin();
        if (isLogin == true) {
          await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) async {
            if (value != null) {
              UserModel userModel = value;
              developer.log(userModel.toJson().toString());
              if (userModel.role == Constant.userRoleVendor) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  Get.offAll(
                    () => const DashBoardScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 1200),
                  );
                } else {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(
                    () => const LoginScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 1200),
                  );
                }
              } else {
                await FirebaseAuth.instance.signOut();
                Get.offAll(
                  () => const LoginScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 1200),
                );
              }
            }
          });
        } else {
          await FirebaseAuth.instance.signOut();
          Get.offAll(
            () => const LoginScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 1200),
          );
        }
      }
    } catch (e) {
      developer.log('VideoSplashScreen: Error navigating to main app: $e');
      // Fallback navigation to login screen
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1200),
      );
    }
  }

  @override
  void dispose() {
    try {
      if (_isVideoInitialized) {
        _videoPlayerController.dispose();
      }
    } catch (e) {
      developer.log('VideoSplashScreen: Error disposing video controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/ic_logo.png", 
                    width: 150, 
                    height: 150
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: AppThemeData.medium,
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error: $_errorMessage",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            : _isVideoInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoPlayerController.value.size.width,
                        height: _videoPlayerController.value.size.height,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    ),
                  )
                : Container(
                    // Show nothing while video is loading - just black screen
                    color: Colors.black,
                  ),
      ),
    );
  }
}

typedef SplashScreen = VideoSplashScreen;
