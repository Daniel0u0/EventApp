import 'package:flutter/material.dart';

class EventBookmarkWidget extends StatefulWidget {
  final bool isBookmarked; // This should be passed from your event model
  final Function(bool) onBookmarkToggle; // Callback to update bookmark status

  EventBookmarkWidget({required this.isBookmarked, required this.onBookmarkToggle});

  @override
  _EventBookmarkWidgetState createState() => _EventBookmarkWidgetState();
}

class _EventBookmarkWidgetState extends State<EventBookmarkWidget> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked; // Initialize the bookmark state
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked; // Toggle the bookmark state
    });
    widget.onBookmarkToggle(_isBookmarked); // Call the callback to update the state
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isBookmarked ? Icons.bookmark : Icons.bookmark_border, // Change icon based on bookmark state
        color: _isBookmarked ? Colors.black : Colors.grey, // Change color based on bookmark state
      ),
      onPressed: _toggleBookmark, // Handle bookmark toggle
    );
  }
}
