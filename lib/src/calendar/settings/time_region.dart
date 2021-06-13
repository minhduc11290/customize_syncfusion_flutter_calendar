part of calendar;

/// It is used to highlight time slots on day, week, work week
/// and timeline views based on start and end time and
/// also used to restrict interaction on time slots.
///
/// Note: If time region have both the [text] and [iconData] then the region
/// will draw icon only.
///
/// ``` dart
///  Widget build(BuildContext context) {
///    return Container(
///      child: SfCalendar(
///        view: CalendarView.week,
///        specialRegions: _getTimeRegions(),
///      ),
///    );
///  }
///
///  List<TimeRegion> _getTimeRegions() {
///    final List<TimeRegion> regions = <TimeRegion>[];
///    regions.add(TimeRegion(
///        startTime: DateTime.now(),
///        endTime: DateTime.now().add(Duration(hours: 1)),
///        enablePointerInteraction: false,
///        color: Colors.grey.withOpacity(0.2),
///        text: 'Break'));
///
///    return regions;
///  }
///
///  ```
class TimeRegion {
  /// Creates a Time region for timeslot views in calendar.
  ///
  /// The time region used to highlight and block the specific timeslots in
  /// timeslots view of [SfCalendar].
  TimeRegion(
      {DateTime startTime,
      DateTime endTime,
      this.text,
      this.recurrenceRule,
      this.color,
      bool enablePointerInteraction,
      this.recurrenceExceptionDates,
      this.resourceIds,
      this.timeZone,
      this.iconData,
      this.textStyle})
      : enablePointerInteraction = enablePointerInteraction ?? true,
        startTime = startTime ?? DateTime.now(),
        endTime = endTime ?? DateTime.now();

  /// Used to specify the start time of the [TimeRegion].
  ///
  /// Defaults to 'DateTime.now()'.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final DateTime startTime;

  /// Used to specify the end time of the [TimeRegion].
  /// [endTime] value as always greater than or equal to [startTime] of
  /// [TimeRegion].
  ///
  /// Defaults to 'DateTime.now()'.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final DateTime endTime;

  /// Used to specify the text of [TimeRegion].
  ///
  /// Note: If time region have both the text and icon data then it will draw
  /// icon only.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final String text;

  /// Used to specify the recurrence of [TimeRegion].
  /// It used to recur the [TimeRegion] and it value like
  /// 'FREQ=DAILY;INTERVAL=1'
  ///
  /// Defaults to null.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        timeZone: 'Eastern Standard Time',
  ///        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
  ///        textStyle: TextStyle(color: Colors.black45, fontSize: 15),
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final String recurrenceRule;

  /// Used to specify the background color of [TimeRegion].
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final Color color;

  /// Used to allow or restrict the interaction of [TimeRegion].
  ///
  /// Note: This property only restrict the interaction on region and it does
  /// not restrict the following
  ///
  /// 1. Programmatic selection(if user update the selected date value
  /// dynamically)
  /// 2. Does not clear the selection when user select the region and
  /// dynamically change the [enablePointerInteraction] property to false.
  /// 3. It does not restrict appointment interaction when the appointment
  /// placed in the region.
  /// 4. It does not restrict the appointment rendering on specified region
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final bool enablePointerInteraction;

  /// Used to specify the time zone of [TimeRegion] start and end time.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        timeZone: 'Eastern Standard Time',
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final String timeZone;

  /// Used to specify the text style for [TimeRegion] text and icon.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        timeZone: 'Eastern Standard Time',
  ///        textStyle: TextStyle(color: Colors.black45, fontSize: 15),
  ///        color: Colors.grey.withOpacity(0.2),
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final TextStyle textStyle;

  /// Used to specify the icon of [TimeRegion].
  ///
  /// Note: If time region have both the text and icon then it will draw icon
  /// only.
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        color: Colors.grey.withOpacity(0.2),
  ///        iconData: Icons.free_breakfast));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final IconData iconData;

  /// Used to restrict the occurrence for an recurrence region.
  ///
  /// [TimeRegion] will recur on all possible dates given by the
  /// [recurrenceRule]. If it is not empty, then recurrence region not applied
  /// to specified collection of dates in [recurrenceExceptionDates].
  ///
  /// ``` dart
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.week,
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///
  ///  List<TimeRegion> _getTimeRegions() {
  ///    final List<TimeRegion> regions = <TimeRegion>[];
  ///    regions.add(TimeRegion(
  ///        startTime: DateTime.now(),
  ///        endTime: DateTime.now().add(Duration(hours: 1)),
  ///        enablePointerInteraction: false,
  ///        timeZone: 'Eastern Standard Time',
  ///        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
  ///        textStyle: TextStyle(color: Colors.black45, fontSize: 15),
  ///        color: Colors.grey.withOpacity(0.2),
  ///        recurrenceExceptionDates: [
  ///              DateTime.now().add(Duration(days: 2))
  ///            ],
  ///        text: 'Break'));
  ///
  ///    return regions;
  ///  }
  ///
  ///  ```
  final List<DateTime> recurrenceExceptionDates;

  /// The ids of the [CalendarResource] that shares this [TimeRegion].
  ///
  /// Based on this Id the [TimeRegion]s are grouped and arranged to each
  /// resource in calendar view.
  ///
  /// See also:
  ///
  /// * [CalendarResource], the resource data for calendar.
  /// * [ResourceViewSettings], the settings have properties which allow to
  /// customize the resource view of the [SfCalendar].
  /// * [CalendarResource.id], the unique id for the [CalendarResource] view of
  /// [SfCalendar].
  ///
  ///```dart
  ///
  /// @override
  ///  Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.timelineMonth,
  ///        dataSource: _getCalendarDataSource(),
  ///        specialRegions: _getTimeRegions(),
  ///      ),
  ///    );
  ///  }
  ///}
  ///
  ///class DataSource extends CalendarDataSource {
  ///  DataSource(List<Appointment> source,
  ///         List<CalendarResource> resourceColl) {
  ///    appointments = source;
  ///    resources = resourceColl;
  ///  }
  ///}
  ///
  ///DataSource _getCalendarDataSource() {
  ///  List<Appointment> appointments = <Appointment>[];
  ///  List<CalendarResource> resources = <CalendarResource>[];
  ///  appointments.add(Appointment(
  ///      startTime: DateTime.now(),
  ///      endTime: DateTime.now().add(Duration(hours: 2)),
  ///      isAllDay: true,
  ///      subject: 'Meeting',
  ///      color: Colors.blue,
  ///      resourceIds: <Object>['0001'],
  ///      startTimeZone: '',
  ///      endTimeZone: ''));
  ///
  ///  resources.add(
  ///      CalendarResource(displayName: 'John', id: '0001',
  ///                                         color: Colors.red));
  ///
  ///  return DataSource(appointments, resources);
  ///}
  ///
  ///List<TimeRegion> _getTimeRegions() {
  ///  final List<TimeRegion> regions = <TimeRegion>[];
  ///  regions.add(TimeRegion(
  ///      startTime: DateTime.now(),
  ///      endTime: DateTime.now().add(Duration(hours: 1)),
  ///      enablePointerInteraction: false,
  ///      color: Colors.grey.withOpacity(0.2),
  ///      resourceIds: <Object>['0001'],
  ///      text: 'Break'));
  ///
  ///  return regions;
  ///}
  ///
  /// ```
  final List<Object> resourceIds;

  /// Used to store the start date value with specified time zone.
  DateTime _actualStartTime;

  /// Used to store the end date value with specified time zone.
  DateTime _actualEndTime;

  /// Creates a copy of this [TimeRegion] but with the given fields replaced
  /// with the new values.
  TimeRegion copyWith(
      {DateTime startTime,
      DateTime endTime,
      String text,
      String recurrenceRule,
      Color color,
      bool enablePointerInteraction,
      List<DateTime> recurrenceExceptionDates,
      String timeZone,
      IconData iconData,
      TextStyle textStyle,
      List<Object> resourceIds}) {
    return TimeRegion(
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        color: color ?? this.color,
        recurrenceRule: recurrenceRule ?? this.recurrenceRule,
        textStyle: textStyle ?? this.textStyle,
        enablePointerInteraction:
            enablePointerInteraction ?? this.enablePointerInteraction,
        recurrenceExceptionDates:
            recurrenceExceptionDates ?? this.recurrenceExceptionDates,
        text: text ?? this.text,
        iconData: iconData ?? this.iconData,
        timeZone: timeZone ?? this.timeZone,
        resourceIds: resourceIds ?? this.resourceIds);
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final TimeRegion region = other;
    return region.textStyle == textStyle &&
        region.startTime == startTime &&
        region.endTime == endTime &&
        region.color == color &&
        region.recurrenceRule == recurrenceRule &&
        region.enablePointerInteraction == enablePointerInteraction &&
        region.recurrenceExceptionDates == recurrenceExceptionDates &&
        region.iconData == iconData &&
        region.timeZone == timeZone &&
        region.text == text;
  }

  @override
  int get hashCode {
    return hashValues(
        startTime,
        endTime,
        color,
        recurrenceRule,
        textStyle,
        enablePointerInteraction,
        recurrenceExceptionDates,
        text,
        iconData,
        timeZone);
  }
}
