part of calendar;

/// All day appointment views default height
const double _kAllDayLayoutHeight = 60;

/// All day appointment height
const double _kAllDayAppointmentHeight = 20;

/// The settings have properties which allow to customize the time slot views
/// of the [SfCalendar].
///
/// Allows to customize the [startHour], [endHour], [nonWorkingDays],
/// [timeInterval], [timeIntervalHeight], [timeFormat], [dateFormat],[dayFormat]
/// and [timeRulerSize] in time slot views of calendar.
///
/// ```dart
///Widget build(BuildContext context) {
///    return Container(
///      child: SfCalendar(
///        view: CalendarView.workWeek,
///        timeSlotViewSettings: TimeSlotViewSettings(
///            startHour: 10,
///            endHour: 20,
///            nonWorkingDays: <int>[
///              DateTime.saturday,
///              DateTime.sunday,
///              DateTime.friday
///            ],
///            timeInterval: Duration(minutes: 120),
///            timeIntervalHeight: 80,
///            timeFormat: 'h:mm',
///            dateFormat: 'd',
///            dayFormat: 'EEE',
///            timeRulerSize: 70),
///      ),
///    );
///  }
/// ```
@immutable
class TimeSlotViewSettings {
  /// Creates a timeslot view settings for calendar.
  ///
  /// The properties allows to customize the timeslot views of [SfCalendar].
  const TimeSlotViewSettings({
    this.startHour = 0,
    this.endHour = 24,
    this.nonWorkingDays = const <int>[DateTime.saturday, DateTime.sunday],
    this.timeFormat = 'h a',
    this.timeInterval = const Duration(minutes: 60),
    this.timeIntervalHeight = 40,
    this.timeIntervalWidth = -2,
    this.timelineAppointmentHeight = -1,
    this.minimumAppointmentDuration,
    this.dateFormat = 'd',
    this.dayFormat = 'EE',
    this.timeRulerSize = -1,
    this.timeTextStyle,
    this.hiddenHalfTime = false,
  });

  /// The start hour for the time slot views in [SfCalendar].
  ///
  /// Allows to change the start hour for the time slot views in calendar, every
  /// day in time slot view start from the hour set to this property.
  ///
  /// Defaults to `0`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double startHour;

  /// The end hour for the time slot views in [SfCalendar].
  ///
  /// Allows to change the end hour for the time slot views in calendar, every
  /// day in time slot view end at the hour set to this property.
  ///
  /// Defaults to `24`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double endHour;

  /// The non working days for the work week view and time slot work week
  /// view in [SfCalendar].
  ///
  /// Defaults to `<int>[DateTime.saturday, DateTime.sunday]`.
  ///
  /// _Note:_ This is only applicable only when the calendar view set as
  /// [CalendarView.workWeek] or [CalendarView.timelineWorkWeek] view.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final List<int> nonWorkingDays;

  /// The time interval between the time slots in time slot views of
  /// [SfCalendar].
  ///
  /// Defaults to `60 minutes`.
  ///
  /// _Note:_ If this property sets with minutes value, the [timeFormat] need to
  /// be modified to display the time labels with minutes.
  ///
  /// See also: [timeFormat].
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final Duration timeInterval;

  /// The height for each time slot to layout within this in time slot views of
  /// [SfCalendar].
  ///
  /// Defaults to `40`.
  ///
  /// _Note:_ Calendar time interval height can be adjusted based on screen
  /// height by changing the value of this property to -1. It will auto-fit to
  /// the screen height and width.
  ///
  /// This property applicable only for day, week and work week view of calendar
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double timeIntervalHeight;

  /// The width for each time slots in the timeline views of [SfCalendar].
  ///
  /// _Note:_ By setting the value of this property to -1, the calendar time
  /// slot width can be adjusted based on the screen width which will be
  /// auto-fit to the screen width.
  ///
  /// See also:
  /// To know more about time slot views in calendar [refer here](https://help.syncfusion.com/flutter/calendar/timeslot-views)
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.timelineWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalWidth: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double timeIntervalWidth;

  /// Formats for the time text in the time slot views of [SfCalendar].
  ///
  /// Defaults to `h a`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final String timeFormat;

  /// The height for an appointment view to layout within this in timeline views
  /// of [SfCalendar].
  ///
  /// _Note:_ It is applicable only when the calendar view set as
  /// [CalendarView.timelineDay], [CalendarView.timelineWeek] and
  /// [CalendarView.timelineWorkWeek] view in [SfCalendar].
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.timelineWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timelineAppointmentHeight: 50,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double timelineAppointmentHeight;

  /// Sets an arbitrary height for an appointment when it has minimum duration
  /// in time slot views of [SfCalendar].
  ///
  /// Defaults to null.
  ///
  /// _Note:_ The value set to this property will be applicable, only when an
  /// [Appointment] duration value lesser than this property.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 60),
  ///            minimumAppointmentDuration: Duration(minutes: 30),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final Duration minimumAppointmentDuration;

  /// Formats the date text in the view header view of [SfCalendar] time slot
  /// views.
  ///
  /// Defaults to `EE`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final String dateFormat;

  /// Formats the day text in the view header view of [SfCalendar] time slot
  /// views.
  ///
  /// Defaults to `d`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final String dayFormat;

  /// The width for the time ruler view to layout with in this in time slot
  /// views of [SfCalendar].
  ///
  /// Defaults to `-1`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.workWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double timeRulerSize;

  /// The text style for the time text in the time slots views of [SfCalendar].
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.timelineWeek,
  ///        timeSlotViewSettings: TimeSlotViewSettings(
  ///            startHour: 10,
  ///            endHour: 20,
  ///            nonWorkingDays: <int>[
  ///              DateTime.saturday,
  ///              DateTime.sunday,
  ///              DateTime.friday
  ///            ],
  ///            minimumAppointmentDuration: Duration(minutes: 30),
  ///            timeInterval: Duration(minutes: 120),
  ///            timeIntervalHeight: 80,
  ///            timeFormat: 'h:mm',
  ///            dateFormat: 'd',
  ///            dayFormat: 'EEE',
  ///            timeRulerSize: 70,
  ///            timeTextStyle: TextStyle(
  ///                fontSize: 15, fontStyle: FontStyle.italic,
  ///                     color: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final TextStyle timeTextStyle;

  final bool hiddenHalfTime;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final TimeSlotViewSettings otherStyle = other;
    return otherStyle.startHour == startHour &&
        otherStyle.endHour == endHour &&
        otherStyle.nonWorkingDays == nonWorkingDays &&
        otherStyle.timeInterval == timeInterval &&
        otherStyle.timeIntervalHeight == timeIntervalHeight &&
        otherStyle.timeIntervalWidth == timeIntervalWidth &&
        otherStyle.timeFormat == timeFormat &&
        otherStyle.timelineAppointmentHeight == timelineAppointmentHeight &&
        otherStyle.minimumAppointmentDuration == minimumAppointmentDuration &&
        otherStyle.dateFormat == dateFormat &&
        otherStyle.dayFormat == dayFormat &&
        otherStyle.timeRulerSize == timeRulerSize &&
        otherStyle.timeTextStyle == timeTextStyle &&
        otherStyle.hiddenHalfTime == hiddenHalfTime;
  }

  @override
  int get hashCode {
    return hashValues(
        startHour,
        endHour,
        nonWorkingDays,
        timeInterval,
        timeIntervalHeight,
        timeIntervalWidth,
        timeFormat,
        timelineAppointmentHeight,
        minimumAppointmentDuration,
        dateFormat,
        dayFormat,
        timeRulerSize,
        timeTextStyle,
        hiddenHalfTime);
  }
}
