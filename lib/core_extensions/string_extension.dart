// 字符串工具与扩展方法集合
// 提供随机字符串、判空与字符统计、命名风格转换、宽度与截断处理、金额格式化等常用字符串操作能力。

import 'dart:convert';
import 'dart:math';

/// 生成随机字符串
/// [length] 字符串长度
/// [containsNumbers] 是否包含数字
/// [containsSpecialChars] 是否包含特殊字符
String generateRandomString(
  int length, {
  bool containsNumbers = true,
  bool containsSpecialChars = false,
}) {
  final random = Random();
  final String letterChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  final String numberChars = containsNumbers ? '1234567890' : '';
  final String specialChars =
      containsSpecialChars ? '!@#\$%^&*()_+-=[]{}|;:,.<>?~' : '';

  final allChars = '$letterChars$numberChars$specialChars';
  final randomString =
      List.generate(
        length,
        (index) => allChars[random.nextInt(allChars.length)],
      ).join();

  return randomString;
}

/// String扩展
extension StringExtension on String {
  ///---------检查------------------------------
  /// 检查字符串是否为空或仅包含空白字符
  bool get isBlank => trim().isEmpty;

  /// 检查字符串是否不为空且不仅包含空白字符
  bool get isNotBlank => !isBlank;

  /// 检查是否只包含数字
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// 检查是否只包含字母
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// 检查是否只包含字母和数字
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// 统计字符出现次数
  int countOccurrences(String pattern) {
    return RegExp.escape(pattern).allMatches(this).length;
  }

  /// 检查是否为有效的JSON格式
  bool get isValidJson {
    try {
      jsonDecode(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 计算字符串的显示宽度（中文字符按2个字符宽度计算）
  int get displayWidth {
    int width = 0;
    for (int i = 0; i < length; i++) {
      final char = codeUnitAt(i);
      // 中文字符范围
      if ((char >= 0x4E00 && char <= 0x9FFF) || // CJK统一汉字
          (char >= 0x3400 && char <= 0x4DBF) || // CJK扩展A
          (char >= 0x20000 && char <= 0x2A6DF) || // CJK扩展B
          (char >= 0x2A700 && char <= 0x2B73F) || // CJK扩展C
          (char >= 0x2B740 && char <= 0x2B81F) || // CJK扩展D
          (char >= 0x2B820 && char <= 0x2CEAF) || // CJK扩展E
          (char >= 0xF900 && char <= 0xFAFF) || // CJK兼容汉字
          (char >= 0x2F800 && char <= 0x2FA1F)) {
        // CJK兼容汉字补充
        width += 2;
      } else {
        width += 1;
      }
    }
    return width;
  }

  ///---------操作------------------------------

  /// 移除所有空白字符（包括空格、制表符、换行符等）
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// 移除所有非字母数字字符
  String get removeAllNonAlphanumeric =>
      replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  /// 只保留数字
  String get onlyNumbers => replaceAll(RegExp(r'[^\d]'), '');

  /// 只保留字母
  String get onlyLetters => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// 只保留字母和数字
  String get onlyAlphanumeric => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  /// 提取所有数字
  List<String> get extractNumbers {
    return RegExp(r'\d+').allMatches(this).map((m) => m.group(0)!).toList();
  }

  /// 反转字符串
  String get reverse => split('').reversed.join('');

  /// 获取字符串的字节长度（UTF-8编码）
  int get byteLength => utf8.encode(this).length;

  /// 截取字符串到指定长度，如果超长则添加省略号
  String truncate(int maxLength, [String ellipsis = '...']) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  String get truncate10 => truncate(10);

  /// 安全的substring，防止越界
  String safeSubstring(int start, [int? end]) {
    final actualStart = max(0, min(start, length));
    final actualEnd = end == null ? length : max(actualStart, min(end, length));
    return substring(actualStart, actualEnd);
  }

  /// 按显示宽度截取字符串
  String truncateByWidth(int maxWidth, [String ellipsis = '...']) {
    int currentWidth = 0;
    int cutIndex = 0;

    int getCharWidth(int char) {
      if ((char >= 0x4E00 && char <= 0x9FFF) ||
          (char >= 0x3400 && char <= 0x4DBF) ||
          (char >= 0x20000 && char <= 0x2A6DF) ||
          (char >= 0x2A700 && char <= 0x2B73F) ||
          (char >= 0x2B740 && char <= 0x2B81F) ||
          (char >= 0x2B820 && char <= 0x2CEAF) ||
          (char >= 0xF900 && char <= 0xFAFF) ||
          (char >= 0x2F800 && char <= 0x2FA1F)) {
        return 2;
      }
      return 1;
    }

    for (int i = 0; i < length; i++) {
      final char = codeUnitAt(i);
      final charWidth = getCharWidth(char);

      if (currentWidth + charWidth > maxWidth) {
        break;
      }

      currentWidth += charWidth;
      cutIndex = i + 1;
    }

    if (cutIndex < length) {
      final ellipsisWidth = ellipsis.displayWidth;
      if (currentWidth + ellipsisWidth <= maxWidth) {
        return substring(0, cutIndex) + ellipsis;
      } else {
        // 需要进一步缩减来容纳省略号
        while (cutIndex > 0 && currentWidth + ellipsisWidth > maxWidth) {
          cutIndex--;
          currentWidth -= getCharWidth(codeUnitAt(cutIndex));
        }
        return substring(0, cutIndex) + ellipsis;
      }
    }

    return this;
  }

  /// 将字符串转换为驼峰命名（首字母小写）
  String get toCamelCase {
    if (isEmpty) return '';
    final words = split(RegExp(r'[_\s-]+'));
    if (words.length == 1) return words.first.toLowerCase();
    return words.first.toLowerCase() +
        words.skip(1).map((word) => word.capitalize).join();
  }

  /// 将字符串转换为帕斯卡命名（首字母大写）
  String get toPascalCase {
    if (isEmpty) return '';
    return split(RegExp(r'[_\s-]+')).map((word) => word.capitalize).join();
  }

  /// 将字符串转换为蛇形命名 (小写字母和下划线)
  String get toSnakeCase {
    return replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// 智能换行：
  ///
  /// 在指定宽度处换行，尽量在单词边界处断开
  String wordWrap(int width) {
    if (isEmpty || width <= 0) return this;

    final words = split(RegExp(r'\s+'));
    final List<String> lines = [];
    String currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ('$currentLine $word'.length <= width) {
        currentLine = '$currentLine $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.join('\n');
  }

  /// 单词首字母大写
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';

  /// 句子每个单词首字母大写
  String get capitalizedLetters {
    try {
      String temp = '';
      split(' ').forEach((s) {
        temp += '${s[0].toUpperCase()}${s.substring(1)} ';
      });
      return temp;
    } catch (e) {
      return '${this[0].toUpperCase()}${substring(1)}';
    }
  }

  /// 为空字符串增加默认值
  String whenEmpty(String defaultValue) {
    return isNotEmpty ? this : defaultValue;
  }

  /// 转换成double类型
  double? toDouble() => double.tryParse(this);

  /// 转换成int类型
  int? toInt() => int.tryParse(this);

  /// 转换成金额格式
  /// [decimalPlaces] 保留的小数位数，默认为2位
  /// [thousandSeparator] 千分位分隔符，默认为逗号
  /// [decimalSeparator] 小数点分隔符，默认为点号
  String toMoneyFormat({
    int decimalPlaces = 2,
    String thousandSeparator = ',',
    String decimalSeparator = '.',
  }) {
    if (isEmpty) return '';

    // 移除所有非数字字符（保留负号和小数点）
    String cleanStr = replaceAll(RegExp(r'[^\d.-]'), '');

    // 验证是否为有效数字
    final double? numValue = double.tryParse(cleanStr);
    if (numValue == null) return this; // 如果不是有效数字，返回原始字符串

    // 处理负号
    bool isNegative = numValue < 0;
    double absValue = numValue.abs();

    // 格式化为指定小数位数
    String formattedStr = absValue.toStringAsFixed(decimalPlaces);

    // 分离整数部分和小数部分
    List<String> parts = formattedStr.split('.');
    String intPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    String addThousandSeparator(String intPart, String separator) {
      if (intPart.length <= 3) return intPart;

      String result = '';
      int count = 0;

      // 从右往左添加分隔符
      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          result = separator + result;
        }
        result = intPart[i] + result;
        count++;
      }

      return result;
    }

    // 添加千分位分隔符
    String formattedIntPart = addThousandSeparator(intPart, thousandSeparator);

    // 组合结果
    String result = formattedIntPart;
    if (decimalPlaces > 0 && decimalPart.isNotEmpty) {
      result += decimalSeparator + decimalPart;
    }

    return isNegative ? '-$result' : result;
  }

  /// 中文金额格式（使用人民币符号）
  String get toCNYFormat {
    final formatted = toMoneyFormat(decimalPlaces: 2);
    return formatted.isEmpty ? '' : '¥$formatted';
  }

  /// 美元格式
  String get toUSDFormat {
    final formatted = toMoneyFormat(decimalPlaces: 2);
    return formatted.isEmpty ? '' : '\$$formatted';
  }
}

/// 字符串正则验证扩展
extension StringRegexExtension on String {
  /// Regex of simple mobile.
  static const String regexMobileSimple = '^[1]\\d{10}\$';

  /// Regex of exact mobile.
  ///  <p>china mobile: 134(0-8), 135, 136, 137, 138, 139, 147, 150, 151, 152, 157, 158, 159, 165, 172, 178, 182, 183, 184, 187, 188, 195, 198</p>
  ///  <p>china unicom: 130, 131, 132, 145, 155, 156, 166, 167, 171, 175, 176, 185, 186</p>
  ///  <p>china telecom: 133, 153, 162, 173, 177, 180, 181, 189, 199, 191</p>
  ///  <p>global star: 1349</p>
  ///  <p>virtual operator: 170</p>
  static const String regexMobileExact =
      '^((13[0-9])|(14[57])|(15[0-35-9])|(16[2567])|(17[01235-8])|(18[0-9])|(19[1589]))\\d{8}\$';

  /// Regex of telephone number.
  static const String regexTel = '^0\\d{2,3}[- ]?\\d{7,8}';

  /// Regex of id card number which length is 15.
  static const String regexIdCard15 =
      '^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}\$';

  /// Regex of id card number which length is 18.
  static const String regexIdCard18 =
      '^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9Xx])\$';

  /// Regex of email.
  static const String regexEmail =
      '^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$';

  /// Regex of url.
  static const String regexUrl = '[a-zA-Z]+://[^\\s]*';

  /// Regex of Chinese character.
  static const String regexZh = '[\\u4e00-\\u9fa5]';

  /// Regex of date which pattern is 'yyyy-MM-dd'.
  static const String regexDate =
      '^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)\$';

  /// Regex of ip address.
  static const String regexIp =
      '((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)';

  /// must contain letters and numbers, 6 ~ 18.
  /// 必须包含字母和数字, 6~18.
  static const String regexUsername =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z]{6,18}\$';

  /// must contain letters and numbers, can contain special characters 6 ~ 18.
  /// 必须包含字母和数字,可包含特殊字符 6~18.
  static const String regexUsername2 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z\\W]{6,18}\$';

  /// must contain letters and numbers and special characters, 6 ~ 18.
  /// 必须包含字母和数字和殊字符, 6~18.
  static const String regexUsername3 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)(?![0-9a-zA-Z]+\$)(?![0-9\\W]+\$)(?![a-zA-Z\\W]+\$)[0-9A-Za-z\\W]{6,18}\$';

  /// Regex of QQ number.
  static const String regexQQ = '[1-9][0-9]{4,}';

  /// Regex of postal code in China.
  static const String regexChinaPostalCode = '[1-9]\\d{5}(?!\\d)';

  /// Regex of Passport.
  static const String regexPassport =
      r'(^[EeKkGgDdSsPpHh]\d{8}$)|(^(([Ee][a-fA-F])|([DdSsPp][Ee])|([Kk][Jj])|([Mm][Aa])|(1[45]))\d{7}$)';

  ///Return whether input matches regex of simple mobile.
  bool isMobileSimple() => matches(regexMobileSimple);

  ///Return whether input matches regex of exact mobile.
  bool isMobileExact() => matches(regexMobileExact);

  /// Return whether input matches regex of telephone number.
  bool isTel() => matches(regexTel);

  /// Return whether input matches regex of id card number.
  bool isIDCard() {
    if (length == 15) {
      return isIDCard15();
    }
    if (length == 18) {
      return isIDCard18();
    }
    return false;
  }

  /// Return whether input matches regex of id card number which length is 15.
  bool isIDCard15() {
    return matches(regexIdCard15);
  }

  /// Return whether input matches regex of id card number which length is 18.
  bool isIDCard18() {
    return matches(regexIdCard18);
  }

  /// Return whether input matches regex of email.
  bool isEmail() {
    return matches(regexEmail);
  }

  /// Return whether input matches regex of url.
  bool isURL() {
    return matches(regexUrl);
  }

  /// Return whether input matches regex of Chinese character.
  bool isZh() {
    return '〇' == this || matches(regexZh);
  }

  /// Return whether input matches regex of date which pattern is 'yyyy-MM-dd'.
  bool isDate() {
    return matches(regexDate);
  }

  /// Return whether input matches regex of ip address.
  bool isIP() {
    return matches(regexIp);
  }

  /// Return whether input matches regex of username.
  bool isUserName() {
    return matches(regexUsername);
  }

  /// Return whether input matches regex of QQ.
  bool isQQ() {
    return matches(regexQQ);
  }

  ///Return whether input matches regex of Passport.
  bool isPassport() {
    return matches(regexPassport);
  }

  bool matches(String regex) {
    if (isEmpty) return false;
    return RegExp(regex).hasMatch(this);
  }
}
