import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date)} WIB';
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 1) {
      if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      }
      return formatDateShort(date);
    } else if (difference.inDays == 1) {
      return 'kemarin';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'baru saja';
    }
  }

  static String formatCountdown(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
