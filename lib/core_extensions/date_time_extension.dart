// 日期时间工具与扩展方法集合
// 提供日期时间格式化（中英文）、工作日计算、年龄与年份统计，以及相对/智能时间展示等能力。
// DataTime格式化扩展
extension FormatExtension on DateTime {
  /// 年
  String get yearEx => '$year';

  /// 月
  String get monthEx => '$month'.padLeft(2, '0');

  /// 日
  String get dayEx => '$day'.padLeft(2, '0');

  /// 时
  String get hourEx => '$hour'.padLeft(2, '0');

  /// 分
  String get minuteEx => '$minute'.padLeft(2, '0');

  /// 秒
  String get secondEx => '$second'.padLeft(2, '0');

  /// 年-月
  String toYM() => '$yearEx-$monthEx';

  /// 月-日
  String toMD() => '$monthEx-$dayEx';

  /// 年-月-日
  String toYMD() => '$yearEx-$monthEx-$dayEx';

  /// 时:分:秒
  String toHMS() => '$hourEx:$minuteEx:$secondEx';

  /// 时:分
  String toHM() => '$hourEx:$minuteEx';

  /// 年-月-日 时:分:秒
  String toYMDHMS() => '${toYMD()} ${toHMS()}';
}

/// DataTime中文格式化扩展
extension FormatExtensionCN on DateTime {
  /// 年-月/中文
  String toYMCN() => '$yearEx年$monthEx月';

  /// 年-月-日/中文
  String toYMDCN() => '$yearEx年$monthEx月$dayEx日';

  /// 月-日/中文
  String toMDCN() => '$monthEx月$dayEx日';

  /// 周几
  String get weekDayCN {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }
}

/// 时间显示模式枚举
enum TimeDisplayMode {
  /// 相对时间模式 (几分钟前、几小时前等)
  relative,

  /// 智能模式 (综合相对时间和智能显示的最佳体验)
  /// - 1小时内：显示相对时间 (如 "30分钟前")
  /// - 今天超过1小时：显示时间 (如 "14:30")
  /// - 昨天/明天：显示 "昨天/明天 时间"
  /// - 本周：显示 "周几 时间"
  /// - 今年：显示 "月日 时间"
  /// - 其他：显示 "年月日 时间"
  smart,
}

/// DataTime扩展
extension DateTimeExtension on DateTime {
  /// 当前起始
  DateTime get startOfDay => DateTime(year, month, day, 0, 0, 0, 0, 0);

  /// 当天结束
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// 是否是整点
  bool get isOnTheHour =>
      minute == 0 && second == 0 && millisecond == 0 && microsecond == 0;

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 是否是明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// 是否是本周
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(
          startOfWeek.startOfDay.subtract(const Duration(microseconds: 1)),
        ) &&
        isBefore(endOfWeek.endOfDay.add(const Duration(microseconds: 1)));
  }

  /// 是否是本月
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// 是否是本年
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  /// 是否是周末
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// 是否是工作日
  bool get isWeekday => !isWeekend;

  /// 是否是闰年
  bool get isLeapYear =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// 本月第一天
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  /// 本月最后一天
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// 本周第一天 (周一)
  DateTime get firstDayOfWeek => subtract(Duration(days: weekday - 1));

  /// 本周最后一天 (周日)
  DateTime get lastDayOfWeek => add(Duration(days: 7 - weekday));

  /// 本年第一天
  DateTime get firstDayOfYear => DateTime(year, 1, 1);

  /// 本年最后一天
  DateTime get lastDayOfYear => DateTime(year, 12, 31);

  /// 添加工作日
  /// [workdays] 工作日数量
  ///
  /// 作用: 从当前日期开始，向前计算指定数量的工作日后的日期。
  /// 自动跳过周末（周六、周日），只计算工作日（周一到周五）
  DateTime addWorkdays(int workdays) {
    DateTime result = this;
    int daysToAdd = workdays;

    while (daysToAdd > 0) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) {
        daysToAdd--;
      }
    }

    return result;
  }

  /// 减去工作日
  /// [workdays] 工作日数量
  ///
  /// 作用: 从当前日期开始，向后计算指定数量的工作日前的日期。
  /// 自动跳过周末（周六、周日），只计算工作日（周一到周五）
  DateTime subtractWorkdays(int workdays) {
    DateTime result = this;
    int daysToSubtract = workdays;

    while (daysToSubtract > 0) {
      result = result.subtract(const Duration(days: 1));
      if (result.isWeekday) {
        daysToSubtract--;
      }
    }

    return result;
  }

  /// 计算年龄
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// 本月的天数
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// 今年过了多少天
  int get dayOfYear => difference(DateTime(year, 1, 1)).inDays + 1;

  /// 一年还剩多少天
  int get remainingDaysInYear => DateTime(year, 12, 31).difference(this).inDays;

  /// 统一的时间显示方法
  /// [mode] 显示模式
  /// [includeYear] 是否包含年份计算(仅relative模式)
  /// [includeMonth] 是否包含月份计算(仅relative模式)
  /// [includeFuture] 是否处理未来时间(仅relative模式)
  String timeDisplay({
    TimeDisplayMode mode = TimeDisplayMode.smart,
    bool includeYear = false,
    bool includeMonth = false,
    bool includeFuture = false,
  }) {
    final now = DateTime.now();
    final timeStr = toHM();

    // 缓存日期比较结果，避免重复计算
    final isToday = year == now.year && month == now.month && day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow =
        year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;

    switch (mode) {
      case TimeDisplayMode.relative:
        return _getRelativeTime(now, includeYear, includeMonth, includeFuture);

      case TimeDisplayMode.smart:
        return _getSmartFormat(now, timeStr, isToday, isYesterday, isTomorrow);
    }
  }

  /// 获取相对时间显示
  String _getRelativeTime(
    DateTime now,
    bool includeYear,
    bool includeMonth,
    bool includeFuture,
  ) {
    final diff = now.difference(this);
    final isInFuture = diff.isNegative;

    // 如果是未来时间且不处理未来时间，返回原始格式
    if (isInFuture && !includeFuture) {
      return toYMDHMS();
    }

    final absDiff = diff.abs();
    final suffix = isInFuture ? '后' : '前';

    // 精确计算年月差
    if (includeYear || includeMonth) {
      final laterDate = isInFuture ? this : now;
      final earlierDate = isInFuture ? now : this;

      int yearDiff = laterDate.year - earlierDate.year;
      int monthDiff = laterDate.month - earlierDate.month;

      // 如果日期还没到，月份减1
      if (laterDate.day < earlierDate.day) {
        monthDiff--;
      }

      // 如果月份为负，年份减1，月份加12
      if (monthDiff < 0) {
        yearDiff--;
        monthDiff += 12;
      }

      if (yearDiff > 0 && includeYear) {
        return monthDiff > 0
            ? '$yearDiff年$monthDiff个月$suffix'
            : '$yearDiff年$suffix';
      } else if (monthDiff > 0 && includeMonth) {
        return '$monthDiff个月$suffix';
      }
    }

    // 处理天、小时、分钟、秒
    if (absDiff.inDays > 0) {
      return '${absDiff.inDays}天$suffix';
    } else if (absDiff.inHours > 0) {
      return '${absDiff.inHours}小时$suffix';
    } else if (absDiff.inMinutes > 0) {
      return '${absDiff.inMinutes}分钟$suffix';
    } else if (absDiff.inSeconds > 0) {
      return '${absDiff.inSeconds}秒$suffix';
    } else {
      return '刚刚';
    }
  }

  /// 获取自动智能格式显示
  String _getSmartFormat(
    DateTime now,
    String timeStr,
    bool isToday,
    bool isYesterday,
    bool isTomorrow,
  ) {
    // 今天的处理：1小时内显示相对时间，超过1小时显示时间
    if (isToday) {
      final diff = now.difference(this);
      if (diff.inHours < 1) {
        return _getRelativeTime(now, false, false, false);
      } else {
        return timeStr;
      }
    }

    // 昨天/明天的处理
    if (isYesterday) {
      return '昨天 $timeStr';
    }

    if (isTomorrow) {
      return '明天 $timeStr';
    }

    // 检查是否是本周
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final isThisWeekCheck =
        isAfter(
          startOfWeek.startOfDay.subtract(const Duration(microseconds: 1)),
        ) &&
        isBefore(endOfWeek.endOfDay.add(const Duration(microseconds: 1)));

    if (isThisWeekCheck) {
      return '$weekDayCN $timeStr';
    }

    // 检查是否是今年
    if (year == now.year) {
      return '${toMDCN()} $timeStr';
    }

    // 其他年份
    return '${toYMDCN()} $timeStr';
  }

  /// 距离当前时间的时间差
  /// [includeYear] 是否包含年份计算
  /// [includeMonth] 是否包含月份计算
  /// [includeFuture] 是否处理未来时间
  String timePassed({
    bool includeYear = false,
    bool includeMonth = false,
    bool includeFuture = false,
  }) {
    return timeDisplay(
      mode: TimeDisplayMode.relative,
      includeYear: includeYear,
      includeMonth: includeMonth,
      includeFuture: includeFuture,
    );
  }

  /// 智能时间显示 (已整合到auto模式)
  /// 为了向后兼容保留此方法
  String get smartFormat {
    return timeDisplay(mode: TimeDisplayMode.smart);
  }
}
