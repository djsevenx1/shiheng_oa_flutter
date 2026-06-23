import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/services/im_service.dart';
import '../../../app/themes/app_theme.dart';

class ChatListController extends GetxController {
  final ImService _im = ImService();
  final conversations = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  Future<void> loadConversations() async {
    isLoading.value = true;
    if (!_im.isLoggedIn) {
      conversations.value = [];
      isLoading.value = false;
      return;
    }
    try {
      final list = await EMClient.getInstance.chatManager.getAllConversations();
      conversations.value = list
          .map((c) => {
                'id': c.id,
                'name': (c.ext?['nickname'] ?? c.id).toString(),
                'lastMessage': c.lastMessage?.body.toString() ?? '',
                'time': c.lastMessage?.serverTime ?? 0,
                'unread': c.unreadCount,
              })
          .toList();
    } catch (e) {
      debugPrint('load conversations failed: $e');
    }
    isLoading.value = false;
  }
}

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChatListController());
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('消息'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.gray300),
                const SizedBox(height: 12),
                Text('暂无消息', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '需要后端签发环信 IM token',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: c.conversations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cv = c.conversations[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E88E5),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(cv['name']?.toString() ?? ''),
              subtitle: Text(cv['lastMessage']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: (cv['unread'] as int? ?? 0) > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: Text('${cv['unread']}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    )
                  : null,
            );
          },
        );
      }),
    );
  }
}
