# Scaffold_Core 基础组件库

## 概述

Scaffold_Core 是一个 Flutter 基础组件库，提供应用开发中常用的 **网络请求、工具类、扩展方法** 等核心能力，采用模块化设计，便于按需引入、维护和扩展。

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  scaffold_core: ^1.0.0
```

或者使用 Git 依赖：

```yaml
dependencies:
  scaffold_core:
    git:
      url: https://github.com/happy-flutter/scaffold_core.git
```

## 目录结构

```text
scaffold_core/lib/
├── core_extensions/            # 扩展方法模块
│   ├── color_extension.dart
│   ├── date_time_extension.dart
│   ├── future_extension.dart
│   └── string_extension.dart
├── core_network/               # 网络请求模块
│   ├── core_network.dart
│   ├── exception.dart
│   ├── request.dart
│   ├── response.dart
│   ├── status_codes.dart
│   └── interceptors/
│       └── retry_interceptor.dart
└── core_utils/                 # 工具类模块
    ├── assets_picker_util.dart
    ├── connectivity_util.dart
    ├── crypt_util.dart
    ├── image_compress_util.dart
    ├── image_util.dart
    ├── info_util.dart
    ├── lifecycle_util.dart
    ├── link_util.dart
    ├── loading_util.dart
    ├── log_util.dart
    ├── permission_util.dart
    ├── storage_util.dart
    ├── throttle_util.dart
    └── video_compress_util.dart
```

## 模块说明

### 1. core_extensions - 扩展方法模块

为常用数据类型提供扩展方法，增强原有类型的可读性与便捷性。

#### 文件说明

- **color_extension.dart**：颜色工具与 `Color` 扩展
  - 随机颜色、HEX/RGB/HSL 构造与转换
  - 亮度、饱和度、色相调整与混色
  - 深色/浅色判断、反色、灰度化、透明度控制

- **date_time_extension.dart**：日期时间扩展
  - 多种日期/时间格式化（`YYYY-MM-DD`、`HH:mm:ss`、`YYYY-MM-DD HH:mm:ss` 等）
  - 中文格式化（年月日、周几等）
  - 相对时间显示（几分钟前、几小时前、几天前等）
  - 今天/昨天/本周/本月/本年判断，工作日与周末判断
  - 工作日加减、年龄计算、今年已过/剩余天数等

- **future_extension.dart**：Future 扩展
  - 为 `Future` 增加最小执行时长（毫秒/秒/自定义 `Duration`）

- **string_extension.dart**：字符串扩展
  - 判空、字符统计、显示宽度计算（中英文混排）
  - 过滤与截断（按长度/显示宽度、安全 substring、反转、字节长度等）
  - 命名风格转换（camel / Pascal / snake）与单词首字母大写
  - 数值转换（`toDouble` / `toInt`）、金额格式化（含 CNY、USD 格式）
  - 常用正则校验（手机号、邮箱、身份证、URL、日期、IP、QQ、用户名等）
  - 随机字符串生成

### 2. core_network - 网络请求模块

基于 Dio 封装的网络请求框架，提供统一、可配置的网络访问能力。

#### 文件说明

- **core_network.dart**：网络客户端核心类
  - `NetworkClient` 单例管理
  - 支持 GET / POST / PUT / DELETE 等常见 HTTP 方法
  - 支持文件上传、下载与进度回调
  - 集成重试拦截器与日志能力

- **exception.dart**：网络异常处理
  - `NetworkException` 自定义异常体系
  - 统一封装超时、取消、连接错误、状态码异常等

- **request.dart**：请求封装
  - `NetworkRequest` 请求构建类
  - 统一管理 baseUrl、路径、参数、头部、超时等配置

- **response.dart**：响应封装
  - `NetworkResponse` 统一响应模型
  - 便于上层业务做统一数据处理

- **status_codes.dart**：HTTP 状态码常量
  - 收录常见 HTTP 状态码，便于语义化使用

- **interceptors/retry_interceptor.dart**：重试拦截器
  - 支持网络请求失败时自动重试
  - 可配置重试次数与策略

### 3. core_utils - 工具类模块

封装常见业务无关的通用工具，方便在不同项目中复用。

#### 文件说明

- **assets_picker_util.dart**：媒体选择工具
  - 相机拍照与录像（分辨率可选）
  - 相册多选图片/视频，并自动修正文件扩展名

- **connectivity_util.dart**：网络连接工具
  - 检测当前网络状态
  - 监听网络变化并回调

- **crypt_util.dart**：加密工具
  - 常用哈希/加密算法封装

- **image_compress_util.dart**：图片压缩工具
  - 基于 `flutter_image_compress` 的尺寸、质量压缩
  - 支持从内存、文件、资源等多种输入形式

- **image_util.dart**：图片处理工具
  - 图片加载、尺寸处理、缓存等（具体以实现为准）

- **info_util.dart**：设备信息工具
  - 获取设备信息和应用版本等

- **lifecycle_util.dart**：生命周期工具
  - 应用生命周期监听与处理

- **link_util.dart**：链接处理工具
  - 打开外部 URL、处理深度链接等

- **loading_util.dart**：加载提示工具
  - 统一的全局 loading 展示与关闭

- **log_util.dart**：日志工具
  - 基于 Talker 的日志封装
  - 支持不同日志级别与网络日志拦截

- **permission_util.dart**：权限管理工具
  - 权限请求、检查与结果处理

- **storage_util.dart**：本地存储工具
  - 基于 SharedPreferences 的键值存储
  - 对象序列化/反序列化与缓存

- **throttle_util.dart**：节流防抖工具
  - 支持函数级节流、指定时间节流
  - 支持防抖操作
  - 支持 Future 节流防抖

- **video_compress_util.dart**：视频压缩工具
  - 基于 `v_video_compressor` 的视频压缩
  - 支持多档质量配置、进度监听与缩略图生成

## 主要依赖

- **dio**：网络请求库
- **talker_flutter / talker_dio_logger / talker_logger**：日志系统
- **shared_preferences**：本地存储
- **path_provider**：路径获取
- **permission_handler**：权限管理
- **crypto / encrypt**：加密库
- **flutter_svg**：SVG 渲染
- **cached_network_image**：网络图片缓存
- **package_info_plus**：应用信息
- **device_info_plus**：设备信息
- **app_settings**：系统设置页面打开
- **map_launcher**：地图导航拉起
- **connectivity_plus**：网络状态
- **url_launcher**：URL 启动
- **app_links**：深度链接
- **flutter_easyloading**：加载提示
- **wechat_assets_picker / wechat_camera_picker**：媒体选择与拍摄
- **flutter_image_compress**：图片压缩
- **v_video_compressor**：视频压缩

## 使用示例

### 网络请求

```dart
// 初始化网络客户端
NetworkClient.init(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 30),
);

// 发起请求
final response = await NetworkClient().fetch(
  NetworkRequest(
    apiPath: '/users',
    method: RequestMethod.get,
  ),
);
```

### 存储操作

```dart
// 初始化存储
await StorageUtil.init();

// 存储数据
await StorageUtil.setValue('key', 'value');
await StorageUtil.setObject('user', {'name': 'John'});

// 读取数据
final value = StorageUtil.getValue('key');
final user = StorageUtil.getObject('user');
```

### 日志记录

```dart
// 记录日志
LogUtil.info('这是一条信息日志');
LogUtil.error('这是一条错误日志');
LogUtil.debug('这是一条调试日志');
```

### 字符串扩展

```dart
// 使用字符串扩展
final phone = '13800138000';
if (phone.isMobileExact()) {
  print('有效的手机号');
}

final amount = '1234.56';
print(amount.toMoneyFormat()); // 输出: 1,234.56
```

## Author

[happy-flutter](https://github.com/happy-flutter)

## License

Scaffold_Core is available under the MIT license. See the LICENSE file for more info.
