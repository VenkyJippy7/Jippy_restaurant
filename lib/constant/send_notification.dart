// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:restaurant/constant/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant/models/notification_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class SendNotification {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  static Future getCharacters() {
    return http.get(Uri.parse(Constant.jsonNotificationFileURL.toString()));
  }

  static Future<String> getAccessToken() async {
    Map<String, dynamic> jsonData = {};

    await getCharacters().then((response) {
      jsonData = json.decode(response.body);
    });
    final serviceAccountCredentials =
        ServiceAccountCredentials.fromJson(jsonData);

    final client =
        await clientViaServiceAccount(serviceAccountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  static Future<bool> sendFcmMessage(
      String type, String token, Map<String, dynamic>? payload) async {
    print('[FCM DEBUG] sendFcmMessage: type=$type, token=$token, payload=$payload');
    try {
      final String accessToken = await getAccessToken();
      debugPrint("accessToken=======>");
      debugPrint(accessToken);
      NotificationModel? notificationModel =
          await FireStoreUtils.getNotificationContent(type);
      print('[FCM DEBUG] NotificationModel: $notificationModel');
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {
                'body': notificationModel!.message ?? '',
                'title': notificationModel.subject ?? '',
              },
              'android': {
                'notification': {
                  'sound': 'order_ringtone.mp3',
                  'channel_id': 'order_channel',
                }
              },
              'data': payload,
            }
          },
        ),
      );
      print('[FCM DEBUG] Response status:  [32m${response.statusCode} [0m, body: ${response.body}');
      debugPrint("Notification=======>");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return true;
    } catch (e) {
      print('[FCM DEBUG] Error sending notification: $e');
      debugPrint(e.toString());
      return false;
    }
  }

  static sendOneNotification(
      {required String token,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {
    print('[FCM DEBUG] sendOneNotification: token=$token, title=$title, body=$body, payload=$payload');
    try {
      final String accessToken = await getAccessToken();
      debugPrint("accessToken=======>");
      debugPrint(accessToken);
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {'body': body, 'title': title},
              'android': {
                'notification': {
                  'sound': 'order_ringtone.mp3',
                  'channel_id': 'order_channel',
                }
              },
              'data': payload,
            }
          },
        ),
      );
      print('[FCM DEBUG] Response status:  [32m${response.statusCode} [0m, body: ${response.body}');
      debugPrint("Notification=======>");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return true;
    } catch (e) {
      print('[FCM DEBUG] Error sending notification: $e');
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> sendChatFcmMessage(String title, String message,
      String token, Map<String, dynamic>? payload) async {
    print('[FCM DEBUG] sendChatFcmMessage: token=$token, title=$title, message=$message, payload=$payload');
    try {
      final String accessToken = await getAccessToken();
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {'body': message, 'title': title},
              'android': {
                'notification': {
                  'sound': 'order_ringtone.mp3',
                  'channel_id': 'order_channel',
                }
              },
              'data': payload,
            }
          },
        ),
      );
      print('[FCM DEBUG] Response status:  [32m${response.statusCode} [0m, body: ${response.body}');
      debugPrint("Notification=======>");
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return true;
    } catch (e) {
      print('[FCM DEBUG] Error sending notification: $e');
      debugPrint(e.toString());
      return false;
    }
  }
}
