import 'package:flutter/material.dart';

class EventBookmarkWidget extends StatefulWidget {
  final bool isBookmarked; // This should be passed from your event model
  final Function(bool) onBookmarkToggle; // Callback to update bookmark status

  const EventBookmarkWidget({
    Key? key,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  }) : super(key: key);

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

  @override
  void didUpdateWidget(EventBookmarkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the local state if the widget's isBookmarked value changes
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      setState(() {
        _isBookmarked = widget.isBookmarked;
      });
    }
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
        color: _isBookmarked ? Colors.black : Colors.grey, // Change color to black for bookmarked state
      ),
      onPressed: _toggleBookmark, // Handle bookmark toggle
    );
  }
}
