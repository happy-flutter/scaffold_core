# Scaffold_Core - Flutter Core Components Library

![Pub Version (including pre-releases)](https://img.shields.io/pub/v/scaffold_core?include_prereleases)
![GitHub](https://img.shields.io/github/license/happy-flutter/scaffold_core)
![Pub Likes](https://img.shields.io/pub/likes/scaffold_core)

[中文文档](README_zh.md)

## Overview

Scaffold_Core is a foundational Flutter components library that provides core capabilities commonly used in application development, including **network requests, utilities, and extension methods**. It adopts a modular design that facilitates on-demand import, maintenance, and extension.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  scaffold_core: ^1.0.0
```

Or use Git dependency:

```yaml
dependencies:
  scaffold_core:
    git:
      url: https://github.com/happy-flutter/scaffold_core.git
```

## Project Structure

```text
scaffold_core/lib/
├── core_extensions/            # Extension methods module
│   ├── color_extension.dart
│   ├── date_time_extension.dart
│   ├── future_extension.dart
│   └── string_extension.dart
├── core_network/               # Network request module
│   ├── core_network.dart
│   ├── exception.dart
│   ├── request.dart
│   ├── response.dart
│   ├── status_codes.dart
│   └── interceptors/
│       └── retry_interceptor.dart
└── core_utils/                 # Utilities module
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

## Module Description

### 1. core_extensions - Extension Methods Module

Provides extension methods for commonly used data types, enhancing the readability and convenience of original types.

#### File Description

- **color_extension.dart**: Color utilities and `Color` extensions
  - Random color, HEX/RGB/HSL construction and conversion
  - Brightness, saturation, hue adjustment and color mixing
  - Dark/light detection, inverse color, grayscale, transparency control

- **date_time_extension.dart**: DateTime extensions
  - Multiple date/time formatting (`YYYY-MM-DD`, `HH:mm:ss`, `YYYY-MM-DD HH:mm:ss`, etc.)
  - Chinese formatting (year-month-day, weekday, etc.)
  - Relative time display (minutes ago, hours ago, days ago, etc.)
  - Today/Yesterday/This week/This month/This year detection, weekday and weekend detection
  - Workday addition/subtraction, age calculation, days passed/remaining in the current year, etc.

- **future_extension.dart**: Future extensions
  - Adds minimum execution duration to `Future` (milliseconds/seconds/custom `Duration`)

- **string_extension.dart**: String extensions
  - Empty check, character count, display width calculation (mixed Chinese and English)
  - Filtering and truncation (by length/display width, safe substring, reverse, byte length, etc.)
  - Naming style conversion (camel / Pascal / snake) and capitalize first word
  - Numeric conversion (`toDouble` / `toInt`), amount formatting (CNY, USD formats included)
  - Common regex validation (phone number, email, ID card, URL, date, IP, QQ, username, etc.)
  - Random string generation

### 2. core_network - Network Request Module

A network request framework encapsulated based on Dio, providing unified and configurable network access capabilities.

#### File Description

- **core_network.dart**: Network client core class
  - `NetworkClient` singleton management
  - Supports common HTTP methods such as GET / POST / PUT / DELETE
  - Supports file upload, download and progress callbacks
  - Integrated retry interceptor and logging capabilities

- **exception.dart**: Network exception handling
  - `NetworkException` custom exception system
  - Unified encapsulation of timeout, cancellation, connection errors, status code exceptions, etc.

- **request.dart**: Request encapsulation
  - `NetworkRequest` request builder class
  - Unified management of baseUrl, path, parameters, headers, timeout and other configurations

- **response.dart**: Response encapsulation
  - `NetworkResponse` unified response model
  - Convenient for upper-layer business to do unified data processing

- **status_codes.dart**: HTTP status code constants
  - Includes common HTTP status codes for semantic usage

- **interceptors/retry_interceptor.dart**: Retry interceptor
  - Supports automatic retry when network request fails
  - Configurable retry count and strategy

### 3. core_utils - Utilities Module

Encapsulates common business-agnostic general utilities for easy reuse across different projects.

#### File Description

- **assets_picker_util.dart**: Media picker utilities
  - Camera photo and video capture (resolution optional)
  - Multiple image/video selection from gallery, automatically corrects file extensions

- **connectivity_util.dart**: Network connectivity utilities
  - Detects current network status
  - Listens for network changes with callbacks

- **crypt_util.dart**: Encryption utilities
  - Common hashing/encryption algorithm encapsulation

- **image_compress_util.dart**: Image compression utilities
  - Size and quality compression based on `flutter_image_compress`
  - Supports multiple input forms from memory, file, resources, etc.

- **image_util.dart**: Image processing utilities
  - Image loading, size processing, caching, etc. (subject to implementation)

- **info_util.dart**: Device info utilities
  - Get device information and application version, etc.

- **lifecycle_util.dart**: Lifecycle utilities
  - Application lifecycle listening and handling

- **link_util.dart**: Link handling utilities
  - Open external URLs, handle deep links, etc.

- **loading_util.dart**: Loading indicator utilities
  - Unified global loading display and dismissal

- **log_util.dart**: Logging utilities
  - Log encapsulation based on Talker
  - Supports different log levels and network log interception

- **permission_util.dart**: Permission management utilities
  - Permission request, checking and result handling

- **storage_util.dart**: Local storage utilities
  - Key-value storage based on SharedPreferences
  - Object serialization/deserialization and caching

- **throttle_util.dart**: Throttle and debounce utilities
  - Supports function-level throttling, specified time throttling
  - Supports debounce operations
  - Supports Future throttle and debounce

- **video_compress_util.dart**: Video compression utilities
  - Video compression based on `v_video_compressor`
  - Supports multi-level quality configuration, progress listening and thumbnail generation

## Main Dependencies

- **dio**: Network request library
- **talker_flutter / talker_dio_logger / talker_logger**: Logging system
- **shared_preferences**: Local storage
- **path_provider**: Path retrieval
- **permission_handler**: Permission management
- **crypto / encrypt**: Encryption library
- **flutter_svg**: SVG rendering
- **cached_network_image**: Network image caching
- **package_info_plus**: Application information
- **device_info_plus**: Device information
- **app_settings**: Open system settings page
- **map_launcher**: Launch map navigation
- **connectivity_plus**: Network status
- **url_launcher**: URL launcher
- **app_links**: Deep links
- **flutter_easyloading**: Loading indicator
- **wechat_assets_picker / wechat_camera_picker**: Media picking and capturing
- **flutter_image_compress**: Image compression
- **v_video_compressor**: Video compression

## Usage Examples

### Network Request

```dart
// Initialize network client
NetworkClient.init(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 30),
);

// Make a request
final response = await NetworkClient().fetch(
  NetworkRequest(
    apiPath: '/users',
    method: RequestMethod.get,
  ),
);
```

### Storage Operations

```dart
// Initialize storage
await StorageUtil.init();

// Save data
await StorageUtil.setValue('key', 'value');
await StorageUtil.setObject('user', {'name': 'John'});

// Read data
final value = StorageUtil.getValue('key');
final user = StorageUtil.getObject('user');
```

### Logging

```dart
// Log messages
LogUtil.info('This is an info log');
LogUtil.error('This is an error log');
LogUtil.debug('This is a debug log');
```

### String Extensions

```dart
// Using string extensions
final phone = '13800138000';
if (phone.isMobileExact()) {
  print('Valid phone number');
}

final amount = '1234.56';
print(amount.toMoneyFormat()); // Output: 1,234.56
```

## Author

[happy-flutter](https://github.com/happy-flutter)

## License

Scaffold_Core is available under the MIT license. See the LICENSE file for more info.
