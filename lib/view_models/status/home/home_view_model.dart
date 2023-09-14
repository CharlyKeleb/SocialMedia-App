import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/services/pagination_service.dart';

class HomeViewModel extends ChangeNotifier {
  bool loading = false;
  bool loadingMore = false;
  bool loadMore = true;

  final FirestorePagination _pagination = FirestorePagination(30);
  List<DocumentSnapshot> data = [];

  ScrollController scrollController = ScrollController();

  listener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMore = true;
        notifyListeners();
        if (!loadingMore) {
          paginate();
          // Animate to bottom of list
          Timer(const Duration(milliseconds: 100), () {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.bounceIn,
            );
          });
        }
      }
    });
  }

  //get group feeds
  fetchFeeds() async {
    loading = true;
    notifyListeners();
    try {
      loadData();
      loading = false;
      notifyListeners();
      listener();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadData() async {
    if (!loading) return;
    loading = true;
    notifyListeners();
    final List<DocumentSnapshot> newData = await _pagination.fetchNextPage(
      data.isNotEmpty ? data.last : null,
    );
    data.addAll(newData);
    loading = false;
    notifyListeners();
  }

  //paginate
  paginate() async {
    if (!loading && !loadingMore && loadMore) {
      Timer(const Duration(milliseconds: 100), () {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
      loadingMore = true;
      notifyListeners();
      try {
        final List<DocumentSnapshot> newData = await _pagination.fetchNextPage(
          data.isNotEmpty ? data.last : null,
        );
        data.addAll(newData);
        loadMore = false;
        loadingMore = false;
        notifyListeners();
      } catch (e) {
        loadMore = false;
        loadingMore = false;
        notifyListeners();
        rethrow;
      }
    }
  }
}
