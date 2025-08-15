import 'package:flutter/material.dart';
import 'package:soma/core/utils/story_reader.dart';
import 'dart:async';

class StoryDetailViewModel extends ChangeNotifier {
  final ScrollController _scrollController = ScrollController();
  final String storySlug;
  final String storyId;
  final int estimatedTimeInSeconds;

  bool _hasScrolledToBottom = false;
  bool _hasSpentEnoughTime = false;
  bool _hasMarkedAsRead = false;
  Timer? _timer;

  StoryDetailViewModel(
    this.storySlug,
    this.storyId,
    this.estimatedTimeInSeconds,
  ) {
    _scrollController.addListener(_onScroll);
    _startTimer();
  }

  ScrollController get scrollController => _scrollController;

  void _onScroll() {
    if (!_hasScrolledToBottom &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 20) {
      _hasScrolledToBottom = true;
      _checkAndMarkRead();
    }
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: estimatedTimeInSeconds), () {
      _hasSpentEnoughTime = true;
      _checkAndMarkRead();
    });
  }

  void _checkAndMarkRead() {
    if (!_hasMarkedAsRead && _hasScrolledToBottom && _hasSpentEnoughTime) {
      _hasMarkedAsRead = true;
      StoryReadTracker.markAsRead(storyId);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
