---
title:  "Skeletons-로딩상태임시보여주시" 
excerpt: "skeletons"

categories:
  - Package
tags:
  - [skeletons, flutter, widget, package]

toc: true
toc_sticky: true
 
date: 2024-09-24
last_modified_at: 2024-09-24
comments: true
---


플러터(Flutter)에서 **Skeletons 패키지**는 로딩 상태를 사용자에게 자연스럽게 보여주기 위해 사용되는 라이브러리입니다. 애플리케이션에서 데이터가 로드될 때, 콘텐츠 대신 뼈대(Skeleton) 모양의 로딩 화면을 보여주어 사용자가 콘텐츠를 기다리며 앱이 멈춘 것처럼 보이지 않도록 합니다. 이를 통해 사용자 경험을 향상시키고, 로딩 상태에서도 비주얼 피드백을 제공합니다.

### 주요 특징
1. **쉬운 사용**: 간단하게 구현하여 UI 요소의 로딩 상태를 시각적으로 표현할 수 있습니다.
2. **다양한 커스터마이징 가능**: Skeleton의 모양, 색상, 애니메이션 속도 등을 조정할 수 있습니다.
3. **다양한 위젯 지원**: 텍스트, 이미지, 버튼 등 다양한 UI 요소에 적용할 수 있습니다.
4. **애니메이션 지원**: Skeleton 패키지는 일반적인 로딩 화면에 애니메이션을 추가하여 더 생동감 있는 사용자 경험을 제공합니다.

### 설치 방법
`pubspec.yaml` 파일에 다음 의존성을 추가하여 설치할 수 있습니다.

```yaml
dependencies:
  skeletons: ^0.0.2
```

그런 다음 `flutter pub get` 명령어를 실행하여 패키지를 설치합니다.

### 사용 방법
아래는 `Skeleton` 패키지를 사용하는 기본적인 예시입니다.

```dart
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Skeleton Example')),
        body: SkeletonListView(),
      ),
    );
  }
}

class SkeletonListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeleton(
      isLoading: true,  // true일 경우 skeleton을 표시합니다.
      skeleton: SkeletonListTile(
        leadingStyle: SkeletonAvatarStyle(
          shape: BoxShape.circle,  // 원형 아바타 스타일
        ),
        titleStyle: SkeletonLineStyle(),
        hasSubtitle: true,  // 부제목 여부
      ),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          title: Text('Loaded Item $index'),
        ),
      ),
    );
  }
}
```

### 주요 위젯
1. **Skeleton**: Skeleton을 감싸서 로딩 상태일 때만 뼈대를 표시합니다.
2. **SkeletonListTile**: 리스트 아이템 모양의 스켈레톤입니다.
3. **SkeletonAvatar**: 아바타(이미지)를 대신할 수 있는 스켈레톤입니다.
4. **SkeletonLine**: 텍스트나 선 모양의 스켈레톤을 만들 때 사용됩니다.

### 커스터마이징
- **애니메이션**: `shimmer` 효과나 `pulse` 효과 등을 설정할 수 있습니다.
- **색상**: `color`, `highlightColor` 등을 통해 로딩 시 스켈레톤의 색상을 조정할 수 있습니다.
  
```dart
Skeleton(
  isLoading: true,
  skeleton: SkeletonAvatar(
    style: SkeletonAvatarStyle(
      shape: BoxShape.circle,
      width: 50,
      height: 50,
    ),
  ),
  child: CircleAvatar(
    radius: 25,
    backgroundImage: NetworkImage('https://example.com/avatar.png'),
  ),
);
```

위 예제는 아바타가 로드되는 동안 원형의 Skeleton이 보여지는 모습을 나타냅니다.

### 마무리
**Skeleton 패키지**는 플러터 앱에서 사용자가 데이터를 기다리는 동안 
더 나은 사용자 경험을 제공하기 위한 중요한 도구입니다. 간편하게 로딩 상태를 시각적으로 표현할 수 있으며, 
다양한 커스터마이징 옵션을 통해 앱의 스타일에 맞는 로딩 UI를 구현할 수 있습니다.
