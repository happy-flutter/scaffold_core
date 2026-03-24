import 'package:scaffold_core/core_utils/loading_util.dart';

void main() {
  LoadingUtil.configLoading(
    displayDuration: Duration(seconds: 2),
  );

  LoadingUtil.show();

  Future.delayed(Duration(seconds: 2), () async {
    await LoadingUtil.dismiss();
    LoadingUtil.showSuccess('Success!');
  });
}
