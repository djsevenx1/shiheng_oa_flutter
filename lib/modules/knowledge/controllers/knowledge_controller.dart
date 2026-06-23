import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/repository/knowledge_repository.dart';

class KnowledgeController extends GetxController {
  final KnowledgeRepository _repo = KnowledgeRepository();

  final all = <KnowledgeEntry>[].obs;
  final filtered = <KnowledgeEntry>[].obs;
  final isLoading = false.obs;
  final keyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    all.value = await _repo.loadAll();
    filtered.value = all;
    isLoading.value = false;
  }

  Future<void> search(String q) async {
    keyword.value = q;
    if (q.trim().isEmpty) {
      filtered.value = all;
      return;
    }
    final result = await _repo.search(q.trim());
    filtered.value = result;
  }

  void clear() {
    keyword.value = '';
    filtered.value = all;
  }
}
