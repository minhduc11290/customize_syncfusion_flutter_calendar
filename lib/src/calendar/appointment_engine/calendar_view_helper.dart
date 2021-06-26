part of calendar;

class CalendarViewHelper {
  /// Get the exact the time from the position and the date time includes
  /// minutes value.
  static double getTimeToPosition(Duration duration,
      TimeSlotViewSettings timeSlotViewSettings, double minuteHeight) {
    final Duration startDuration = Duration(
        hours: timeSlotViewSettings.startHour.toInt(),
        minutes: ((timeSlotViewSettings.startHour -
                    timeSlotViewSettings.startHour.toInt()) *
                60)
            .toInt());
    final Duration difference = duration - startDuration;
    if (difference.isNegative) {
      return 0;
    }

    return difference.inMinutes * minuteHeight;
  }

  /// Returns the time interval value based on the given start time, end time
  /// and time interval value of time slot view settings, the time interval will
  /// be auto adjust if the given time interval doesn't cover the given start
  /// and end time values, i.e: if the startHour set as 10 and endHour set as
  /// 20 and the timeInterval value given as 180 means we cannot divide the 10
  /// hours into 3  hours, hence the time interval will be auto adjusted to 200
  /// based on the given properties.
  static int getTimeInterval(TimeSlotViewSettings settings) {
    double defaultLinesCount = 24;
    double totalMinutes = 0;

    if (settings.startHour >= 0 &&
        settings.endHour >= settings.startHour &&
        settings.endHour <= 24) {
      defaultLinesCount = settings.endHour - settings.startHour;
    }

    totalMinutes = defaultLinesCount * 60;

    if (settings.timeInterval.inMinutes >= 0 &&
        settings.timeInterval.inMinutes <= totalMinutes &&
        totalMinutes.round() % settings.timeInterval.inMinutes.round() == 0) {
      return settings.timeInterval.inMinutes;
    } else if (settings.timeInterval.inMinutes >= 0 &&
        settings.timeInterval.inMinutes <= totalMinutes) {
      return _getNearestValue(settings.timeInterval.inMinutes, totalMinutes);
    } else {
      return 60;
    }
  }

  static int _getNearestValue(int timeInterval, double totalMinutes) {
    timeInterval++;
    if (totalMinutes.round() % timeInterval.round() == 0) {
      return timeInterval;
    }

    return _getNearestValue(timeInterval, totalMinutes);
  }
}
