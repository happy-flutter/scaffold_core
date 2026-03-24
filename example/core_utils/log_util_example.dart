import 'package:scaffold_core/core_utils/log_util.dart';

void main() {
  LogUtil.info('This is info message');
  LogUtil.debug('This is debug message');
  LogUtil.error('This is error message', exception: Exception('test error'));
  LogUtil.warning('This is warning');

  'Hello world'.log();

  // Interceptor logger = LogUtil.talkerDioLogger;
  print('Dio logger interceptor created');

  // Widget talkerScreen = LogUtil.talkerPage;
  print('Talker debug page created');
}
