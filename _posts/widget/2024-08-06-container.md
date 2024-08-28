---
title:  "Container-컨테이너" 
excerpt: "Container-컨테이너"

categories:
  - Widget
tags:
  - [Container, 플러터, 컨테이너,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06
comments: true
---

Flutter에서 `Container` 위젯은 매우 유용한 레이아웃 도구입니다. 기본적으로 `Container`는 자식 위젯을 담는 박스 역할을 하며, 다양한 스타일링과 레이아웃 기능을 제공합니다. 아래에서 `Container`의 주요 속성과 그 사용법을 자세히 설명하겠습니다.

### 1. `Container`의 기본 구조

```dart
Container(
  width: 100.0,
  height: 100.0,
  color: Colors.blue,
  child: Text('Hello, World!'),
)
```

### 2. 주요 속성

- **`width`** 및 **`height`**: `Container`의 너비와 높이를 설정합니다. 설정하지 않으면 자식 위젯의 크기에 따라 자동으로 조정됩니다.

- **`color`**: `Container`의 배경 색상을 설정합니다. `Color` 클래스를 사용하여 색상을 지정할 수 있습니다.

- **`padding`**: `Container`의 내부 여백을 설정합니다. `EdgeInsets` 클래스를 사용하여 상하좌우의 여백을 지정할 수 있습니다.

  ```dart
  padding: EdgeInsets.all(16.0)
  ```

- **`margin`**: `Container`의 외부 여백을 설정합니다. `EdgeInsets` 클래스를 사용하여 여백을 지정할 수 있습니다.

  ```dart
  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0)
  ```

- **`decoration`**: `Container`의 외형을 꾸미기 위한 속성입니다. `BoxDecoration` 클래스를 사용하여 배경 색상, 테두리, 그림자, 모서리 둥글기 등을 설정할 수 있습니다.

  ```dart
  decoration: BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  )
  ```

- **`alignment`**: `Container` 내부의 자식 위젯의 정렬을 설정합니다. `Alignment` 클래스를 사용하여 자식 위젯의 위치를 조정할 수 있습니다.

  ```dart
  alignment: Alignment.center
  ```

- **`constraints`**: `Container`의 제약 조건을 설정합니다. `BoxConstraints` 클래스를 사용하여 최소 및 최대 너비와 높이를 정의할 수 있습니다.

  ```dart
  constraints: BoxConstraints(
    minWidth: 100.0,
    maxWidth: 200.0,
  )
  ```

- **`transform`**: `Container`를 변형할 수 있는 속성입니다. `Matrix4` 클래스를 사용하여 회전, 크기 조절, 이동 등을 적용할 수 있습니다.

  ```dart
  transform: Matrix4.rotationZ(0.1),
  ```

- **`child`**: `Container`의 자식 위젯을 설정합니다. `Container` 안에는 단일 위젯만을 포함할 수 있습니다. 여러 위젯을 포함하려면 `Column`, `Row`, `Stack` 등의 레이아웃 위젯을 사용해야 합니다.

### 3. 예제

다양한 속성을 조합하여 `Container`를 활용할 수 있습니다.

```dart
Container(
  width: 150.0,
  height: 150.0,
  margin: EdgeInsets.all(10.0),
  padding: EdgeInsets.all(20.0),
  decoration: BoxDecoration(
    color: Colors.red,
    borderRadius: BorderRadius.circular(15.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 10.0,
        offset: Offset(5.0, 5.0),
      ),
    ],
  ),
  alignment: Alignment.center,
  transform: Matrix4.rotationZ(0.1),
  child: Text(
    'Styled Container',
    style: TextStyle(color: Colors.white, fontSize: 16),
  ),
)
```

이 예제에서는 `Container`를 사용하여 배경색, 모서리 둥글기, 그림자, 여백, 패딩, 자식 위젯의 정렬 및 텍스트 스타일링을 설정했습니다.

`Container`는 Flutter에서 매우 기본적이지만 강력한 레이아웃 도구이며, 다양한 속성과 기능을 활용하여 원하는 UI를 구현할 수 있습니다.
