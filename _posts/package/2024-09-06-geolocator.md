---
title:  "geolocator-위치정보가져오기" 
excerpt: "geolocator"

categories:
  - Package
tags:
  - [geolocator, flutter, package, 위치정보가져오기,]

toc: true
toc_sticky: true
 
date: 2024-09-06
last_modified_at: 2024-09-06
comments: true
---

`geolocator` 패키지는 Flutter에서 위치 정보를 쉽게 가져올 수 있도록 도와주는 패키지입니다. 이를 통해 사용자의 현재 위치를 가져오거나, 위치 기반 서비스를 구현할 수 있습니다.

### 주요 기능

- **현재 위치 가져오기**: 사용자의 현재 위치를 GPS 또는 네트워크를 통해 가져올 수 있습니다.
- **위치 추적**: 위치 변화를 지속적으로 모니터링할 수 있습니다.
- **위치 권한 요청**: 위치 권한을 요청하고 관리할 수 있습니다.

### 설치

`pubspec.yaml` 파일에 `geolocator` 패키지를 추가합니다:

```yaml
dependencies:
  geolocator: ^9.0.0  # 최신 버전으로 변경될 수 있습니다.
```

그런 다음 패키지를 설치합니다:

```bash
flutter pub get
```

### 기본 사용법

다음은 `geolocator`를 사용하여 사용자의 현재 위치를 가져오는 간단한 예제입니다.

**1. 권한 요청 및 위치 접근 설정**

**AndroidManifest.xml** (Android 설정)

`android/app/src/main/AndroidManifest.xml`에 위치 접근 권한을 추가합니다.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**Info.plist** (iOS 설정)

`ios/Runner/Info.plist`에 위치 접근 권한 요청을 추가합니다.

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to provide accurate information.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to provide accurate information.</string>
```

**2. 위치 정보를 가져오는 예제**

**`main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // 위치 권한 확인 및 요청
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _message = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        setState(() {
          _message = 'Location permissions are denied';
        });
        return;
      }
    }

    // 현재 위치 가져오기
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _message = '';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to get location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Example')),
      body: Center(
        child: _currentPosition == null
            ? Text(_message)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Latitude: ${_currentPosition!.latitude}'),
                  Text('Longitude: ${_currentPosition!.longitude}'),
                ],
              ),
      ),
    );
  }
}
```

### 설명

1. **권한 요청 및 확인**:
   - `Geolocator.isLocationServiceEnabled()`를 사용하여 위치 서비스가 활성화되어 있는지 확인합니다.
   - `Geolocator.checkPermission()`과 `Geolocator.requestPermission()`을 사용하여 위치 권한을 확인하고 요청합니다.

2. **현재 위치 가져오기**:
   - `Geolocator.getCurrentPosition()`을 사용하여 현재 위치를 가져옵니다. `desiredAccuracy`를 설정하여 위치 정확도를 조정할 수 있습니다.

3. **UI 업데이트**:
   - 위치 정보를 가져오면 상태를 업데이트하여 UI에 위치를 표시합니다. 위치 정보가 없거나 오류가 발생하면 적절한 메시지를 표시합니다.

이 예제를 통해 `geolocator` 패키지를 사용하여 Flutter 앱에서 위치 정보를 가져오고 사용할 수 있습니다.
