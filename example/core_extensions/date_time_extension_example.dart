import 'package:scaffold_core/core_extensions/date_time_extension.dart';

void main() {
  final date = DateTime.now();
  
  print('YMD: ${date.toYMD()}');
  print('YMDHMS: ${date.toYMDHMS()}');
  print('YMD CN: ${date.toYMDCN()}');
  print('Weekday CN: ${date.weekDayCN}');
  
  print('IsToday: ${date.isToday}');
  print('IsWeekend: ${date.isWeekend}');
  
  final future = DateTime.now().add(Duration(days: 30));
  print('Relative time: ${future.timePassed(includeMonth: true)}');
  print('Smart format: ${date.timeDisplay()}');
  
  print('Days in month: ${date.daysInMonth}');
  print('Day of year: ${date.dayOfYear}');
  
  final added = date.addWorkdays(5);
  print('After adding 5 workdays: ${added.toYMD()}');
}
