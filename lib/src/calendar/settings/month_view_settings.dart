part of calendar;

/// The settings have properties which allow to customize the month view of
/// the [SfCalendar].
///
/// Allows to customize the [dayFormat], [numberOfWeeksInView],
/// [appointmentDisplayMode], [showAgenda], [appointmentDisplayCount]
/// [showTrailingAndLeadingDates] and [navigationDirection] in month view of
/// [SfCalendar].
///
/// ```dart
///
///Widget build(BuildContext context) {
///    return Container(
///      child: SfCalendar(
///        view: CalendarView.month,
///        monthViewSettings: MonthViewSettings(
///            dayFormat: 'EEE',
///            numberOfWeeksInView: 4,
///            appointmentDisplayCount: 2,
///            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
///            showAgenda: false,
///            navigationDirection: MonthNavigationDirection.horizontal),
///      ),
///    );
///  }
///
/// ```
@immutable
class MonthViewSettings {
  /// Creates a Month view settings for calendar.
  ///
  /// The properties allows to customize the month view of [SfCalendar].
  const MonthViewSettings(
      {this.appointmentDisplayCount = 4,
      this.numberOfWeeksInView = 6,
      this.appointmentDisplayMode = MonthAppointmentDisplayMode.indicator,
      this.showAgenda = false,
      this.navigationDirection = MonthNavigationDirection.horizontal,
      this.dayFormat = 'EE',
      this.agendaItemHeight = -1,
      bool showTrailingAndLeadingDates,
      double agendaViewHeight,
      MonthCellStyle monthCellStyle,
      AgendaStyle agendaStyle})
      : monthCellStyle = monthCellStyle ?? const MonthCellStyle(),
        showTrailingAndLeadingDates = showTrailingAndLeadingDates ?? true,
        agendaStyle = agendaStyle ?? const AgendaStyle(),
        agendaViewHeight = agendaViewHeight ?? -1;

  /// Formats the text in the [SfCalendar] month view view header.
  ///
  /// Defaults to `EE`.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        dataSource: _getCalendarDataSource(),
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  ///
  /// class DataSource extends CalendarDataSource {
  ///  DataSource(List<Appointment> source) {
  ///    appointments = source;
  ///  }
  /// }
  ///
  ///  DataSource _getCalendarDataSource() {
  ///    List<Appointment> appointments = <Appointment>[];
  ///    appointments.add(Appointment(
  ///      startTime: DateTime.now(),
  ///      endTime: DateTime.now().add(Duration(hours: 2)),
  ///      isAllDay: true,
  ///      subject: 'Meeting',
  ///      color: Colors.blue,
  ///      startTimeZone: '',
  ///      endTimeZone: '',
  ///    ));
  ///
  ///    return DataSource(appointments);
  ///  }
  ///
  final String dayFormat;

  /// The height for each appointment view to layout within this in month agenda
  /// view of [SfCalendar],.
  ///
  /// Defaults to `50`.
  ///
  /// ![month agenda item height as 70](https://help.syncfusion.com/flutter/calendar/images/monthview/agenda-item-height.png)
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          dayFormat: 'EEE',
  ///          numberOfWeeksInView: 4,
  ///          appointmentDisplayCount: 2,
  ///          agendaItemHeight: 50,
  ///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///          showAgenda: false,
  ///          navigationDirection: MonthNavigationDirection.horizontal,
  ///          agendaStyle: AgendaStyle(
  ///              backgroundColor: Colors.transparent,
  ///             appointmentTextStyle: TextStyle(
  ///                  color: Colors.white,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic
  ///              ),
  ///              dayTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic),
  ///              dateTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 25,
  ///                  fontWeight: FontWeight.bold,
  ///                  fontStyle: FontStyle.normal)
  ///         )),
  ///      ),
  ///    );
  /// }
  /// ```
  final double agendaItemHeight;

  /// Makes the leading and trailing dates visible for the [SfCalendar]
  /// month view.
  ///
  /// Defaults to `true`.
  ///
  /// Note: Leading and trailing dates are not visible when the
  /// [showTrailingAndLeadingDates] value is false and the
  /// [showTrailingAndLeadingDates] only applies when the
  /// [numberOfWeeksInView] is 6.
  ///
  /// Styling of the trailing and leading dates can be handled using the
  /// [MonthCellStyle.leadingDatesTextStyle] and
  /// [MonthCellStyle.trailingDatesTextStyle] properties in [MonthCellStyle].
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          showTrailingAndLeadingDates: false,
  ///         ),
  ///      ),
  ///    );
  /// }
  /// ```
  final bool showTrailingAndLeadingDates;

  /// Sets the style to customize [SfCalendar] month cells.
  ///
  /// Allows to customize the [MonthCellStyle.textStyle],
  /// [MonthCellStyle.trailingDatesTextStyle],
  /// [MonthCellStyle.leadingDatesTextStyle], [MonthCellStyle.backgroundColor],
  /// [MonthCellStyle.todayBackgroundColor],
  /// [MonthCellStyle.leadingDatesBackgroundColor] and
  /// [MonthCellStyle.trailingDatesBackgroundColor] in month cells of month view
  /// in calendar.
  ///
  /// Defaults to null.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        dataSource: _getCalendarDataSource(),
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  ///
  /// class DataSource extends CalendarDataSource {
  ///  DataSource(List<Appointment> source) {
  ///    appointments = source;
  ///  }
  /// }
  ///
  ///  DataSource _getCalendarDataSource() {
  ///    List<Appointment> appointments = <Appointment>[];
  ///    appointments.add(Appointment(
  ///      startTime: DateTime.now(),
  ///      endTime: DateTime.now().add(Duration(hours: 2)),
  ///      isAllDay: true,
  ///      subject: 'Meeting',
  ///      color: Colors.blue,
  ///      startTimeZone: '',
  ///      endTimeZone: '',
  ///    ));
  ///
  ///    return DataSource(appointments);
  ///  }S
  ///
  final MonthCellStyle monthCellStyle;

  /// Sets the style to customize [SfCalendar] month agenda view.
  ///
  /// Allows to customize the [AgendaStyle.backgroundColor],
  /// [AgendaStyle.dayTextStyle], [AgendaStyle.dateTextStyle] and
  /// [AgendaStyle.appointmentTextStyle] in month agenda view of calendar.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          dayFormat: 'EEE',
  ///          numberOfWeeksInView: 4,
  ///          appointmentDisplayCount: 2,
  ///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///          showAgenda: false,
  ///          navigationDirection: MonthNavigationDirection.horizontal,
  ///          agendaStyle: AgendaStyle(
  ///              backgroundColor: Colors.transparent,
  ///             appointmentTextStyle: TextStyle(
  ///                  color: Colors.white,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic
  ///              ),
  ///              dayTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic),
  ///              dateTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 25,
  ///                  fontWeight: FontWeight.bold,
  ///                  fontStyle: FontStyle.normal)
  ///         )),
  ///      ),
  ///    );
  /// }
  /// ```

  final AgendaStyle agendaStyle;

  /// The number of weeks to display in [ SfCalendar ]'s month view.
  ///
  /// Defaults to `6`.
  ///
  /// _Note:_ If this property is set to a value less than or equal to ' 4, '
  /// the trailing and lead dates style will not be updated.
  ///
  /// See also: [MonthCellStyle] to know about leading and trailing dates style.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal),
  ///      ),
  ///    );
  ///  }
  /// ```
  final int numberOfWeeksInView;

  /// The number of appointments to be displayed in month cell of [SfCalendar].
  ///
  /// Defaults to `4`.
  ///
  /// _Note:_ if the appointment count is less than the value set to this
  /// property in a particular day, then the month cell will display the
  /// appointments according to the number of appointments available on that
  /// day.
  ///
  /// Appointment indicator will be shown on the basis of date meetings, usable
  /// month cell size and indicator count. For eg, if the month cell size is
  /// less (available for only 4 dots) and the indicator count is 10, then 4
  /// indicators will be shown
  ///
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal),
  ///      ),
  ///    );
  ///  }
  /// ```
  final int appointmentDisplayCount;

  /// Defines the appointment display mode for the month cell in [SfCalendar].
  ///
  /// Defaults to `MonthAppointmentDisplayMode.indicator`.
  ///
  /// Also refer: [MonthAppointmentDisplayMode].
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal),
  ///      ),
  ///    );
  ///  }
  /// ```
  final MonthAppointmentDisplayMode appointmentDisplayMode;

  /// Makes [SfCalendar] agenda view visible on month view.
  ///
  /// The month view of [SfCalendar] will render agenda view along with month,
  /// to display the selected date's appointments.
  ///
  /// The [agendaHeight] property used to customize the height of the agenda
  /// view in month view.
  ///
  /// The [agendaItemHeight] property used to customize the height for each item
  /// in agenda view.
  ///
  /// Defaults to `false`.
  ///
  /// ![calendar month view with agenda](https://help.syncfusion.com/flutter/calendar/images/monthview/appointment-indicator-count.png)
  ///
  /// see also:
  /// [agendaHeight].
  /// [agendaItemHeight]
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: true,
  ///           navigationDirection: MonthNavigationDirection.horizontal),
  ///      ),
  ///    );
  ///  }
  /// ```
  final bool showAgenda;

  /// The height for agenda view to layout within this in [SfCalendar] month
  /// view.
  ///
  /// Defaults to `-1`.
  ///
  /// ![month agenda view height as 400](https://help.syncfusion.com/flutter/calendar/images/monthview/agendaview-height.png)
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: true,
  ///           agendaViewHeight: 120,
  ///           navigationDirection: MonthNavigationDirection.horizontal),
  ///      ),
  ///    );
  ///  }
  /// ```
  final double agendaViewHeight;

  /// The direction tht [SfCalendar] month view is navigating in.
  ///
  /// If it this property set as [MonthNavigationDirection.vertical] the
  /// [SfCalendar] month view will navigate to the previous/next views in the
  /// vertical direction instead of the horizontal direction.
  ///
  /// Defaults to `MonthNavigationDirection.horizontal`.
  ///
  /// Also refer: [MonthNavigationDirection].
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal),
  ///      ),
  ///    );
  ///  }
  /// ```
  final MonthNavigationDirection navigationDirection;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MonthViewSettings otherSetting = other;
    return otherSetting.dayFormat == dayFormat &&
        otherSetting.monthCellStyle == monthCellStyle &&
        otherSetting.agendaStyle == agendaStyle &&
        otherSetting.numberOfWeeksInView == numberOfWeeksInView &&
        otherSetting.appointmentDisplayCount == appointmentDisplayCount &&
        otherSetting.appointmentDisplayMode == appointmentDisplayMode &&
        otherSetting.agendaItemHeight == agendaItemHeight &&
        otherSetting.showAgenda == showAgenda &&
        otherSetting.agendaViewHeight == agendaViewHeight &&
        otherSetting.showTrailingAndLeadingDates ==
            showTrailingAndLeadingDates &&
        otherSetting.navigationDirection == navigationDirection;
  }

  @override
  int get hashCode {
    return hashValues(
      dayFormat,
      monthCellStyle,
      agendaStyle,
      numberOfWeeksInView,
      appointmentDisplayCount,
      appointmentDisplayMode,
      showAgenda,
      agendaViewHeight,
      agendaItemHeight,
      showTrailingAndLeadingDates,
      navigationDirection,
    );
  }
}

/// Sets the style to customize [SfCalendar] month agenda view.
///
/// Allows to customize the [backgroundColor], [dayTextStyle], [dateTextStyle]
/// and [appointmentTextStyle] in month agenda view of calendar.
///
/// ```dart
/// Widget build(BuildContext context) {
/// return Container(
///    child: SfCalendar(
///      view: CalendarView.month,
///      monthViewSettings: MonthViewSettings(
///          dayFormat: 'EEE',
///          numberOfWeeksInView: 4,
///          appointmentDisplayCount: 2,
///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
///          showAgenda: true,
///          navigationDirection: MonthNavigationDirection.horizontal,
///          agendaStyle: AgendaStyle(
///              backgroundColor: Colors.transparent,
///             appointmentTextStyle: TextStyle(
///                  color: Colors.white,
///                  fontSize: 13,
///                  fontStyle: FontStyle.italic
///              ),
///              dayTextStyle: TextStyle(color: Colors.red,
///                  fontSize: 13,
///                  fontStyle: FontStyle.italic),
///              dateTextStyle: TextStyle(color: Colors.red,
///                  fontSize: 25,
///                  fontWeight: FontWeight.bold,
///                  fontStyle: FontStyle.normal)
///         )),
///      ),
///    );
/// }
/// ```
@immutable
class AgendaStyle {
  /// Creates a agenda style for month view in calendar.
  ///
  /// The properties allows to customize the agenda view in month view  of
  /// [SfCalendar].
  const AgendaStyle(
      {this.appointmentTextStyle,
      this.dayTextStyle,
      this.dateTextStyle,
      this.backgroundColor});

  /// The text style for the text in the [Appointment] view in [SfCalendar]
  /// month agenda view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          dayFormat: 'EEE',
  ///          numberOfWeeksInView: 4,
  ///          appointmentDisplayCount: 2,
  ///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///          showAgenda: true,
  ///          navigationDirection: MonthNavigationDirection.horizontal,
  ///          agendaStyle: AgendaStyle(
  ///              backgroundColor: Colors.transparent,
  ///             appointmentTextStyle: TextStyle(
  ///                  color: Colors.white,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic
  ///              ),
  ///              dayTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic),
  ///              dateTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 25,
  ///                  fontWeight: FontWeight.bold,
  ///                  fontStyle: FontStyle.normal)
  ///         )),
  ///      ),
  ///    );
  /// }
  /// ```
  final TextStyle appointmentTextStyle;

  /// The text style for the text in the day text of [SfCalendar] month agenda
  /// view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          dayFormat: 'EEE',
  ///          numberOfWeeksInView: 4,
  ///          appointmentDisplayCount: 2,
  ///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///          showAgenda: true,
  ///          navigationDirection: MonthNavigationDirection.horizontal,
  ///          agendaStyle: AgendaStyle(
  ///              backgroundColor: Colors.transparent,
  ///             appointmentTextStyle: TextStyle(
  ///                  color: Colors.white,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic
  ///              ),
  ///              dayTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic),
  ///              dateTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 25,
  ///                  fontWeight: FontWeight.bold,
  ///                  fontStyle: FontStyle.normal)
  ///         )),
  ///      ),
  ///    );
  /// }
  /// ```
  final TextStyle dayTextStyle;

  /// The text style for the text in the date view of [SfCalendar] month agenda
  /// view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          dayFormat: 'EEE',
  ///          numberOfWeeksInView: 4,
  ///          appointmentDisplayCount: 2,
  ///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///          showAgenda: true,
  ///          navigationDirection: MonthNavigationDirection.horizontal,
  ///          agendaStyle: AgendaStyle(
  ///              backgroundColor: Colors.transparent,
  ///             appointmentTextStyle: TextStyle(
  ///                  color: Colors.white,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic
  ///              ),
  ///              dayTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic),
  ///              dateTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 25,
  ///                  fontWeight: FontWeight.bold,
  ///                  fontStyle: FontStyle.normal)
  ///         )),
  ///      ),
  ///    );
  /// }
  /// ```
  final TextStyle dateTextStyle;

  /// The background color to fill the background of the [SfCalendar] month
  /// agenda view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  /// return Container(
  ///    child: SfCalendar(
  ///      view: CalendarView.month,
  ///      monthViewSettings: MonthViewSettings(
  ///          dayFormat: 'EEE',
  ///          numberOfWeeksInView: 4,
  ///          appointmentDisplayCount: 2,
  ///          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///          showAgenda: true,
  ///          navigationDirection: MonthNavigationDirection.horizontal,
  ///          agendaStyle: AgendaStyle(
  ///              backgroundColor: Colors.transparent,
  ///             appointmentTextStyle: TextStyle(
  ///                  color: Colors.white,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic
  ///              ),
  ///              dayTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 13,
  ///                  fontStyle: FontStyle.italic),
  ///              dateTextStyle: TextStyle(color: Colors.red,
  ///                  fontSize: 25,
  ///                  fontWeight: FontWeight.bold,
  ///                  fontStyle: FontStyle.normal)
  ///         )),
  ///      ),
  ///    );
  /// }
  ///```
  final Color backgroundColor;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final AgendaStyle otherStyle = other;
    return otherStyle.appointmentTextStyle == appointmentTextStyle &&
        otherStyle.dayTextStyle == dayTextStyle &&
        otherStyle.dateTextStyle == dateTextStyle &&
        otherStyle.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode {
    return hashValues(
      appointmentTextStyle,
      dayTextStyle,
      dateTextStyle,
      backgroundColor,
    );
  }
}

/// Sets the style to customize [SfCalendar] month cells.
///
/// Allows to customize the [textStyle], [trailingDatesTextStyle],
/// [leadingDatesTextStyle], [backgroundColor], [todayBackgroundColor],
/// [leadingDatesBackgroundColor] and [trailingDatesBackgroundColor] in month
/// cells of month view in calendar.
///
/// ```dart
///Widget build(BuildContext context) {
///    return Container(
///      child: SfCalendar(
///        view: CalendarView.month,
///        dataSource: _getCalendarDataSource(),
///        monthViewSettings: MonthViewSettings(
///            dayFormat: 'EEE',
///            numberOfWeeksInView: 4,
///            appointmentDisplayCount: 2,
///            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
///            showAgenda: false,
///            navigationDirection: MonthNavigationDirection.horizontal,
///            monthCellStyle
///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
///            normal, fontSize: 15, color: Colors.black),
///                trailingDatesTextStyle: TextStyle(
///                    fontStyle: FontStyle.normal,
///                    fontSize: 15,
///                    color: Colors.black),
///                leadingDatesTextStyle: TextStyle(
///                    fontStyle: FontStyle.normal,
///                    fontSize: 15,
///                    color: Colors.black),
///                backgroundColor: Colors.red,
///                todayBackgroundColor: Colors.blue,
///                leadingDatesBackgroundColor: Colors.grey,
///                trailingDatesBackgroundColor: Colors.grey)),
///      ),
///    );
///  }
///
/// class DataSource extends CalendarDataSource {
///  DataSource(List<Appointment> source) {
///    appointments = source;
///  }
/// }
///
///  DataSource _getCalendarDataSource() {
///    List<Appointment> appointments = <Appointment>[];
///    appointments.add(Appointment(
///      startTime: DateTime.now(),
///      endTime: DateTime.now().add(Duration(hours: 2)),
///      isAllDay: true,
///      subject: 'Meeting',
///      color: Colors.blue,
///      startTimeZone: '',
///      endTimeZone: '',
///    ));
///
///    return DataSource(appointments);
///  }
///
@immutable
class MonthCellStyle {
  /// Creates a month cell style for month view in calendar.
  ///
  /// The properties allows to customize the month cell in month view  of
  /// [SfCalendar].
  const MonthCellStyle({
    this.backgroundColor,
    this.todayBackgroundColor,
    this.trailingDatesBackgroundColor,
    this.leadingDatesBackgroundColor,
    this.textStyle,
    @Deprecated('Moved the same [todayTextStyle] to SfCalendar class, '
        'use [todayTextStyle] property from SfCalendar class')
        // ignore: deprecated_member_use_from_same_package, deprecated_member_use
        this.todayTextStyle,
    this.trailingDatesTextStyle,
    this.leadingDatesTextStyle,
  });

  /// The text style for the text in the [SfCalendar] month cells.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final TextStyle textStyle;

  /// The text style for the text in the today cell of [SfCalendar] month view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  @Deprecated('Moved the same [todayTextStyle] to SfCalendar class, use '
      '[todayTextStyle] property from SfCalendar class')
  final TextStyle todayTextStyle;

  /// The text style for the text in the trailing dates cell of [SfCalendar]
  /// month view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final TextStyle trailingDatesTextStyle;

  /// The text style for the text in the leading dates cell of [SfCalendar]
  /// month view.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final TextStyle leadingDatesTextStyle;

  /// The background color to fill the background of the [SfCalendar]
  /// month cell.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final Color backgroundColor;

  /// The background color to fill the background of the [SfCalendar] today
  /// month cell.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final Color todayBackgroundColor;

  /// The background color to fill the background of the [SfCalendar] trailing
  /// dates month cell.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final Color trailingDatesBackgroundColor;

  /// The background color to fill the background of the [SfCalendar] leading
  /// dates month cell.
  ///
  /// Defaults to null.
  ///
  /// Using a [SfCalendarTheme] gives more fine-grained control over the
  /// appearance of various components of the calendar.
  ///
  /// ```dart
  ///Widget build(BuildContext context) {
  ///    return Container(
  ///      child: SfCalendar(
  ///        view: CalendarView.month,
  ///        monthViewSettings: MonthViewSettings(
  ///           dayFormat: 'EEE',
  ///           numberOfWeeksInView: 4,
  ///           appointmentDisplayCount: 2,
  ///           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
  ///           showAgenda: false,
  ///           navigationDirection: MonthNavigationDirection.horizontal,
  ///           monthCellStyle
  ///                : MonthCellStyle(textStyle: TextStyle(fontStyle: FontStyle.
  ///           normal, fontSize: 15, color: Colors.black),
  ///                trailingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                leadingDatesTextStyle: TextStyle(
  ///                    fontStyle: FontStyle.normal,
  ///                    fontSize: 15,
  ///                    color: Colors.black),
  ///                backgroundColor: Colors.red,
  ///                todayBackgroundColor: Colors.blue,
  ///                leadingDatesBackgroundColor: Colors.grey,
  ///                trailingDatesBackgroundColor: Colors.grey)),
  ///      ),
  ///    );
  ///  }
  /// ```
  final Color leadingDatesBackgroundColor;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    final MonthCellStyle otherStyle = other;
    return otherStyle.textStyle == textStyle &&
        otherStyle.trailingDatesTextStyle == trailingDatesTextStyle &&
        otherStyle.leadingDatesTextStyle == leadingDatesTextStyle &&
        otherStyle.backgroundColor == backgroundColor &&
        otherStyle.todayBackgroundColor == todayBackgroundColor &&
        otherStyle.trailingDatesBackgroundColor ==
            trailingDatesBackgroundColor &&
        otherStyle.leadingDatesBackgroundColor == leadingDatesBackgroundColor;
  }

  @override
  int get hashCode {
    return hashValues(
      textStyle,
      trailingDatesTextStyle,
      leadingDatesTextStyle,
      backgroundColor,
      todayBackgroundColor,
      trailingDatesBackgroundColor,
      leadingDatesBackgroundColor,
    );
  }
}
