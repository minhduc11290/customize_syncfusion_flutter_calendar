part of calendar;

@immutable
class _CalendarView extends StatefulWidget {
  const _CalendarView(
      this.calendar,
      this.view,
      this.visibleDates,
      this.width,
      this.height,
      this.agendaSelectedDate,
      this.locale,
      this.calendarTheme,
      this.regions,
      this.blackoutDates,
      this.focusNode,
      this.removePicker,
      this.allowViewNavigation,
      this.controller,
      this.resourcePanelScrollController,
      this.resourceCollection,
      this.textScaleFactor,
      this.isMobilePlatform,
      {Key key,
      this.updateCalendarState,
      this.getCalendarState,
      this.scroll})
      : super(key: key);

  final List<DateTime> visibleDates;
  final List<TimeRegion> regions;
  final List<DateTime> blackoutDates;
  final SfCalendar calendar;
  final CalendarView view;
  final double width;
  final SfCalendarThemeData calendarTheme;
  final double height;
  final String locale;
  final ValueNotifier<DateTime> agendaSelectedDate;
  final CalendarController controller;
  final VoidCallback removePicker;
  final _UpdateCalendarState updateCalendarState;
  final _UpdateCalendarState getCalendarState;
  final bool allowViewNavigation;
  final FocusNode focusNode;
  final ScrollController resourcePanelScrollController;
  final List<CalendarResource> resourceCollection;
  final double textScaleFactor;
  final bool isMobilePlatform;

  final Function(double) scroll;

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView>
    with TickerProviderStateMixin {
  // line count is the total time slot lines to be drawn in the view
  // line count per view is for time line view which contains the time slot
  // count for per view
  double _horizontalLinesCount;

  //// all day scroll controller is used to identify the scrollposition for draw
  // all day selection.
  ScrollController _scrollController,
      _timelineViewHeaderScrollController,
      _timelineViewVerticalScrollController,
      _timelineRulerController;

  GlobalKey<_AppointmentLayoutState> _appointmentLayoutKey;
  AnimationController _timelineViewAnimationController;
  Animation<double> _timelineViewAnimation;
  Tween<double> _timelineViewTween;

  //// timeline header is used to implement the sticky view header in horizontal calendar view mode.
  _TimelineViewHeaderView _timelineViewHeader;
  _SelectionPainter _selectionPainter;
  double _allDayHeight = 0;
  double _timeIntervalHeight;
  _UpdateCalendarStateDetails _updateCalendarStateDetails;
  ValueNotifier<_SelectionDetails> _allDaySelectionNotifier;
  ValueNotifier<Offset> _viewHeaderNotifier,
      _calendarCellNotifier,
      _allDayNotifier,
      _appointmentHoverNotifier;
  ValueNotifier<bool> _selectionNotifier, _timelineViewHeaderNotifier;
  bool _isRTL;

  bool _isExpanded = false;
  DateTime _hoveringDate;

  /// The property to hold the resource value associated with the selected
  /// calendar cell.
  int _selectedResourceIndex = -1;
  AnimationController _animationController;
  Animation<double> _heightAnimation;
  Animation<double> _allDayExpanderAnimation;
  AnimationController _expanderAnimationController;

  /// Store the month widget instance used to update the month view
  /// when the visible appointment updated.
  _MonthViewWidget _monthView;

  ValueNotifier<int> _currentTimeNotifier;

  @override
  void initState() {
    _isExpanded = false;
    _appointmentLayoutKey = GlobalKey<_AppointmentLayoutState>();
    _hoveringDate = DateTime.now();
    _selectionNotifier = ValueNotifier<bool>(false);
    _timelineViewHeaderNotifier = ValueNotifier<bool>(false);
    _viewHeaderNotifier = ValueNotifier<Offset>(null)
      ..addListener(_timelineViewHoveringUpdate);
    _calendarCellNotifier = ValueNotifier<Offset>(null);
    _allDayNotifier = ValueNotifier<Offset>(null);
    _appointmentHoverNotifier = ValueNotifier<Offset>(null);
    _allDaySelectionNotifier = ValueNotifier<_SelectionDetails>(null);
    if (!_isTimelineView(widget.view) && widget.view != CalendarView.month) {
      _animationController = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);
      _heightAnimation =
          CurveTween(curve: Curves.easeIn).animate(_animationController)
            ..addListener(() {
              setState(() {
                /* Animates the all day panel height when
              expanding or collapsing */
              });
            });

      _expanderAnimationController = AnimationController(
          duration: const Duration(milliseconds: 100), vsync: this);
      _allDayExpanderAnimation =
          CurveTween(curve: Curves.easeIn).animate(_expanderAnimationController)
            ..addListener(() {
              setState(() {
                /* Animates the all day panel height when
              expanding or collapsing */
              });
            });
    }

    _updateCalendarStateDetails = _UpdateCalendarStateDetails();
    _timeIntervalHeight = _getTimeIntervalHeight(
        widget.calendar,
        widget.view,
        widget.width,
        widget.height,
        widget.visibleDates.length,
        _allDayHeight,
        widget.isMobilePlatform);
    if (widget.view != CalendarView.month) {
      _horizontalLinesCount = _getHorizontalLinesCount(
          widget.calendar.timeSlotViewSettings, widget.view);
      _scrollController =
          ScrollController(initialScrollOffset: 0, keepScrollOffset: true)
            ..addListener(_scrollListener);
      if (_isTimelineView(widget.view)) {
        _timelineRulerController =
            ScrollController(initialScrollOffset: 0, keepScrollOffset: true)
              ..addListener(_timeRulerListener);
        _timelineViewHeaderScrollController =
            ScrollController(initialScrollOffset: 0, keepScrollOffset: true);
        _timelineViewAnimationController = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
            animationBehavior: AnimationBehavior.normal);
        _timelineViewTween = Tween<double>(begin: 0.0, end: 0.1);
        _timelineViewAnimation = _timelineViewTween
            .animate(_timelineViewAnimationController)
              ..addListener(_scrollAnimationListener);
        _timelineViewVerticalScrollController =
            ScrollController(initialScrollOffset: 0, keepScrollOffset: true);
        _timelineViewVerticalScrollController
            .addListener(_updateResourceScroll);
        widget.resourcePanelScrollController
            ?.addListener(_updateResourcePanelScroll);
      }

      _scrollToPosition();
    }

    final DateTime today = DateTime.now();
    _currentTimeNotifier = ValueNotifier<int>(
        (today.day * 24 * 60) + (today.hour * 60) + today.minute);

    super.initState();
  }

  @override
  void didUpdateWidget(_CalendarView oldWidget) {
    if (widget.view != CalendarView.month) {
      _allDaySelectionNotifier ??= ValueNotifier<_SelectionDetails>(null);
      if (!_isTimelineView(widget.view)) {
        _updateTimeSlotView(oldWidget);
      }

      _updateHorizontalLineCount(oldWidget);

      _scrollController = _scrollController ??
          ScrollController(initialScrollOffset: 0, keepScrollOffset: true)
        ..addListener(_scrollListener);

      if (_isTimelineView(widget.view)) {
        _updateTimelineViews(oldWidget);
      }
    }

    /// Update the scroll position with following scenarios
    /// 1. View changed from month or schedule view.
    /// 2. View changed from timeline view(timeline day, timeline week,
    /// timeline work week) to timeslot view(day, week, work week).
    /// 3. View changed from timeslot view(day, week, work week) to
    /// timeline view(timeline day, timeline week, timeline work week).
    ///
    /// This condition used to restrict the following scenarios
    /// 1. View changed to month view.
    /// 2. View changed with in the day, week, work week
    /// (eg., view changed to week from day).
    /// 3. View changed with in the timeline day, timeline week, timeline
    /// work week(eg., view changed to timeline week from timeline day).
    if ((oldWidget.view == CalendarView.month ||
            oldWidget.view == CalendarView.schedule ||
            (oldWidget.view != widget.view && _isTimelineView(widget.view)) ||
            (_isTimelineView(oldWidget.view) &&
                !_isTimelineView(widget.view))) &&
        widget.view != CalendarView.month) {
      _scrollToPosition();
    }

    _timeIntervalHeight = _getTimeIntervalHeight(
        widget.calendar,
        widget.view,
        widget.width,
        widget.height,
        widget.visibleDates.length,
        _allDayHeight,
        widget.isMobilePlatform);

    /// Clear the all day panel selection when the calendar view changed
    /// Eg., if select the all day panel and switch to month view and again
    /// select the same month cell and move to day view then the view show
    /// calendar cell selection and all day panel selection.
    // if (oldWidget.view != widget.view) {
    //   _allDaySelectionNotifier = ValueNotifier<_SelectionDetails>(null);
    // }

    if ((oldWidget.view != widget.view ||
            oldWidget.width != widget.width ||
            oldWidget.height != widget.height) &&
        _selectionPainter._appointmentView != null) {
      _selectionPainter._appointmentView = null;
    }

    /// When view switched from any other view to timeline view, and resource
    /// enabled the selection must render the first resource view.
    widget.getCalendarState(_updateCalendarStateDetails);
    if (!_isTimelineView(oldWidget.view) &&
        _updateCalendarStateDetails._selectedDate != null &&
        _isResourceEnabled(widget.calendar.dataSource, widget.view) &&
        _selectedResourceIndex == -1) {
      _selectedResourceIndex = 0;
    }

    // if (oldWidget.calendar.showCurrentTimeIndicator !=
    //     widget.calendar.showCurrentTimeIndicator) {
    //   _position = 0;
    //   _children.clear();
    // }

    // if (oldWidget.calendar.showCurrentTimeIndicator !=
    //     widget.calendar.showCurrentTimeIndicator) {
    //   _timer?.cancel();
    //   _timer = _createTimer();
    // }

    if (!_isResourceEnabled(widget.calendar.dataSource, widget.view)) {
      _selectedResourceIndex = -1;
    }

    /// Clear the all day panel selection when the calendar view changed
    /// Eg., if select the all day panel and switch to month view and again
    /// select the same month cell and move to day view then the view show
    /// calendar cell selection and all day panel selection.
    if (oldWidget.view != widget.view) {
      _allDaySelectionNotifier = ValueNotifier<_SelectionDetails>(null);

      final DateTime today = DateTime.now();
      _currentTimeNotifier = ValueNotifier<int>(
          (today.day * 24 * 60) + (today.hour * 60) + today.minute);
      // _timer?.cancel();
      // _timer = null;
    }

    super.didUpdateWidget(oldWidget);
  }

  // Timer? _createTimer() {
  //   return widget.calendar.showCurrentTimeIndicator &&
  //           widget.view != CalendarView.month &&
  //           widget.view != CalendarView.timelineMonth
  //       ? Timer.periodic(Duration(seconds: 1), (Timer t) {
  //           final DateTime today = DateTime.now();
  //           final DateTime viewEndDate =
  //               widget.visibleDates[widget.visibleDates.length - 1];

  //           /// Check the today date is in between visible date range and
  //           /// today date hour and minute is 0(12 AM) because in day view
  //           /// current time as Feb 16, 23.59 and changed to Feb 17 then view
  //           /// will update both Feb 16 and 17 views.
  //           if (!isDateWithInDateRange(
  //                   widget.visibleDates[0], viewEndDate, today) &&
  //               !(today.hour == 0 &&
  //                   today.minute == 0 &&
  //                   isSameDate(addDays(today, -1), viewEndDate))) {
  //             return;
  //           }

  //           _currentTimeNotifier.value =
  //               (today.day * 24 * 60) + (today.hour * 60) + today.minute;
  //         })
  //       : null;
  // }

  Widget _getCurrentTimeIndicator(
      double timeLabelSize, double width, double height, bool isTimelineView) {
    if (!widget.calendar.showCurrentTimeIndicator ||
        widget.view == CalendarView.timelineMonth) {
      return Container(
        width: 0,
        height: 0,
      );
    }

    return RepaintBoundary(
      child: CustomPaint(
        painter: _CurrentTimeIndicator(
          _timeIntervalHeight,
          timeLabelSize,
          widget.calendar.timeSlotViewSettings,
          isTimelineView,
          widget.visibleDates,
          widget.calendar.todayHighlightColor ??
              widget.calendarTheme.todayHighlightColor,
          _isRTL,
          _currentTimeNotifier,
        ),
        size: Size(width, height),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _isRTL = _isRTLLayout(context);
    widget.getCalendarState(_updateCalendarStateDetails);
    switch (widget.view) {
      case CalendarView.schedule:
        return null;
      case CalendarView.month:
        return _getMonthView();
      case CalendarView.day:
      case CalendarView.week:
      case CalendarView.workWeek:
        return _getDayView();
      case CalendarView.timelineDay:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkWeek:
      case CalendarView.timelineMonth:
        return _getTimelineView();
    }

    return null;
  }

  @override
  void dispose() {
    if (_viewHeaderNotifier != null) {
      _viewHeaderNotifier.removeListener(_timelineViewHoveringUpdate);
    }

    if (_calendarCellNotifier != null) {
      _calendarCellNotifier.removeListener(_timelineViewHoveringUpdate);
    }

    if (_timelineViewAnimation != null) {
      _timelineViewAnimation.removeListener(_scrollAnimationListener);
    }

    if (_isTimelineView(widget.view) &&
        _timelineViewAnimationController != null) {
      _timelineViewAnimationController.dispose();
      _timelineViewAnimationController = null;
    }
    if (_scrollController != null) {
      _scrollController.removeListener(_scrollListener);
      _scrollController.dispose();
      _scrollController = null;
    }
    if (_timelineViewHeaderScrollController != null) {
      _timelineViewHeaderScrollController.dispose();
      _timelineViewHeaderScrollController = null;
    }
    if (_animationController != null) {
      _animationController.dispose();
      _animationController = null;
    }
    if (_timelineRulerController != null) {
      _timelineRulerController.dispose();
      _timelineRulerController = null;
    }

    if (_expanderAnimationController != null) {
      _expanderAnimationController.dispose();
      _expanderAnimationController = null;
    }

    super.dispose();
  }

  /// Updates the resource panel scroll based on timeline scroll in vertical
  /// direction.
  void _updateResourcePanelScroll() {
    if (_updateCalendarStateDetails._currentViewVisibleDates ==
        widget.visibleDates) {
      widget.removePicker();
    }

    if (widget.resourcePanelScrollController == null ||
        !_isResourceEnabled(widget.calendar.dataSource, widget.view)) {
      return;
    }

    if (widget.resourcePanelScrollController.offset !=
        _timelineViewVerticalScrollController.offset) {
      _timelineViewVerticalScrollController
          .jumpTo(widget.resourcePanelScrollController.offset);
    }
  }

  /// Updates the timeline view scroll in vertical direction based on resource
  /// panel scroll.
  void _updateResourceScroll() {
    if (_updateCalendarStateDetails._currentViewVisibleDates ==
        widget.visibleDates) {
      widget.removePicker();
    }

    if (widget.resourcePanelScrollController == null ||
        !_isResourceEnabled(widget.calendar.dataSource, widget.view)) {
      return;
    }

    if (widget.resourcePanelScrollController.offset !=
        _timelineViewVerticalScrollController.offset) {
      widget.resourcePanelScrollController
          .jumpTo(_timelineViewVerticalScrollController.offset);
    }
  }

  Widget _getMonthView() {
    return GestureDetector(
      child: MouseRegion(
        onEnter: _pointerEnterEvent,
        onExit: _pointerExitEvent,
        onHover: _pointerHoverEvent,
        child: _addMonthView(_isRTL, widget.locale),
      ),
      onTapUp: (TapUpDetails details) {
        _handleOnTapForMonth(details);
      },
      onLongPressStart: (LongPressStartDetails details) {
        _handleOnLongPressForMonth(details);
      },
    );
  }

  Widget _getDayView() {
    _allDayHeight = 0;

    final bool isCurrentView =
        _updateCalendarStateDetails._currentViewVisibleDates ==
            widget.visibleDates;
    if (widget.view == CalendarView.day) {
      final double viewHeaderHeight =
          _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
      if (isCurrentView) {
        _allDayHeight = _kAllDayLayoutHeight > viewHeaderHeight &&
                _updateCalendarStateDetails._allDayPanelHeight >
                    viewHeaderHeight
            ? _updateCalendarStateDetails._allDayPanelHeight >
                    _kAllDayLayoutHeight
                ? _kAllDayLayoutHeight
                : _updateCalendarStateDetails._allDayPanelHeight
            : viewHeaderHeight;
        if (_allDayHeight < _updateCalendarStateDetails._allDayPanelHeight) {
          _allDayHeight += _kAllDayAppointmentHeight;
        }
      } else {
        _allDayHeight = viewHeaderHeight;
      }
    } else if (isCurrentView) {
      _allDayHeight =
          _updateCalendarStateDetails._allDayPanelHeight > _kAllDayLayoutHeight
              ? _kAllDayLayoutHeight
              : _updateCalendarStateDetails._allDayPanelHeight;
      _allDayHeight = _allDayHeight * _heightAnimation.value;
    }

    return GestureDetector(
      child: MouseRegion(
        onEnter: _pointerEnterEvent,
        onHover: _pointerHoverEvent,
        onExit: _pointerExitEvent,
        child: _addDayView(
            widget.width,
            _timeIntervalHeight * _horizontalLinesCount,
            _isRTL,
            widget.locale,
            isCurrentView),
      ),
      onTapUp: (TapUpDetails details) {
        _handleOnTapForDay(details);
      },
      onLongPressStart: (LongPressStartDetails details) {
        _handleOnLongPressForDay(details);
      },
    );
  }

  Widget _getTimelineView() {
    return GestureDetector(
      child: MouseRegion(
        onEnter: _pointerEnterEvent,
        onHover: _pointerHoverEvent,
        onExit: _pointerExitEvent,
        child: _addTimelineView(
            _timeIntervalHeight *
                (_horizontalLinesCount * widget.visibleDates.length),
            widget.height,
            widget.locale),
      ),
      onTapUp: (TapUpDetails details) {
        _handleOnTapForTimeline(details);
      },
      onLongPressStart: (LongPressStartDetails details) {
        _handleOnLongPressForTimeline(details);
      },
    );
  }

  void _timelineViewHoveringUpdate() {
    if (!_isTimelineView(widget.view) && mounted) {
      return;
    }

    // Updates the timeline views based on mouse hovering position.
    _timelineViewHeaderNotifier.value = !_timelineViewHeaderNotifier.value;
  }

  void _scrollAnimationListener() {
    _scrollController.jumpTo(_timelineViewAnimation.value);
  }

  void _scrollToPosition() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.view == CalendarView.month) {
        return;
      }

      widget.getCalendarState(_updateCalendarStateDetails);
      final double scrollPosition = _getScrollPositionForCurrentDate(
          _updateCalendarStateDetails._currentDate);
      if (scrollPosition == -1) {
        return;
      }

      _scrollController.jumpTo(scrollPosition);
    });
  }

  double _getScrollPositionForCurrentDate(DateTime date) {
    final int visibleDatesCount = widget.visibleDates.length;
    if (!isDateWithInDateRange(widget.visibleDates[0],
        widget.visibleDates[visibleDatesCount - 1], date)) {
      return -1;
    }

    double timeToPosition = 0;
    if (!_isTimelineView(widget.view)) {
      timeToPosition =
          _timeToPosition(widget.calendar, date, _timeIntervalHeight);
    } else {
      for (int i = 0; i < visibleDatesCount; i++) {
        if (!isSameDate(date, widget.visibleDates[i])) {
          continue;
        }

        if (widget.view == CalendarView.timelineMonth) {
          timeToPosition = _timeIntervalHeight * i;
        } else {
          timeToPosition = (_getSingleViewWidthForTimeLineView(this) * i) +
              _timeToPosition(widget.calendar, date, _timeIntervalHeight);
        }

        break;
      }
    }

    if (_scrollController.hasClients) {
      if (timeToPosition > _scrollController.position.maxScrollExtent) {
        timeToPosition = _scrollController.position.maxScrollExtent;
      } else if (timeToPosition < _scrollController.position.minScrollExtent) {
        timeToPosition = _scrollController.position.minScrollExtent;
      }
    }

    return timeToPosition;
  }

  /// Used to retain the scrolled date time.
  void _retainScrolledDateTime() {
    if (widget.view == CalendarView.month) {
      return;
    }

    DateTime scrolledDate = widget.visibleDates[0];
    double scrolledPosition = 0;
    if (_isTimelineView(widget.view)) {
      final double singleViewWidth = _getSingleViewWidthForTimeLineView(this);

      /// Calculate the scrolled position date.
      scrolledDate = widget
          .visibleDates[_scrollController.position.pixels ~/ singleViewWidth];

      /// Calculate the scrolled hour position without visible date position.
      scrolledPosition = _scrollController.position.pixels % singleViewWidth;
    } else {
      /// Calculate the scrolled hour position.
      scrolledPosition = _scrollController.position.pixels;
    }

    /// Calculate the current horizontal line based on time interval height.
    final double columnIndex = scrolledPosition / _timeIntervalHeight;

    /// Calculate the time based on calculated horizontal position.
    final double time =
        ((_getTimeInterval(widget.calendar.timeSlotViewSettings) / 60) *
                columnIndex) +
            widget.calendar.timeSlotViewSettings.startHour;
    final int hour = time.toInt();
    final int minute = ((time - hour) * 60).round();
    scrolledDate = DateTime(
        scrolledDate.year, scrolledDate.month, scrolledDate.day, hour, minute);

    /// Update the scrolled position after the widget generated.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_getPositionFromDate(scrolledDate));
    });
  }

  /// Calculate the position from date.
  double _getPositionFromDate(DateTime date) {
    final int visibleDatesCount = widget.visibleDates.length;
    _timeIntervalHeight = _getTimeIntervalHeight(
        widget.calendar,
        widget.view,
        widget.width,
        widget.height,
        visibleDatesCount,
        _allDayHeight,
        widget.isMobilePlatform);
    double timeToPosition = 0;
    final bool isTimelineView = _isTimelineView(widget.view);
    if (!isTimelineView) {
      timeToPosition =
          _timeToPosition(widget.calendar, date, _timeIntervalHeight);
    } else {
      for (int i = 0; i < visibleDatesCount; i++) {
        if (!isSameDate(date, widget.visibleDates[i])) {
          continue;
        }

        if (widget.view == CalendarView.timelineMonth) {
          timeToPosition = _timeIntervalHeight * i;
        } else {
          timeToPosition = (_getSingleViewWidthForTimeLineView(this) * i) +
              _timeToPosition(widget.calendar, date, _timeIntervalHeight);
        }

        break;
      }
    }

    double maxScrollPosition = 0;
    if (!isTimelineView) {
      final double scrollViewHeight = widget.height -
          _allDayHeight -
          _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
      final double scrollViewContentHeight = _getHorizontalLinesCount(
              widget.calendar.timeSlotViewSettings, widget.view) *
          _timeIntervalHeight;
      maxScrollPosition = scrollViewContentHeight - scrollViewHeight;
    } else {
      final double scrollViewContentWidth = _getHorizontalLinesCount(
              widget.calendar.timeSlotViewSettings, widget.view) *
          _timeIntervalHeight *
          visibleDatesCount;
      maxScrollPosition = scrollViewContentWidth - widget.width;
    }

    return maxScrollPosition > timeToPosition
        ? timeToPosition
        : maxScrollPosition;
  }

  void _expandOrCollapseAllDay() {
    _isExpanded = !_isExpanded;
    if (_isExpanded) {
      _expanderAnimationController.forward();
    } else {
      _expanderAnimationController.reverse();
    }
  }

  /// Update the time slot view scroll based on time ruler view scroll in
  /// timeslot views.
  void _timeRulerListener() {
    if (!_isTimelineView(widget.view)) {
      return;
    }

    if (_timelineRulerController.offset != _scrollController.offset) {
      _scrollController.jumpTo(_timelineRulerController.offset);
    }
  }

  void _scrollListener() {
    if (_updateCalendarStateDetails._currentViewVisibleDates ==
        widget.visibleDates) {
      widget.removePicker();
    }

    if (_isTimelineView(widget.view)) {
      widget.getCalendarState(_updateCalendarStateDetails);
      if (_timelineViewHeader != null &&
          widget.view != CalendarView.timelineMonth) {
        _timelineViewHeaderNotifier.value = !_timelineViewHeaderNotifier.value;
      }

      if (_timelineRulerController.offset != _scrollController.offset) {
        _timelineRulerController.jumpTo(_scrollController.offset);
      }

      _timelineViewHeaderScrollController.jumpTo(_scrollController.offset);
    }

    if (widget.scroll != null) {
      widget.scroll(_scrollController.position.pixels);
    }
  }

  void _updateTimeSlotView(_CalendarView oldWidget) {
    _animationController ??= AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _heightAnimation ??=
        CurveTween(curve: Curves.easeIn).animate(_animationController)
          ..addListener(() {
            setState(() {
              /*Animates the all day panel when it's expanding or
        collapsing*/
            });
          });

    _updateCalendarStateDetails ??= _UpdateCalendarStateDetails();
    _expanderAnimationController ??= AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _allDayExpanderAnimation ??=
        CurveTween(curve: Curves.easeIn).animate(_expanderAnimationController)
          ..addListener(() {
            setState(() {
              /*Animates the all day panel when it's expanding or
        collapsing*/
            });
          });

    if (widget.view != CalendarView.day && _allDayHeight == 0) {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reset();
      }

      _animationController.forward();
    }
  }

  void _updateHorizontalLineCount(_CalendarView oldWidget) {
    if (widget.calendar.timeSlotViewSettings.startHour !=
            oldWidget.calendar.timeSlotViewSettings.startHour ||
        widget.calendar.timeSlotViewSettings.endHour !=
            oldWidget.calendar.timeSlotViewSettings.endHour ||
        _getTimeInterval(widget.calendar.timeSlotViewSettings) !=
            _getTimeInterval(oldWidget.calendar.timeSlotViewSettings) ||
        oldWidget.view == CalendarView.month ||
        oldWidget.view == CalendarView.timelineMonth ||
        oldWidget.view != CalendarView.timelineMonth &&
            widget.view == CalendarView.timelineMonth) {
      _horizontalLinesCount = _getHorizontalLinesCount(
          widget.calendar.timeSlotViewSettings, widget.view);
    } else {
      _horizontalLinesCount = _horizontalLinesCount ??
          _getHorizontalLinesCount(
              widget.calendar.timeSlotViewSettings, widget.view);
    }
  }

  void _updateTimelineViews(_CalendarView oldWidget) {
    _timelineRulerController = _timelineRulerController ??
        ScrollController(initialScrollOffset: 0, keepScrollOffset: true)
      ..addListener(_timeRulerListener);

    _timelineViewAnimationController = _timelineViewAnimationController ??
        AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
            animationBehavior: AnimationBehavior.normal);
    _timelineViewTween =
        _timelineViewTween ?? Tween<double>(begin: 0.0, end: 0.1);

    _timelineViewAnimation = _timelineViewAnimation ??
        _timelineViewTween.animate(_timelineViewAnimationController)
      ..addListener(_scrollAnimationListener);

    _timelineViewHeaderScrollController = _timelineViewHeaderScrollController ??
        ScrollController(initialScrollOffset: 0, keepScrollOffset: true);
    _timelineViewVerticalScrollController =
        ScrollController(initialScrollOffset: 0, keepScrollOffset: true);
    _timelineViewVerticalScrollController.addListener(_updateResourceScroll);
    widget.resourcePanelScrollController
        ?.addListener(_updateResourcePanelScroll);
  }

  void _getPainterProperties(_UpdateCalendarStateDetails details) {
    widget.getCalendarState(_updateCalendarStateDetails);
    details._allDayAppointmentViewCollection =
        _updateCalendarStateDetails._allDayAppointmentViewCollection;
    details._currentViewVisibleDates =
        _updateCalendarStateDetails._currentViewVisibleDates;
    details._visibleAppointments =
        _updateCalendarStateDetails._visibleAppointments;
    details._selectedDate = _updateCalendarStateDetails._selectedDate;
  }

  Widget _addAllDayAppointmentPanel(
      SfCalendarThemeData calendarTheme, bool isCurrentView) {
    final Color borderColor =
        widget.calendar.cellBorderColor ?? calendarTheme.cellBorderColor;
    final Widget shadowView = Divider(
      height: 1,
      thickness: 1,
      color: borderColor.withOpacity(borderColor.opacity * 0.5),
    );

    final double timeLabelWidth = _getTimeLabelWidth(
        widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);
    double topPosition =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    if (widget.view == CalendarView.day) {
      topPosition = _allDayHeight;
    }

    if (_allDayHeight == 0 ||
        (widget.view != CalendarView.day &&
            widget.visibleDates !=
                _updateCalendarStateDetails._currentViewVisibleDates)) {
      return Positioned(
          left: 0, right: 0, top: topPosition, height: 1, child: shadowView);
    }

    if (widget.view == CalendarView.day) {
      //// Default minimum view header width in day view as 50,so set 50
      //// when view header width less than 50.
      topPosition = 0;
    }

    double panelHeight = isCurrentView
        ? _updateCalendarStateDetails._allDayPanelHeight - _allDayHeight
        : 0;
    if (panelHeight < 0) {
      panelHeight = 0;
    }

    final double allDayExpanderHeight =
        _allDayHeight + (panelHeight * _allDayExpanderAnimation.value);
    return Positioned(
      left: 0,
      top: topPosition,
      right: 0,
      height: allDayExpanderHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: _isExpanded ? allDayExpanderHeight : _allDayHeight,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              children: <Widget>[
                _AllDayAppointmentLayout(
                    widget.calendar,
                    widget.view,
                    widget.visibleDates,
                    widget.visibleDates ==
                            _updateCalendarStateDetails._currentViewVisibleDates
                        ? _updateCalendarStateDetails._visibleAppointments
                        : null,
                    timeLabelWidth,
                    allDayExpanderHeight,
                    panelHeight > 0 &&
                        (_heightAnimation.value == 1 ||
                            widget.view == CalendarView.day),
                    _allDayExpanderAnimation.value != 0.0 &&
                        _allDayExpanderAnimation.value != 1,
                    _isRTL,
                    widget.calendarTheme,
                    _allDaySelectionNotifier,
                    _allDayNotifier,
                    widget.textScaleFactor,
                    widget.isMobilePlatform,
                    widget.width,
                    (widget.view == CalendarView.day &&
                                _updateCalendarStateDetails._allDayPanelHeight <
                                    _allDayHeight) ||
                            !isCurrentView
                        ? _allDayHeight
                        : _updateCalendarStateDetails._allDayPanelHeight,
                    updateCalendarState: (_UpdateCalendarStateDetails details) {
                  _getPainterProperties(details);
                }),
              ],
            ),
          ),
          Positioned(
              left: 0,
              top: allDayExpanderHeight - 1,
              right: 0,
              height: 1,
              child: shadowView),
        ],
      ),
    );
  }

  _AppointmentLayout _addAppointmentPainter(double width, double height,
      [double resourceItemHeight]) {
    final List<Appointment> visibleAppointments = widget.visibleDates ==
            _updateCalendarStateDetails._currentViewVisibleDates
        ? _updateCalendarStateDetails._visibleAppointments
        : null;
    return _AppointmentLayout(
      widget.calendar,
      widget.view,
      widget.visibleDates,
      ValueNotifier<List<Appointment>>(visibleAppointments),
      _timeIntervalHeight,
      widget.calendarTheme,
      _isRTL,
      _appointmentHoverNotifier,
      widget.resourceCollection,
      resourceItemHeight,
      widget.textScaleFactor,
      widget.isMobilePlatform,
      width,
      height,
      _getPainterProperties,
      key: _appointmentLayoutKey,
    );
  }

  // Returns the month view  as a child for the calendar view.
  Widget _addMonthView(bool isRTL, String locale) {
    final double viewHeaderHeight =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    final double height = widget.height - viewHeaderHeight;
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          height: viewHeaderHeight,
          child: Container(
            color: widget.calendar.viewHeaderStyle.backgroundColor ??
                widget.calendarTheme.viewHeaderBackgroundColor,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _ViewHeaderViewPainter(
                    widget.visibleDates,
                    widget.view,
                    widget.calendar.viewHeaderStyle,
                    widget.calendar.timeSlotViewSettings,
                    _getTimeLabelWidth(
                        widget.calendar.timeSlotViewSettings.timeRulerSize,
                        widget.view),
                    _getViewHeaderHeight(
                        widget.calendar.viewHeaderHeight, widget.view),
                    widget.calendar.monthViewSettings,
                    isRTL,
                    widget.locale,
                    widget.calendarTheme,
                    widget.calendar.todayHighlightColor ??
                        widget.calendarTheme.todayHighlightColor,
                    widget.calendar.todayTextStyle,
                    widget.calendar.cellBorderColor,
                    widget.calendar.minDate,
                    widget.calendar.maxDate,
                    _viewHeaderNotifier,
                    widget.textScaleFactor),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: viewHeaderHeight,
          right: 0,
          bottom: 0,
          child: RepaintBoundary(
              child: _CalendarMultiChildContainer(
            width: widget.width,
            height: height,
            children: [
              RepaintBoundary(child: _getMonthWidget(isRTL, height)),
              RepaintBoundary(
                  child: _addAppointmentPainter(widget.width, height)),
            ],
          )),
        ),
        Positioned(
          left: 0,
          top: viewHeaderHeight,
          right: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _addSelectionView(),
              size: Size(widget.width, height),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getMonthWidget(bool isRTL, double height) {
    final List<Appointment> visibleAppointments = widget.visibleDates ==
            _updateCalendarStateDetails._currentViewVisibleDates
        ? _updateCalendarStateDetails._visibleAppointments
        : null;
    _monthView = _MonthViewWidget(
        widget.visibleDates,
        widget.calendar.monthViewSettings.numberOfWeeksInView,
        widget.calendar.monthViewSettings.monthCellStyle,
        isRTL,
        widget.calendar.todayHighlightColor ??
            widget.calendarTheme.todayHighlightColor,
        widget.calendar.todayTextStyle,
        widget.calendar.cellBorderColor,
        widget.calendarTheme,
        _calendarCellNotifier,
        widget.calendar.monthViewSettings.showTrailingAndLeadingDates,
        widget.calendar.minDate,
        widget.calendar.maxDate,
        widget.calendar,
        widget.blackoutDates,
        widget.calendar.blackoutDatesTextStyle,
        widget.textScaleFactor,
        widget.calendar.monthCellBuilder,
        widget.width,
        height,
        ValueNotifier<List<Appointment>>(visibleAppointments));

    return _monthView;
  }

  // Returns the day view as a child for the calendar view.
  Widget _addDayView(double width, double height, bool isRTL, String locale,
      bool isCurrentView) {
    double viewHeaderWidth = widget.width;
    double viewHeaderHeight =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    final double timeLabelWidth = _getTimeLabelWidth(
        widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);
    if (widget.view == null || widget.view == CalendarView.day) {
      viewHeaderWidth = timeLabelWidth < 50 ? 50 : timeLabelWidth;
      viewHeaderHeight =
          _allDayHeight > viewHeaderHeight ? _allDayHeight : viewHeaderHeight;
    }

    double panelHeight = isCurrentView
        ? _updateCalendarStateDetails._allDayPanelHeight - _allDayHeight
        : 0;
    if (panelHeight < 0) {
      panelHeight = 0;
    }

    if (widget.view == CalendarView.week) {
      // viewHeaderWidth = 0;
      width = width - (timeLabelWidth < 50 ? 50 : timeLabelWidth);
    }

    final double allDayExpanderHeight =
        panelHeight * _allDayExpanderAnimation.value;

    return Container(
        //color: Colors.red,
        child: Stack(
      children: <Widget>[
        //_addAllDayAppointmentPanel(widget.calendarTheme, isCurrentView),

        widget.view != CalendarView.day
            ? Positioned(
                left: isRTL ? widget.width - viewHeaderWidth : 50,
                top: 0,
                //right: isRTL ? 0 : widget.width - viewHeaderWidth,
                right: 0,
                height: _getViewHeaderHeight(
                    widget.calendar.viewHeaderHeight, widget.view),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ViewHeaderViewPainter(
                        widget.visibleDates,
                        widget.view,
                        widget.calendar.viewHeaderStyle,
                        widget.calendar.timeSlotViewSettings,
                        0,
                        // _getTimeLabelWidth(
                        //     widget
                        //         .calendar.timeSlotViewSettings.timeRulerSize,
                        //     widget.view),
                        _getViewHeaderHeight(
                            widget.calendar.viewHeaderHeight, widget.view),
                        widget.calendar.monthViewSettings,
                        isRTL,
                        widget.locale,
                        widget.calendarTheme,
                        widget.calendar.todayHighlightColor ??
                            widget.calendarTheme.todayHighlightColor,
                        widget.calendar.todayTextStyle,
                        widget.calendar.cellBorderColor,
                        widget.calendar.minDate,
                        widget.calendar.maxDate,
                        _viewHeaderNotifier,
                        widget.textScaleFactor),
                  ),
                ),
              )
            : Container(),
        Positioned(
            left: 0,
            top: 0,
            width: 50,
            height: _getViewHeaderHeight(
                widget.calendar.viewHeaderHeight, widget.view),
            child: widget.view != CalendarView.day
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 1),
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  )
                : Container()),
        Positioned(
            top: (widget.view == CalendarView.day)
                ? viewHeaderHeight + allDayExpanderHeight
                : viewHeaderHeight + _allDayHeight + allDayExpanderHeight,
            left: (widget.view == CalendarView.day)
                ? 0
                : (timeLabelWidth < 50 ? 50 : timeLabelWidth),
            right: 0,
            bottom: 0,
            child: Container(
                //color: Colors.blue,
                child: Stack(children: [
              // RepaintBoundary(
              //   child: CustomPaint(
              //     painter: _TimeRulerView(
              //         _horizontalLinesCount,
              //         _timeIntervalHeight,
              //         widget.calendar.timeSlotViewSettings,
              //         widget.calendar.cellBorderColor,
              //         isRTL,
              //         widget.locale,
              //         widget.calendarTheme,
              //         _isTimelineView(widget.view),
              //         widget.visibleDates,
              //         widget.textScaleFactor),
              //     size: Size(timeLabelWidth, height),
              //   ),
              // ),
              Scrollbar(
                child: ListView(
                    padding: const EdgeInsets.all(0.0),
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    physics: const ClampingScrollPhysics(),
                    children: <Widget>[
                      Container(
                          child: Stack(children: <Widget>[
                        RepaintBoundary(
                            child: CustomPaint(
                          painter: _addSelectionView(),
                          size: Size(
                              width +
                                  (widget.view == CalendarView.day
                                      ? timeLabelWidth
                                      : timeLabelWidth),
                              height),
                        )),
                        RepaintBoundary(
                            child: _CalendarMultiChildContainer(
                                width: width,
                                height: height,
                                children: [
                              RepaintBoundary(
                                child: _TimeSlotWidget(
                                    widget.visibleDates,
                                    _horizontalLinesCount,
                                    _timeIntervalHeight,
                                    widget.view == CalendarView.day ? 0 : 0,
                                    widget.calendar.cellBorderColor,
                                    widget.calendarTheme,
                                    widget.calendar.timeSlotViewSettings,
                                    isRTL,
                                    widget.regions,
                                    _calendarCellNotifier,
                                    widget.textScaleFactor,
                                    widget.calendar.timeRegionBuilder,
                                    width,
                                    height,
                                    widget.view),
                              ),
                              RepaintBoundary(
                                  child: _addAppointmentPainter(width, height)),
                            ])),
                        _getCurrentTimeIndicator(
                            widget.view == CalendarView.day
                                ? -timeLabelWidth
                                : 0,
                            widget.view == CalendarView.day ? width : width,
                            height,
                            false),
                      ]))
                    ]),
              )
            ]))),
      ],
    ));
  }

  /// Updates the cell selection when the initial display date property of
  /// calendar has value, on this scenario the first resource cell must be
  /// selected;
  void _updateProgrammaticSelectedResourceIndex() {
    if (_updateCalendarStateDetails._selectedDate != null &&
        _selectedResourceIndex == -1) {
      if ((widget.view == CalendarView.timelineMonth &&
              (isSameDate(_updateCalendarStateDetails._selectedDate,
                  widget.calendar.initialSelectedDate))) ||
          (widget.view != CalendarView.timelineMonth &&
              (_isSameTimeSlot(_updateCalendarStateDetails._selectedDate,
                  widget.calendar.initialSelectedDate)))) {
        _selectedResourceIndex = 0;
      }
    }
  }

  // Returns the timeline view  as a child for the calendar view.
  Widget _addTimelineView(double width, double height, String locale) {
    width = width;
    final double viewHeaderHeight =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    final double timeLabelSize = _getTimeLabelWidth(
        widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);
    final bool isResourceEnabled =
        _isResourceEnabled(widget.calendar.dataSource, widget.view);
    double resourceItemHeight = 0;
    height -= (viewHeaderHeight + timeLabelSize);
    if (isResourceEnabled) {
      _updateProgrammaticSelectedResourceIndex();
      final double resourceViewSize = widget.calendar.resourceViewSettings.size;
      resourceItemHeight = _getResourceItemHeight(
          resourceViewSize,
          (widget.height - viewHeaderHeight - timeLabelSize),
          widget.calendar.resourceViewSettings,
          widget.calendar.dataSource.resources.length);
      height = resourceItemHeight * widget.resourceCollection.length;
    }
    return Stack(children: <Widget>[
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: viewHeaderHeight,
        child: Container(
          color: widget.calendar.viewHeaderStyle.backgroundColor ??
              widget.calendarTheme.viewHeaderBackgroundColor,
          child: _getTimelineViewHeader(width, viewHeaderHeight, widget.locale),
        ),
      ),
      Positioned(
          top: viewHeaderHeight,
          left: 0,
          right: 0,
          height: timeLabelSize,
          child: ListView(
            padding: const EdgeInsets.all(0.0),
            controller: _timelineRulerController,
            scrollDirection: Axis.horizontal,
            physics: _CustomNeverScrollableScrollPhysics(),
            children: <Widget>[
              RepaintBoundary(
                  child: CustomPaint(
                painter: _TimeRulerView(
                    _horizontalLinesCount,
                    _timeIntervalHeight,
                    widget.calendar.timeSlotViewSettings,
                    widget.calendar.cellBorderColor,
                    _isRTL,
                    locale,
                    widget.calendarTheme,
                    _isTimelineView(widget.view),
                    widget.visibleDates,
                    widget.textScaleFactor),
                size: Size(width, timeLabelSize),
              )),
            ],
          )),
      Positioned(
          top: viewHeaderHeight + timeLabelSize,
          left: 0,
          right: 0,
          bottom: 0,
          child: Scrollbar(
            child: ListView(
                padding: const EdgeInsets.all(0.0),
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: _CustomNeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                      width: width,
                      child: Stack(children: [
                        Scrollbar(
                            child: ListView(
                                padding: const EdgeInsets.all(0.0),
                                scrollDirection: Axis.vertical,
                                controller:
                                    _timelineViewVerticalScrollController,
                                physics: isResourceEnabled
                                    ? const ClampingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                children: [
                              Stack(children: <Widget>[
                                RepaintBoundary(
                                    child: _CalendarMultiChildContainer(
                                  width: width,
                                  height: height,
                                  children: [
                                    RepaintBoundary(
                                        child: _TimelineWidget(
                                            _horizontalLinesCount,
                                            widget.visibleDates,
                                            widget
                                                .calendar.timeSlotViewSettings,
                                            _timeIntervalHeight,
                                            widget.calendar.cellBorderColor,
                                            _isRTL,
                                            widget.calendarTheme,
                                            _calendarCellNotifier,
                                            _scrollController,
                                            widget.regions,
                                            resourceItemHeight,
                                            widget.resourceCollection,
                                            widget.textScaleFactor,
                                            widget.isMobilePlatform,
                                            widget.calendar.timeRegionBuilder,
                                            width,
                                            height)),
                                    RepaintBoundary(
                                        child: _addAppointmentPainter(
                                            width, height, resourceItemHeight))
                                  ],
                                )),
                                RepaintBoundary(
                                  child: CustomPaint(
                                    painter:
                                        _addSelectionView(resourceItemHeight),
                                    size: Size(width, height),
                                  ),
                                ),
                              ]),
                            ])),
                      ])),
                ]),
          )),
    ]);
  }

  //// Handles the onTap callback for month cells, and view header of month
  void _handleOnTapForMonth(TapUpDetails details) {
    _handleTouchOnMonthView(details, null);
  }

  /// Handles the tap and long press related functions for month view.
  void _handleTouchOnMonthView(
      TapUpDetails tapDetails, LongPressStartDetails longPressDetails) {
    widget.removePicker();
    double xDetails, yDetails;
    bool isTapCallback = false;
    if (tapDetails != null) {
      isTapCallback = true;
      xDetails = tapDetails.localPosition.dx;
      yDetails = tapDetails.localPosition.dy;
    } else if (longPressDetails != null) {
      xDetails = longPressDetails.localPosition.dx;
      yDetails = longPressDetails.localPosition.dy;
    }

    final double viewHeaderHeight =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    if (yDetails < viewHeaderHeight) {
      if (isTapCallback) {
        _handleOnTapForViewHeader(tapDetails, widget.width);
      } else if (!isTapCallback) {
        _handleOnLongPressForViewHeader(longPressDetails, widget.width);
      }
    } else if (yDetails > viewHeaderHeight) {
      if (!widget.focusNode.hasFocus) {
        widget.focusNode.requestFocus();
      }

      _AppointmentView appointmentView;
      bool isMoreTapped = false;
      if (!widget.isMobilePlatform &&
          widget.calendar.monthViewSettings.appointmentDisplayMode ==
              MonthAppointmentDisplayMode.appointment) {
        appointmentView = _appointmentLayoutKey.currentState
            ._getAppointmentViewOnPoint(xDetails, yDetails - viewHeaderHeight);
        isMoreTapped = appointmentView != null &&
            appointmentView.startIndex == -1 &&
            appointmentView.endIndex == -1 &&
            appointmentView.position == -1 &&
            appointmentView.maxPositions == -1;
      }

      if (appointmentView == null) {
        _drawSelection(xDetails, yDetails - viewHeaderHeight, 0);
      } else {
        _updateCalendarStateDetails._selectedDate = null;
        widget.agendaSelectedDate.value = null;
        _selectionPainter.selectedDate = null;
        _selectionPainter._appointmentView = appointmentView;
        _selectionNotifier.value = !_selectionNotifier.value;
      }

      widget.updateCalendarState(_updateCalendarStateDetails);
      final DateTime selectedDate =
          _getDateFromPosition(xDetails, yDetails - viewHeaderHeight, 0);
      if (appointmentView == null) {
        if (!isDateWithInDateRange(widget.calendar.minDate,
                widget.calendar.maxDate, selectedDate) ||
            _isDateInDateCollection(widget.blackoutDates, selectedDate)) {
          return;
        }

        final int currentMonth =
            widget.visibleDates[widget.visibleDates.length ~/ 2].month;

        /// Check the selected cell date as trailing or leading date when
        /// [SfCalendar] month not shown leading and trailing dates.
        if (!_isCurrentMonthDate(
            widget.calendar.monthViewSettings.numberOfWeeksInView,
            widget.calendar.monthViewSettings.showTrailingAndLeadingDates,
            currentMonth,
            selectedDate)) {
          return;
        }

        _handleMonthCellTapNavigation(selectedDate);
      }

      if ((!isTapCallback &&
              _shouldRaiseCalendarLongPressCallback(
                  widget.calendar.onLongPress)) ||
          (isTapCallback &&
              _shouldRaiseCalendarTapCallback(widget.calendar.onTap))) {
        final List<dynamic> selectedAppointments = appointmentView == null ||
                isMoreTapped
            ? _getSelectedAppointments(selectedDate)
            : <dynamic>[
                appointmentView.appointment._data ?? appointmentView.appointment
              ];
        final CalendarElement selectedElement = appointmentView == null
            ? CalendarElement.calendarCell
            : isMoreTapped
                ? CalendarElement.moreAppointmentRegion
                : CalendarElement.appointment;
        if (isTapCallback) {
          _raiseCalendarTapCallback(widget.calendar,
              date: selectedDate,
              appointments: selectedAppointments,
              element: selectedElement);
        } else {
          _raiseCalendarLongPressCallback(widget.calendar,
              date: selectedDate,
              appointments: selectedAppointments,
              element: selectedElement);
        }
      }
    }
  }

  void _handleMonthCellTapNavigation(DateTime date) {
    if (!widget.allowViewNavigation ||
        widget.view != CalendarView.month ||
        widget.calendar.monthViewSettings.showAgenda) {
      return;
    }

    widget.controller.view = CalendarView.day;
    widget.controller.displayDate = date;
  }

  //// Handles the onLongPress callback for month cells, and view header of month.
  void _handleOnLongPressForMonth(LongPressStartDetails details) {
    _handleTouchOnMonthView(null, details);
  }

  //// Handles the onTap callback for timeline view cells, and view header of timeline.
  void _handleOnTapForTimeline(TapUpDetails details) {
    _handleTouchOnTimeline(details, null);
  }

  /// Returns the index of resource value associated with the selected calendar
  /// cell in timeline views.
  int _getSelectedResourceIndex(
      double yPosition, double viewHeaderHeight, double timeLabelSize) {
    final int resourceCount = widget.calendar.dataSource != null &&
            widget.calendar.dataSource.resources != null
        ? widget.calendar.dataSource.resources.length
        : 0;
    final double resourceItemHeight = _getResourceItemHeight(
        widget.calendar.resourceViewSettings.size,
        widget.height - viewHeaderHeight - timeLabelSize,
        widget.calendar.resourceViewSettings,
        resourceCount);
    return (yPosition / resourceItemHeight).truncate();
  }

  /// Handles the tap and long press related functions for timeline view.
  void _handleTouchOnTimeline(
      TapUpDetails tapDetails, LongPressStartDetails longPressDetails) {
    widget.removePicker();
    double xDetails, yDetails;
    bool isTapCallback = false;
    if (tapDetails != null) {
      isTapCallback = true;
      xDetails = tapDetails.localPosition.dx;
      yDetails = tapDetails.localPosition.dy;
    } else if (longPressDetails != null) {
      xDetails = longPressDetails.localPosition.dx;
      yDetails = longPressDetails.localPosition.dy;
    }

    final double viewHeaderHeight =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);

    if (yDetails < viewHeaderHeight) {
      if (isTapCallback) {
        _handleOnTapForViewHeader(tapDetails, widget.width);
      } else if (!isTapCallback) {
        _handleOnLongPressForViewHeader(longPressDetails, widget.width);
      }
    } else if (yDetails > viewHeaderHeight) {
      if (!widget.focusNode.hasFocus) {
        widget.focusNode.requestFocus();
      }

      widget.getCalendarState(_updateCalendarStateDetails);
      DateTime selectedDate = _updateCalendarStateDetails._selectedDate;

      double xPosition = _scrollController.offset + xDetails;
      double yPosition = yDetails - viewHeaderHeight;
      final double timeLabelWidth = _getTimeLabelWidth(
          widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);

      if (yPosition < timeLabelWidth) {
        return;
      }

      yPosition -= timeLabelWidth;

      CalendarResource selectedResource;

      if (_isResourceEnabled(widget.calendar.dataSource, widget.view)) {
        yPosition += _timelineViewVerticalScrollController.offset;
        _selectedResourceIndex = _getSelectedResourceIndex(
            yPosition, viewHeaderHeight, timeLabelWidth);
        selectedResource =
            widget.calendar.dataSource.resources[_selectedResourceIndex];
      }

      _selectionPainter.selectedResourceIndex = _selectedResourceIndex;

      if (_isRTL) {
        xPosition = _scrollController.offset +
            (_scrollController.position.viewportDimension - xDetails);
        xPosition = (_scrollController.position.viewportDimension +
                _scrollController.position.maxScrollExtent) -
            xPosition;
      }

      final _AppointmentView appointmentView = _appointmentLayoutKey
          .currentState
          ._getAppointmentViewOnPoint(xPosition, yPosition);
      if (appointmentView == null) {
        _drawSelection(xDetails, yPosition, timeLabelWidth);
        selectedDate = _selectionPainter.selectedDate;
      } else {
        if (selectedDate != null) {
          selectedDate = null;
          _selectionPainter.selectedDate = selectedDate;
          _updateCalendarStateDetails._selectedDate = selectedDate;
        }

        _selectionPainter._appointmentView = appointmentView;
        _selectionNotifier.value = !_selectionNotifier.value;
      }

      widget.updateCalendarState(_updateCalendarStateDetails);

      if ((!isTapCallback &&
              _shouldRaiseCalendarLongPressCallback(
                  widget.calendar.onLongPress)) ||
          (isTapCallback &&
              _shouldRaiseCalendarTapCallback(widget.calendar.onTap))) {
        final DateTime selectedDate =
            _getDateFromPosition(xDetails, yDetails - viewHeaderHeight, 0);
        if (appointmentView == null) {
          if (!isDateWithInDateRange(widget.calendar.minDate,
                  widget.calendar.maxDate, selectedDate) ||
              (widget.view == CalendarView.timelineMonth &&
                  _isDateInDateCollection(
                      widget.calendar.blackoutDates, selectedDate))) {
            return;
          }

          /// Restrict the callback, while selected region as disabled
          /// [TimeRegion].
          if (!_isEnabledRegion(
              xDetails, selectedDate, _selectedResourceIndex)) {
            return;
          }

          if (isTapCallback) {
            _raiseCalendarTapCallback(widget.calendar,
                date: selectedDate,
                appointments: null,
                element: CalendarElement.calendarCell,
                resource: selectedResource);
          } else {
            _raiseCalendarLongPressCallback(widget.calendar,
                date: selectedDate,
                appointments: null,
                element: CalendarElement.calendarCell,
                resource: selectedResource);
          }
        } else {
          if (isTapCallback) {
            _raiseCalendarTapCallback(widget.calendar,
                date: selectedDate,
                appointments: <dynamic>[
                  appointmentView.appointment._data ??
                      appointmentView.appointment
                ],
                element: CalendarElement.appointment,
                resource: selectedResource);
          } else {
            _raiseCalendarLongPressCallback(widget.calendar,
                date: selectedDate,
                appointments: <dynamic>[
                  appointmentView.appointment._data ??
                      appointmentView.appointment
                ],
                element: CalendarElement.appointment,
                resource: selectedResource);
          }
        }
      }
    }
  }

  //// Handles the onLongPress callback for timeline view cells, and view header
  //// of timeline.
  void _handleOnLongPressForTimeline(LongPressStartDetails details) {
    _handleTouchOnTimeline(null, details);
  }

  void _updateAllDaySelection(_AppointmentView view, DateTime date) {
    if (_allDaySelectionNotifier != null &&
        _allDaySelectionNotifier.value != null &&
        view == _allDaySelectionNotifier.value.appointmentView &&
        isSameDate(date, _allDaySelectionNotifier.value.selectedDate)) {
      return;
    }

    _allDaySelectionNotifier?.value = _SelectionDetails(view, date);
  }

  //// Handles the onTap callback for day view cells, all day panel, and view
  //// header of day.
  void _handleOnTapForDay(TapUpDetails details) {
    _handleTouchOnDayView(details, null);
  }

  /// Handles the tap and long press related functions for day, week
  /// work week views.
  void _handleTouchOnDayView(
      TapUpDetails tapDetails, LongPressStartDetails longPressDetails) {
    widget.removePicker();
    double xDetails, yDetails;
    bool isTappedCallback = false;
    if (tapDetails != null) {
      isTappedCallback = true;
      xDetails = tapDetails.localPosition.dx;
      yDetails = tapDetails.localPosition.dy;
    } else if (longPressDetails != null) {
      xDetails = longPressDetails.localPosition.dx;
      yDetails = longPressDetails.localPosition.dy;
    }
    if (!widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    }

    widget.getCalendarState(_updateCalendarStateDetails);
    dynamic selectedAppointment;
    List<dynamic> selectedAppointments;
    CalendarElement targetElement;
    DateTime selectedDate = _updateCalendarStateDetails._selectedDate;
    final double timeLabelWidth = _getTimeLabelWidth(
        widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);
    print(timeLabelWidth);
    final double viewHeaderHeight = widget.view == CalendarView.day
        ? 0
        : _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    final double allDayHeight = _isExpanded
        ? _updateCalendarStateDetails._allDayPanelHeight
        : _allDayHeight;
    if (!_isRTL &&
        xDetails <= timeLabelWidth &&
        yDetails > viewHeaderHeight + allDayHeight) {
      return;
    }

    if (_isRTL &&
        xDetails >= widget.width - timeLabelWidth &&
        yDetails > viewHeaderHeight + allDayHeight) {
      return;
    }

    if (yDetails < viewHeaderHeight) {
      /// Check the touch position in time ruler view
      /// If RTL, time ruler placed at right side,
      /// else time ruler placed at left side.
      if ((!_isRTL && xDetails <= timeLabelWidth) ||
          (_isRTL && widget.width - xDetails <= timeLabelWidth)) {
        return;
      }

      if (isTappedCallback) {
        _handleOnTapForViewHeader(tapDetails, widget.width);
      } else if (!isTappedCallback) {
        _handleOnLongPressForViewHeader(longPressDetails, widget.width);
      }

      return;
    } else if (yDetails < viewHeaderHeight + allDayHeight) {
      /// Check the touch position in view header when [CalendarView] is day
      /// If RTL, view header placed at right side,
      /// else view header placed at left side.
      if (widget.view == CalendarView.day &&
          ((!_isRTL && xDetails <= timeLabelWidth) ||
              (_isRTL && widget.width - xDetails <= timeLabelWidth)) &&
          yDetails <
              _getViewHeaderHeight(
                  widget.calendar.viewHeaderHeight, widget.view)) {
        if (isTappedCallback) {
          _handleOnTapForViewHeader(tapDetails, widget.width);
        } else if (!isTappedCallback) {
          _handleOnLongPressForViewHeader(longPressDetails, widget.width);
        }

        return;
      } else if ((!_isRTL && timeLabelWidth >= xDetails) ||
          (_isRTL && xDetails > widget.width - timeLabelWidth)) {
        /// Perform expand or collapse when the touch position on
        /// expander icon in all day panel.
        _expandOrCollapseAllDay();
        return;
      }

      final double yPosition = yDetails - viewHeaderHeight;
      final _AppointmentView appointmentView = _getAllDayAppointmentOnPoint(
          _updateCalendarStateDetails._allDayAppointmentViewCollection,
          xDetails,
          yPosition);

      if (appointmentView == null) {
        targetElement = CalendarElement.allDayPanel;
        if (isTappedCallback) {
          selectedDate =
              _getTappedViewHeaderDate(tapDetails.localPosition, widget.width);
        } else {
          selectedDate = _getTappedViewHeaderDate(
              longPressDetails.localPosition, widget.width);
        }
      }

      /// Check the count position tapped or not
      bool isTappedOnCount = appointmentView != null &&
          _updateCalendarStateDetails._allDayPanelHeight > allDayHeight &&
          yPosition > allDayHeight - _kAllDayAppointmentHeight;

      /// Check the tap position inside the last appointment rendering position
      /// when the panel as collapsed and it does not psoition does not have
      /// appointment.
      /// Eg., If July 8 have 3 all day appointments spanned to July 9 and
      /// July 9 have 1 all day appointment spanned to July 10 then July 10
      /// appointment view does not shown and it only have count label.
      /// If user tap on count label then the panel does not have appointment
      /// view, because the view rendered after the end position, so calculate
      /// the visible date cell appointment and it have appointments after
      /// end position then perform expand operation.
      if (appointmentView == null &&
          selectedDate != null &&
          _updateCalendarStateDetails._allDayPanelHeight > allDayHeight &&
          yPosition > allDayHeight - _kAllDayAppointmentHeight) {
        final int currentSelectedIndex =
            _getVisibleDateIndex(widget.visibleDates, selectedDate);
        if (currentSelectedIndex != -1) {
          final List<_AppointmentView> selectedIndexAppointment =
              <_AppointmentView>[];
          for (int i = 0;
              i <
                  _updateCalendarStateDetails
                      ._allDayAppointmentViewCollection.length;
              i++) {
            final _AppointmentView currentView =
                _updateCalendarStateDetails._allDayAppointmentViewCollection[i];
            if (currentView.appointment == null) {
              continue;
            }
            if (currentView.startIndex <= currentSelectedIndex &&
                currentView.endIndex > currentSelectedIndex) {
              selectedIndexAppointment.add(currentView);
            }
          }

          int maxPosition = 0;
          if (selectedIndexAppointment.isNotEmpty) {
            maxPosition = selectedIndexAppointment
                .reduce((_AppointmentView currentAppView,
                        _AppointmentView nextAppView) =>
                    currentAppView.maxPositions > nextAppView.maxPositions
                        ? currentAppView
                        : nextAppView)
                .maxPositions;
          }
          final int endAppointmentPosition =
              allDayHeight ~/ _kAllDayAppointmentHeight;
          if (endAppointmentPosition < maxPosition) {
            isTappedOnCount = true;
          }
        }
      }

      if (appointmentView != null &&
          (yPosition < allDayHeight - _kAllDayAppointmentHeight ||
              _updateCalendarStateDetails._allDayPanelHeight <= allDayHeight ||
              appointmentView.position + 1 >= appointmentView.maxPositions)) {
        if (!isDateWithInDateRange(
                widget.calendar.minDate,
                widget.calendar.maxDate,
                appointmentView.appointment._actualStartTime) ||
            !isDateWithInDateRange(
                widget.calendar.minDate,
                widget.calendar.maxDate,
                appointmentView.appointment._actualEndTime)) {
          return;
        }
        if (selectedDate != null) {
          selectedDate = null;
          _selectionPainter.selectedDate = selectedDate;
          _updateCalendarStateDetails._selectedDate = selectedDate;
        }

        _selectionPainter._appointmentView = null;
        _selectionNotifier.value = !_selectionNotifier.value;
        selectedAppointment = appointmentView.appointment;
        selectedAppointments = null;
        targetElement = CalendarElement.appointment;
        _updateAllDaySelection(appointmentView, null);
      } else if (isTappedOnCount) {
        _expandOrCollapseAllDay();
        return;
      } else if (appointmentView == null) {
        _updateAllDaySelection(null, selectedDate);
        _selectionPainter.selectedDate = null;
        _selectionPainter._appointmentView = null;
        _selectionNotifier.value = !_selectionNotifier.value;
        _updateCalendarStateDetails._selectedDate = null;
      }
    } else {
      print("handleTap");
      print(xDetails);
      print(yDetails);
      xDetails = xDetails - (widget.view == CalendarView.week ? 50 : 0);
      final double yPosition =
          yDetails - viewHeaderHeight - allDayHeight + _scrollController.offset;
      final _AppointmentView appointmentView = _appointmentLayoutKey
          .currentState
          ._getAppointmentViewOnPoint(xDetails, yPosition);
      print("appointmentView");
      _allDaySelectionNotifier?.value = null;
      if (appointmentView == null) {
        if (_isRTL) {
          _drawSelection(xDetails, yDetails - viewHeaderHeight - allDayHeight,
              timeLabelWidth);
        } else {
          _drawSelection(xDetails - timeLabelWidth,
              yDetails - viewHeaderHeight - allDayHeight, timeLabelWidth);
        }
        targetElement = CalendarElement.calendarCell;
      } else {
        if (selectedDate != null) {
          selectedDate = null;
          _selectionPainter.selectedDate = selectedDate;
          _updateCalendarStateDetails._selectedDate = selectedDate;
        }

        _selectionPainter._appointmentView = appointmentView;
        _selectionNotifier.value = !_selectionNotifier.value;
        selectedAppointment = appointmentView.appointment;
        targetElement = CalendarElement.appointment;
      }
    }

    widget.updateCalendarState(_updateCalendarStateDetails);
    if ((!isTappedCallback &&
            _shouldRaiseCalendarLongPressCallback(
                widget.calendar.onLongPress)) ||
        (isTappedCallback &&
            _shouldRaiseCalendarTapCallback(widget.calendar.onTap))) {
      if (_selectionPainter.selectedDate != null &&
          targetElement != CalendarElement.allDayPanel) {
        selectedAppointments = null;

        final double yPosition = yDetails - viewHeaderHeight - allDayHeight;

        /// In LTR, remove the time ruler width value from the
        /// touch x position while calculate the selected date value.
        selectedDate = _getDateFromPosition(
            !_isRTL ? xDetails - timeLabelWidth : xDetails,
            yPosition,
            timeLabelWidth);

        if (!isDateWithInDateRange(
            widget.calendar.minDate, widget.calendar.maxDate, selectedDate)) {
          return;
        }

        /// Restrict the callback, while selected region as disabled
        /// [TimeRegion].
        if (targetElement == CalendarElement.calendarCell &&
            !_isEnabledRegion(
                yPosition, selectedDate, _selectedResourceIndex)) {
          return;
        }

        if (isTappedCallback) {
          _raiseCalendarTapCallback(widget.calendar,
              date: _selectionPainter.selectedDate,
              appointments: selectedAppointments,
              element: targetElement);
        } else {
          _raiseCalendarLongPressCallback(widget.calendar,
              date: _selectionPainter.selectedDate,
              appointments: selectedAppointments,
              element: targetElement);
        }
      } else if (selectedAppointment != null) {
        selectedAppointments = <dynamic>[
          selectedAppointment._data ?? selectedAppointment
        ];

        /// In LTR, remove the time ruler width value from the
        /// touch x position while calculate the selected date value.
        selectedDate = _getDateFromPosition(
            !_isRTL ? xDetails - timeLabelWidth : xDetails, 0, timeLabelWidth);

        if (isTappedCallback) {
          _raiseCalendarTapCallback(widget.calendar,
              date: selectedDate,
              appointments: selectedAppointments,
              element: CalendarElement.appointment);
        } else {
          _raiseCalendarLongPressCallback(widget.calendar,
              date: selectedDate,
              appointments: selectedAppointments,
              element: CalendarElement.appointment);
        }
      } else if (selectedDate != null &&
          targetElement == CalendarElement.allDayPanel) {
        if (isTappedCallback) {
          _raiseCalendarTapCallback(widget.calendar,
              date: selectedDate, appointments: null, element: targetElement);
        } else {
          _raiseCalendarLongPressCallback(widget.calendar,
              date: selectedDate, appointments: null, element: targetElement);
        }
      }
    }
  }

  /// Check the selected date region as enabled time region or not.
  bool _isEnabledRegion(double y, DateTime selectedDate, int resourceIndex) {
    if (widget.regions == null ||
        widget.regions.isEmpty ||
        widget.view == CalendarView.timelineMonth ||
        selectedDate == null) {
      return true;
    }

    final double timeIntervalSize = _getTimeIntervalHeight(
        widget.calendar,
        widget.view,
        widget.width,
        widget.height,
        widget.visibleDates.length,
        _allDayHeight,
        widget.isMobilePlatform);

    final double minuteHeight = timeIntervalSize /
        _getTimeInterval(widget.calendar.timeSlotViewSettings);
    final Duration startDuration = Duration(
        hours: widget.calendar.timeSlotViewSettings.startHour.toInt(),
        minutes: ((widget.calendar.timeSlotViewSettings.startHour -
                    widget.calendar.timeSlotViewSettings.startHour.toInt()) *
                60)
            .toInt());
    int minutes;
    if (_isTimelineView(widget.view)) {
      final double viewWidth = _timeIntervalHeight * _horizontalLinesCount;
      if (_isRTL) {
        minutes = ((_scrollController.offset +
                    (_scrollController.position.viewportDimension - y)) %
                viewWidth) ~/
            minuteHeight;
      } else {
        minutes = ((_scrollController.offset + y) % viewWidth) ~/ minuteHeight;
      }
    } else {
      minutes = (_scrollController.offset + y) ~/ minuteHeight;
    }

    final DateTime date = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, 0, minutes + startDuration.inMinutes, 0);
    for (int i = 0; i < widget.regions.length; i++) {
      final TimeRegion region = widget.regions[i];
      if (region.enablePointerInteraction ||
          region._actualStartTime.isAfter(date) ||
          region._actualEndTime.isBefore(date)) {
        continue;
      }

      /// Condition added ensure that the region is disabled only on the
      /// specified resource slot, for other resources it must be enabled.
      if (_isResourceEnabled(widget.calendar.dataSource, widget.view) &&
          !region.enablePointerInteraction &&
          resourceIndex != -1 &&
          region.resourceIds != null &&
          region.resourceIds.isNotEmpty &&
          !region.resourceIds
              .contains(widget.resourceCollection[resourceIndex].id)) {
        continue;
      }

      return false;
    }

    return true;
  }

  //// Handles the onLongPress callback for day view cells, all day panel and
  //// view header  of day.
  void _handleOnLongPressForDay(LongPressStartDetails details) {
    _handleTouchOnDayView(null, details);
  }

  //// Handles the on tap callback for view header
  void _handleOnTapForViewHeader(TapUpDetails details, double width) {
    final DateTime tappedDate =
        _getTappedViewHeaderDate(details.localPosition, width);
    _handleViewHeaderTapNavigation(tappedDate);
    if (!_shouldRaiseCalendarTapCallback(widget.calendar.onTap)) {
      return;
    }

    _raiseCalendarTapCallback(widget.calendar,
        date: tappedDate, element: CalendarElement.viewHeader);
  }

  //// Handles the on long press callback for view header
  void _handleOnLongPressForViewHeader(
      LongPressStartDetails details, double width) {
    final DateTime tappedDate =
        _getTappedViewHeaderDate(details.localPosition, width);
    _handleViewHeaderTapNavigation(tappedDate);
    if (!_shouldRaiseCalendarLongPressCallback(widget.calendar.onLongPress)) {
      return;
    }

    _raiseCalendarLongPressCallback(widget.calendar,
        date: tappedDate, element: CalendarElement.viewHeader);
  }

  void _handleViewHeaderTapNavigation(DateTime date) {
    if (!widget.allowViewNavigation ||
        widget.view == CalendarView.day ||
        widget.view == CalendarView.timelineDay ||
        widget.view == CalendarView.month) {
      return;
    }

    if (!isDateWithInDateRange(
            widget.calendar.minDate, widget.calendar.maxDate, date) ||
        (widget.controller.view == CalendarView.timelineMonth &&
            _isDateInDateCollection(widget.blackoutDates, date))) {
      return;
    }

    if (widget.view == CalendarView.week ||
        widget.view == CalendarView.workWeek) {
      widget.controller.view = CalendarView.day;
    } else {
      widget.controller.view = CalendarView.timelineDay;
    }

    widget.controller.displayDate = date;
  }

  DateTime _getTappedViewHeaderDate(Offset localPosition, double width) {
    int index = 0;
    final double timeLabelViewWidth = _getTimeLabelWidth(
        widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);
    if (!_isTimelineView(widget.view)) {
      double cellWidth = 0;
      if (widget.view != CalendarView.month) {
        cellWidth = (width - timeLabelViewWidth) / widget.visibleDates.length;

        /// Set index value as 0 when calendar view as day because day view hold
        /// single visible date.
        if (widget.view == CalendarView.day) {
          index = 0;
        } else {
          index = ((localPosition.dx - (_isRTL ? 0 : timeLabelViewWidth)) /
                  cellWidth)
              .truncate();
        }
      } else {
        cellWidth = width / _kNumberOfDaysInWeek;
        index = (localPosition.dx / cellWidth).truncate();
      }

      /// Calculate the RTL based value of index when the widget direction as
      /// RTL.
      if (_isRTL && widget.view != CalendarView.month) {
        index = widget.visibleDates.length - index - 1;
      } else if (_isRTL && widget.view == CalendarView.month) {
        index = _kNumberOfDaysInWeek - index - 1;
      }

      if (index < 0 || index >= widget.visibleDates.length) {
        return null;
      }

      return widget.visibleDates[index];
    } else {
      index = ((_scrollController.offset +
                  (_isRTL
                      ? _scrollController.position.viewportDimension -
                          localPosition.dx
                      : localPosition.dx)) /
              _getSingleViewWidthForTimeLineView(this))
          .truncate();

      if (index < 0 || index >= widget.visibleDates.length) {
        return null;
      }

      return widget.visibleDates[index];
    }
  }

  void _updateHoveringForAppointment(double xPosition, double yPosition) {
    if (_viewHeaderNotifier.value != null) {
      _viewHeaderNotifier.value = null;
    }

    if (_calendarCellNotifier.value != null) {
      _calendarCellNotifier.value = null;
    }

    if (_allDayNotifier.value != null) {
      _allDayNotifier.value = null;
    }

    if (_hoveringDate != null) {
      _hoveringDate = null;
    }

    _appointmentHoverNotifier.value = Offset(xPosition, yPosition);
  }

  void _updateHoveringForAllDayPanel(double xPosition, double yPosition) {
    if (_viewHeaderNotifier.value != null) {
      _viewHeaderNotifier.value = null;
    }

    if (_calendarCellNotifier.value != null) {
      _hoveringDate = null;
      _calendarCellNotifier.value = null;
    }

    if (_appointmentHoverNotifier.value != null) {
      _appointmentHoverNotifier.value = null;
    }

    if (_hoveringDate != null) {
      _hoveringDate = null;
    }

    _allDayNotifier.value = Offset(xPosition, yPosition);
  }

  /// Removes the view header hovering in multiple occasions, when the pointer
  /// hovering the disabled or blackout dates, and when the pointer moves out
  /// of the view header.
  void _removeViewHeaderHovering() {
    if (_hoveringDate != null) {
      _hoveringDate = null;
    }

    if (_viewHeaderNotifier.value != null) {
      _viewHeaderNotifier.value = null;
    }
  }

  void _removeAllWidgetHovering() {
    if (_hoveringDate != null) {
      _hoveringDate = null;
    }

    if (_viewHeaderNotifier.value != null) {
      _viewHeaderNotifier.value = null;
    }

    if (_calendarCellNotifier.value != null) {
      _hoveringDate = null;
      _calendarCellNotifier.value = null;
    }

    if (_allDayNotifier.value != null) {
      _allDayNotifier.value = null;
    }

    if (_appointmentHoverNotifier.value != null) {
      _appointmentHoverNotifier.value = null;
    }
  }

  void _updateHoveringForViewHeader(Offset localPosition, double xPosition,
      double yPosition, double viewHeaderHeight) {
    if (widget.calendar.onTap == null && widget.calendar.onLongPress == null) {
      final bool isViewNavigationEnabled =
          widget.calendar.allowViewNavigation &&
              widget.view != CalendarView.month &&
              widget.view != CalendarView.day &&
              widget.view != CalendarView.timelineDay;
      if (!isViewNavigationEnabled) {
        _removeAllWidgetHovering();
        return;
      }
    }

    if (yPosition < 0) {
      if (_hoveringDate != null) {
        _hoveringDate = null;
      }

      if (_viewHeaderNotifier.value != null) {
        _viewHeaderNotifier.value = null;
      }

      if (_calendarCellNotifier.value != null) {
        _calendarCellNotifier.value = null;
      }

      if (_allDayNotifier.value != null) {
        _allDayNotifier.value = null;
      }

      if (_appointmentHoverNotifier.value != null) {
        _appointmentHoverNotifier.value = null;
      }
    }

    final DateTime hoverDate = _getTappedViewHeaderDate(
        Offset(_isTimelineView(widget.view) ? localPosition.dx : xPosition,
            yPosition),
        widget.width);

    // Remove the hovering when the position not in cell regions.
    if (hoverDate == null) {
      _removeViewHeaderHovering();

      return;
    }

    if (!isDateWithInDateRange(
        widget.calendar.minDate, widget.calendar.maxDate, hoverDate)) {
      _removeViewHeaderHovering();

      return;
    }

    if (widget.view == CalendarView.timelineMonth &&
        _isDateInDateCollection(widget.blackoutDates, hoverDate)) {
      _removeViewHeaderHovering();

      return;
    }

    _hoveringDate = hoverDate;

    if (_calendarCellNotifier.value != null) {
      _calendarCellNotifier.value = null;
    }

    if (_allDayNotifier.value != null) {
      _allDayNotifier.value = null;
    }

    if (_appointmentHoverNotifier.value != null) {
      _appointmentHoverNotifier.value = null;
    }

    _viewHeaderNotifier.value = Offset(xPosition, yPosition);
  }

  void _updatePointerHover(Offset globalPosition) {
    if (widget.isMobilePlatform) {
      return;
    }

    final RenderBox box = context.findRenderObject();
    final Offset localPosition = box.globalToLocal(globalPosition);
    double viewHeaderHeight =
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view);
    final double timeLabelWidth = _getTimeLabelWidth(
        widget.calendar.timeSlotViewSettings.timeRulerSize, widget.view);
    double allDayHeight = _isExpanded
        ? _updateCalendarStateDetails._allDayPanelHeight
        : _allDayHeight;

    /// All day panel and view header are arranged horizontally,
    /// so get the maximum value from all day height and view header height and
    /// use the value instead of adding of view header height and all day
    /// height.
    if (widget.view == CalendarView.day) {
      if (allDayHeight > viewHeaderHeight) {
        viewHeaderHeight = allDayHeight;
      }

      allDayHeight = 0;
    }

    double xPosition;
    double yPosition;
    final bool isTimelineViews = _isTimelineView(widget.view);
    if (widget.view != CalendarView.month && !isTimelineViews) {
      /// In LTR, remove the time ruler width value from the
      /// touch x position while calculate the selected date from position.
      xPosition = _isRTL ? localPosition.dx : localPosition.dx - timeLabelWidth;

      if (localPosition.dy < viewHeaderHeight) {
        if (widget.view == CalendarView.day) {
          if ((_isRTL && localPosition.dx < widget.width - timeLabelWidth) ||
              (!_isRTL && localPosition.dx > timeLabelWidth)) {
            _updateHoveringForAllDayPanel(localPosition.dx, localPosition.dy);
            return;
          }

          _updateHoveringForViewHeader(
              localPosition,
              _isRTL ? widget.width - localPosition.dx : localPosition.dx,
              localPosition.dy,
              viewHeaderHeight);
          return;
        }

        _updateHoveringForViewHeader(localPosition, localPosition.dx,
            localPosition.dy, viewHeaderHeight);
        return;
      }

      double panelHeight =
          _updateCalendarStateDetails._allDayPanelHeight - _allDayHeight;
      if (panelHeight < 0) {
        panelHeight = 0;
      }

      final double allDayExpanderHeight =
          panelHeight * _allDayExpanderAnimation.value;
      final double allDayBottom = widget.view == CalendarView.day
          ? viewHeaderHeight
          : viewHeaderHeight + _allDayHeight + allDayExpanderHeight;
      if (localPosition.dy > viewHeaderHeight &&
          localPosition.dy < allDayBottom) {
        if ((_isRTL && localPosition.dx < widget.width - timeLabelWidth) ||
            (!_isRTL && localPosition.dx > timeLabelWidth)) {
          _updateHoveringForAllDayPanel(
              localPosition.dx, localPosition.dy - viewHeaderHeight);
        } else {
          _removeAllWidgetHovering();
        }

        return;
      }

      yPosition = localPosition.dy - (viewHeaderHeight + allDayHeight);

      final _AppointmentView appointment = _appointmentLayoutKey.currentState
          ._getAppointmentViewOnPoint(
              localPosition.dx, yPosition + _scrollController.offset);
      if (appointment != null) {
        _updateHoveringForAppointment(
            localPosition.dx, yPosition + _scrollController.offset);
        _hoveringDate = null;
        return;
      }
    } else {
      xPosition = localPosition.dx;

      /// Update the x position value with scroller offset and the value
      /// assigned to mouse hover position.
      /// mouse hover position value used for highlight the position
      /// on all the calendar views.
      if (isTimelineViews) {
        if (_isRTL) {
          xPosition = (_getSingleViewWidthForTimeLineView(this) *
                  widget.visibleDates.length) -
              (_scrollController.offset +
                  (_scrollController.position.viewportDimension -
                      localPosition.dx));
        } else {
          xPosition = localPosition.dx + _scrollController.offset;
        }
      }

      if (localPosition.dy < viewHeaderHeight) {
        _updateHoveringForViewHeader(
            localPosition, xPosition, localPosition.dy, viewHeaderHeight);
        return;
      }

      yPosition = localPosition.dy - viewHeaderHeight - timeLabelWidth;
      if (_isResourceEnabled(widget.calendar.dataSource, widget.view)) {
        yPosition += _timelineViewVerticalScrollController.offset;
      }

      final _AppointmentView appointment = _appointmentLayoutKey.currentState
          ._getAppointmentViewOnPoint(xPosition, yPosition);
      if (appointment != null) {
        _updateHoveringForAppointment(xPosition, yPosition);
        _hoveringDate = null;
        return;
      }
    }

    /// Remove the hovering when the position not in cell regions.
    if (yPosition < 0) {
      if (_hoveringDate != null) {
        _hoveringDate = null;
      }

      if (_calendarCellNotifier.value != null) {
        _calendarCellNotifier.value = null;
      }

      return;
    }

    final DateTime hoverDate = _getDateFromPosition(
        isTimelineViews ? localPosition.dx : xPosition,
        yPosition,
        timeLabelWidth);

    /// Remove the hovering when the position not in cell regions or non active
    /// cell regions.
    if (hoverDate == null ||
        !isDateWithInDateRange(
            widget.calendar.minDate, widget.calendar.maxDate, hoverDate)) {
      if (_hoveringDate != null) {
        _hoveringDate = null;
      }

      if (_calendarCellNotifier.value != null) {
        _calendarCellNotifier.value = null;
      }

      return;
    }

    /// Check the hovering month cell date is blackout date.
    if ((widget.view == CalendarView.month ||
            widget.view == CalendarView.timelineMonth) &&
        _isDateInDateCollection(widget.blackoutDates, hoverDate)) {
      if (_hoveringDate != null) {
        _hoveringDate = null;
      }

      /// Remove the existing cell hovering.
      if (_calendarCellNotifier.value != null) {
        _calendarCellNotifier.value = null;
      }

      /// Remove the existing appointment hovering.
      if (_appointmentHoverNotifier.value != null) {
        _appointmentHoverNotifier.value = null;
      }

      return;
    }

    final int hoveringResourceIndex =
        _getSelectedResourceIndex(yPosition, viewHeaderHeight, timeLabelWidth);

    /// Restrict the hovering, while selected region as disabled [TimeRegion].
    if (((widget.view == CalendarView.day ||
                widget.view == CalendarView.week ||
                widget.view == CalendarView.workWeek) &&
            !_isEnabledRegion(yPosition, hoverDate, hoveringResourceIndex)) ||
        (isTimelineViews &&
            !_isEnabledRegion(
                localPosition.dx, hoverDate, hoveringResourceIndex))) {
      if (_hoveringDate != null) {
        _hoveringDate = null;
      }

      if (_calendarCellNotifier.value != null) {
        _calendarCellNotifier.value = null;
      }
      return;
    }

    final int currentMonth =
        widget.visibleDates[widget.visibleDates.length ~/ 2].month;

    /// Check the selected cell date as trailing or leading date when
    /// [SfCalendar] month not shown leading and trailing dates.
    if (!_isCurrentMonthDate(
        widget.calendar.monthViewSettings.numberOfWeeksInView,
        widget.calendar.monthViewSettings.showTrailingAndLeadingDates,
        currentMonth,
        hoverDate)) {
      if (_hoveringDate != null) {
        _hoveringDate = null;
      }

      /// Remove the existing cell hovering.
      if (_calendarCellNotifier.value != null) {
        _calendarCellNotifier.value = null;
      }

      /// Remove the existing appointment hovering.
      if (_appointmentHoverNotifier.value != null) {
        _appointmentHoverNotifier.value = null;
      }

      return;
    }

    final bool isResourceEnabled =
        _isResourceEnabled(widget.calendar.dataSource, widget.view);

    /// If resource enabled the selected date or time slot can be same but the
    /// resource value differs hence to handle this scenario we are excluding
    /// the following conditions, if resource enabled.
    if (!isResourceEnabled) {
      if ((widget.view == CalendarView.month &&
              isSameDate(_hoveringDate, hoverDate) &&
              _viewHeaderNotifier.value == null) ||
          (widget.view != CalendarView.month &&
              _isSameTimeSlot(_hoveringDate, hoverDate) &&
              _viewHeaderNotifier.value == null)) {
        return;
      }
    }

    _hoveringDate = hoverDate;

    if (widget.view == CalendarView.month &&
        isSameDate(_selectionPainter.selectedDate, _hoveringDate)) {
      _calendarCellNotifier.value = null;
      return;
    } else if (widget.view != CalendarView.month &&
        _isSameTimeSlot(_selectionPainter.selectedDate, _hoveringDate) &&
        hoveringResourceIndex == _selectedResourceIndex) {
      _calendarCellNotifier.value = null;
      return;
    }

    if (widget.view != CalendarView.month && !isTimelineViews) {
      yPosition += _scrollController.offset;
    }

    if (_viewHeaderNotifier.value != null) {
      _viewHeaderNotifier.value = null;
    }

    if (_allDayNotifier.value != null) {
      _allDayNotifier.value = null;
    }

    if (_appointmentHoverNotifier.value != null) {
      _appointmentHoverNotifier.value = null;
    }

    _calendarCellNotifier.value = Offset(xPosition, yPosition);
  }

  void _pointerEnterEvent(PointerEnterEvent event) {
    _updatePointerHover(event.position);
  }

  void _pointerHoverEvent(PointerHoverEvent event) {
    _updatePointerHover(event.position);
  }

  void _pointerExitEvent(PointerExitEvent event) {
    _hoveringDate = null;
    _calendarCellNotifier.value = null;
    _viewHeaderNotifier.value = null;
    _appointmentHoverNotifier.value = null;
    _allDayNotifier.value = null;
  }

  _AppointmentView _getAllDayAppointmentOnPoint(
      List<_AppointmentView> appointmentCollection, double x, double y) {
    if (appointmentCollection == null) {
      return null;
    }

    _AppointmentView selectedAppointmentView;
    for (int i = 0; i < appointmentCollection.length; i++) {
      final _AppointmentView appointmentView = appointmentCollection[i];
      if (appointmentView.appointment != null &&
          appointmentView.appointmentRect != null &&
          appointmentView.appointmentRect.left <= x &&
          appointmentView.appointmentRect.right >= x &&
          appointmentView.appointmentRect.top <= y &&
          appointmentView.appointmentRect.bottom >= y) {
        selectedAppointmentView = appointmentView;
        break;
      }
    }

    return selectedAppointmentView;
  }

  List<dynamic> _getSelectedAppointments(DateTime selectedDate) {
    return (widget.calendar.dataSource != null &&
            !_isCalendarAppointment(widget.calendar.dataSource))
        ? _getCustomAppointments(_getSelectedDateAppointments(
            _updateCalendarStateDetails._appointments,
            widget.calendar.timeZone,
            selectedDate))
        : (_getSelectedDateAppointments(
            _updateCalendarStateDetails._appointments,
            widget.calendar.timeZone,
            selectedDate));
  }

  DateTime _getDateFromPositionForMonth(
      double cellWidth, double cellHeight, double x, double y) {
    final int rowIndex = (x / cellWidth).truncate();
    final int columnIndex = (y / cellHeight).truncate();
    int index = 0;
    if (_isRTL) {
      index = (columnIndex * _kNumberOfDaysInWeek) +
          (_kNumberOfDaysInWeek - rowIndex) -
          1;
    } else {
      index = (columnIndex * _kNumberOfDaysInWeek) + rowIndex;
    }

    if (index < 0 || index >= widget.visibleDates.length) {
      return null;
    }

    return widget.visibleDates[index];
  }

  DateTime _getDateFromPositionForDay(
      double cellWidth, double cellHeight, double x, double y) {
    final int columnIndex =
        ((_scrollController.offset + y) / cellHeight).truncate();
    final double time =
        ((_getTimeInterval(widget.calendar.timeSlotViewSettings) / 60) *
                columnIndex) +
            widget.calendar.timeSlotViewSettings.startHour;
    final int hour = time.toInt();
    final int minute = ((time - hour) * 60).round();
    return DateTime(widget.visibleDates[0].year, widget.visibleDates[0].month,
        widget.visibleDates[0].day, hour, minute);
  }

  DateTime _getDateFromPositionForWeek(
      double cellWidth, double cellHeight, double x, double y) {
    final int columnIndex =
        ((_scrollController.offset + y) / cellHeight).truncate();
    final double time =
        ((_getTimeInterval(widget.calendar.timeSlotViewSettings) / 60) *
                columnIndex) +
            widget.calendar.timeSlotViewSettings.startHour;
    final int hour = time.toInt();
    final int minute = ((time - hour) * 60).round();
    int rowIndex = (x / cellWidth).truncate();
    if (_isRTL) {
      rowIndex = (widget.visibleDates.length - rowIndex) - 1;
    }

    if (rowIndex < 0 || rowIndex >= widget.visibleDates.length) {
      return null;
    }

    final DateTime date = widget.visibleDates[rowIndex];

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime _getDateFromPositionForTimeline(
      double cellWidth, double cellHeight, double x, double y) {
    int rowIndex, columnIndex;
    if (_isRTL) {
      rowIndex = (((_scrollController.offset %
                      _getSingleViewWidthForTimeLineView(this)) +
                  (_scrollController.position.viewportDimension - x)) /
              cellWidth)
          .truncate();
    } else {
      rowIndex = (((_scrollController.offset %
                      _getSingleViewWidthForTimeLineView(this)) +
                  x) /
              cellWidth)
          .truncate();
    }
    columnIndex =
        (_scrollController.offset / _getSingleViewWidthForTimeLineView(this))
            .truncate();
    if (rowIndex >= _horizontalLinesCount) {
      columnIndex += rowIndex ~/ _horizontalLinesCount;
      rowIndex = (rowIndex % _horizontalLinesCount).toInt();
    }
    final double time =
        ((_getTimeInterval(widget.calendar.timeSlotViewSettings) / 60) *
                rowIndex) +
            widget.calendar.timeSlotViewSettings.startHour;
    final int hour = time.toInt();
    final int minute = ((time - hour) * 60).round();
    if (columnIndex < 0) {
      columnIndex = 0;
    } else if (columnIndex > widget.visibleDates.length) {
      columnIndex = widget.visibleDates.length - 1;
    }

    if (columnIndex < 0 || columnIndex >= widget.visibleDates.length) {
      return null;
    }

    final DateTime date = widget.visibleDates[columnIndex];

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime _getDateFromPosition(double x, double y, double timeLabelWidth) {
    double cellWidth = 0;
    double cellHeight = 0;
    final double width = widget.width - timeLabelWidth;
    switch (widget.view) {
      case CalendarView.schedule:
        return null;
      case CalendarView.month:
        {
          if (x > width || x < 0) {
            return null;
          }

          cellWidth = width / _kNumberOfDaysInWeek;
          cellHeight = (widget.height -
                  _getViewHeaderHeight(
                      widget.calendar.viewHeaderHeight, widget.view)) /
              widget.calendar.monthViewSettings.numberOfWeeksInView;
          return _getDateFromPositionForMonth(cellWidth, cellHeight, x, y);
        }
      case CalendarView.day:
        {
          if (y >= _timeIntervalHeight * _horizontalLinesCount ||
              x > width ||
              x < 0) {
            return null;
          }
          cellWidth = width;
          cellHeight = _timeIntervalHeight;
          return _getDateFromPositionForDay(cellWidth, cellHeight, x, y);
        }
      case CalendarView.week:
      case CalendarView.workWeek:
        {
          if (y >= _timeIntervalHeight * _horizontalLinesCount ||
              x > width ||
              x < 0) {
            return null;
          }
          cellWidth = width / widget.visibleDates.length;
          cellHeight = _timeIntervalHeight;
          return _getDateFromPositionForWeek(cellWidth, cellHeight, x, y);
        }
      case CalendarView.timelineDay:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkWeek:
      case CalendarView.timelineMonth:
        {
          final double viewWidth = _timeIntervalHeight *
              (_horizontalLinesCount * widget.visibleDates.length);
          if ((!_isRTL && x >= viewWidth) ||
              (_isRTL && x < (widget.width - viewWidth))) {
            return null;
          }
          cellWidth = _timeIntervalHeight;
          cellHeight = widget.height;
          return _getDateFromPositionForTimeline(cellWidth, cellHeight, x, y);
        }
    }

    return null;
  }

  void _drawSelection(double x, double y, double timeLabelWidth) {
    final DateTime selectedDate = _getDateFromPosition(x, y, timeLabelWidth);
    if (selectedDate == null ||
        !isDateWithInDateRange(
            widget.calendar.minDate, widget.calendar.maxDate, selectedDate)) {
      return;
    }

    /// Restrict the selection update, while selected region as disabled
    /// [TimeRegion].
    if (((widget.view == CalendarView.day ||
                widget.view == CalendarView.week ||
                widget.view == CalendarView.workWeek) &&
            !_isEnabledRegion(y, selectedDate, _selectedResourceIndex)) ||
        (_isTimelineView(widget.view) &&
            !_isEnabledRegion(x, selectedDate, _selectedResourceIndex))) {
      return;
    }

    if ((widget.view == CalendarView.month ||
            widget.view == CalendarView.timelineMonth) &&
        _isDateInDateCollection(widget.blackoutDates, selectedDate)) {
      return;
    }

    if (widget.view == CalendarView.month) {
      final int currentMonth =
          widget.visibleDates[widget.visibleDates.length ~/ 2].month;

      /// Check the selected cell date as trailing or leading date when
      /// [SfCalendar] month not shown leading and trailing dates.
      if (!_isCurrentMonthDate(
          widget.calendar.monthViewSettings.numberOfWeeksInView,
          widget.calendar.monthViewSettings.showTrailingAndLeadingDates,
          currentMonth,
          selectedDate)) {
        return;
      }

      widget.agendaSelectedDate.value = selectedDate;
    }

    _updateCalendarStateDetails._selectedDate = selectedDate;
    _selectionPainter.selectedDate = selectedDate;
    _selectionPainter._appointmentView = null;
    _selectionNotifier.value = !_selectionNotifier.value;
  }

  _SelectionPainter _addSelectionView([double resourceItemHeight]) {
    _AppointmentView appointmentView;
    if (_selectionPainter != null &&
        _selectionPainter._appointmentView != null) {
      appointmentView = _selectionPainter._appointmentView;
    }

    _selectionPainter = _SelectionPainter(
        widget.calendar,
        widget.view,
        widget.visibleDates,
        _updateCalendarStateDetails._selectedDate,
        widget.calendar.selectionDecoration,
        _timeIntervalHeight,
        widget.calendarTheme,
        _selectionNotifier,
        _isRTL,
        _selectedResourceIndex,
        resourceItemHeight,
        updateCalendarState: (_UpdateCalendarStateDetails details) {
      _getPainterProperties(details);
    });

    if (appointmentView != null &&
        _updateCalendarStateDetails._visibleAppointments != null &&
        _updateCalendarStateDetails._visibleAppointments
            .contains(appointmentView.appointment)) {
      _selectionPainter._appointmentView = appointmentView;
    }

    return _selectionPainter;
  }

  Widget _getTimelineViewHeader(double width, double height, String locale) {
    _timelineViewHeader = _TimelineViewHeaderView(
        widget.visibleDates,
        _timelineViewHeaderScrollController,
        _timelineViewHeaderNotifier,
        widget.calendar.viewHeaderStyle,
        widget.calendar.timeSlotViewSettings,
        _getViewHeaderHeight(widget.calendar.viewHeaderHeight, widget.view),
        _isRTL,
        widget.calendar.todayHighlightColor ??
            widget.calendarTheme.todayHighlightColor,
        widget.calendar.todayTextStyle,
        widget.locale,
        widget.calendarTheme,
        widget.calendar.minDate,
        widget.calendar.maxDate,
        _viewHeaderNotifier,
        widget.calendar.cellBorderColor,
        widget.blackoutDates,
        widget.calendar.blackoutDatesTextStyle,
        widget.textScaleFactor);
    return ListView(
        padding: const EdgeInsets.all(0.0),
        controller: _timelineViewHeaderScrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          CustomPaint(
            painter: _timelineViewHeader,
            size: Size(width, height),
          )
        ]);
  }
}

class _CustomNeverScrollableScrollPhysics extends NeverScrollableScrollPhysics {
  /// Creates scroll physics that does not let the user scroll.
  const _CustomNeverScrollableScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  _CustomNeverScrollableScrollPhysics applyTo(ScrollPhysics ancestor) {
    /// Set the clamping scroll physics as default parent for never scroll
    /// physics, because flutter framework set different parent physics
    /// based on platform(iOS, Android, etc.,)
    return _CustomNeverScrollableScrollPhysics(
        parent: buildParent(
            ClampingScrollPhysics(parent: RangeMaintainingScrollPhysics())));
  }
}
