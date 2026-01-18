String formatTimeAgo(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 7) {
    return '${date.day}/${date.month}/${date.year}';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}
