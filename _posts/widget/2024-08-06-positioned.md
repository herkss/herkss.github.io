---
title:  "Positioned" 
excerpt: "Positioned"

categories:
  - Widget
tags:
  - [Positioned, 플러터, 포지션드,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06
comments: true
---

`Positioned` 위젯은 Flutter의 `Stack` 위젯 내에서 자식 위젯의 위치를 절대적으로 지정할 수 있게 해줍니다. `Stack`은 여러 위젯을 쌓아서 배치할 수 있는 위젯으로, `Positioned` 위젯을 사용하면 `Stack` 내에서 자식 위젯의 정확한 위치를 설정할 수 있습니다.

### 1. 기본 구조

`Positioned` 위젯은 `Stack` 위젯 내에서만 사용할 수 있습니다. `Positioned`는 자식 위젯의 위치를 설정하는 역할을 합니다.

```dart
Stack(
  children: <Widget>[
    Container(color: Colors.red, width: 200, height: 200),
    Positioned(
      left: 20,
      top: 20,
      child: Container(color: Colors.blue, width: 100, height: 100),
    ),
  ],
)
```

이 예제에서 `Stack` 위젯은 빨간색 `Container`를 배경으로 하고, 그 위에 파란색 `Container`를 `left`와 `top` 속성을 사용하여 배치합니다.

### 2. 주요 속성

- **`top`**: 위젯의 상단에서의 거리입니다. 기본값은 `null`이며, 설정하지 않으면 상단에서의 거리는 0으로 간주됩니다.

  ```dart
  Positioned(
    top: 20,
    child: Text('Top 20'),
  )
  ```

- **`right`**: 위젯의 오른쪽에서의 거리입니다. 기본값은 `null`입니다.

  ```dart
  Positioned(
    right: 20,
    child: Text('Right 20'),
  )
  ```

- **`bottom`**: 위젯의 하단에서의 거리입니다. 기본값은 `null`입니다.

  ```dart
  Positioned(
    bottom: 20,
    child: Text('Bottom 20'),
  )
  ```

- **`left`**: 위젯의 왼쪽에서의 거리입니다. 기본값은 `null`입니다.

  ```dart
  Positioned(
    left: 20,
    child: Text('Left 20'),
  )
  ```

- **`width`**: 위젯의 너비를 설정합니다. 기본값은 `null`이며, 설정하지 않으면 자식 위젯의 기본 너비가 사용됩니다.

  ```dart
  Positioned(
    width: 100,
    child: Container(color: Colors.green),
  )
  ```

- **`height`**: 위젯의 높이를 설정합니다. 기본값은 `null`이며, 설정하지 않으면 자식 위젯의 기본 높이가 사용됩니다.

  ```dart
  Positioned(
    height: 100,
    child: Container(color: Colors.yellow),
  )
  ```

### 3. 사용 예제

다양한 속성을 활용하여 `Positioned` 위젯을 사용한 예제를 살펴보겠습니다.

```dart
Stack(
  children: <Widget>[
    Container(color: Colors.grey[300], width: 300, height: 300),
    Positioned(
      left: 10,
      top: 10,
      child: Container(color: Colors.red, width: 80, height: 80),
    ),
    Positioned(
      right: 10,
      bottom: 10,
      child: Container(color: Colors.blue, width: 80, height: 80),
    ),
    Positioned(
      left: 50,
      bottom: 50,
      width: 100,
      height: 100,
      child: Container(color: Colors.green),
    ),
  ],
)
```

이 예제에서는:
- 상단 왼쪽에 빨간색 `Container`를 위치시키기 위해 `left`와 `top` 속성을 사용했습니다.
- 하단 오른쪽에 파란색 `Container`를 위치시키기 위해 `right`와 `bottom` 속성을 사용했습니다.
- 상단 왼쪽에서 조금 떨어진 곳에 녹색 `Container`를 배치하기 위해 `left`와 `bottom` 속성을 설정했습니다.

### 4. `Positioned`의 동작 원리

`Positioned` 위젯은 `Stack` 내에서 상대적인 위치를 지정하는데 사용됩니다. `top`, `right`, `bottom`, `left` 속성 중 하나 이상을 설정하여 자식 위젯의 위치를 정의합니다. 

- **상단과 왼쪽**: `top`과 `left` 속성은 `Stack`의 상단과 왼쪽 모서리에서 자식 위젯까지의 거리를 정의합니다.
- **하단과 오른쪽**: `bottom`과 `right` 속성은 `Stack`의 하단과 오른쪽 모서리에서 자식 위젯까지의 거리를 정의합니다.

### 5. 제한 사항

- `Positioned` 위젯은 `Stack` 위젯의 자식으로만 사용할 수 있습니다.
- 모든 `Positioned` 속성 값을 지정할 필요는 없습니다. 필요한 속성만 설정하면 됩니다.

`Positioned` 위젯은 복잡한 레이아웃을 구성할 때 매우 유용합니다. 다양한 위치 속성을 활용하여 `Stack` 내에서 자식 위젯을 정확하게 배치할 수 있습니다.
