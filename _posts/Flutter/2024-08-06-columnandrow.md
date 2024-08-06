---
title:  "Column And Row" 
excerpt: "Column And Row"

categories:
  - Flutter
tags:
  - [Column And Row, 플러터, Github, ]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06

---
<img src="assets/images/comn-row.png" width="450px" height="450px" title="컬럼과로우의이해" alt="컬럼과로우"><br/>

플러터에서 `Column`과 `Row` 위젯은 레이아웃을 구성하는 데 매우 중요한 역할을 합니다. 이 두 위젯은 자식 위젯들을 수직 또는 수평으로 배치할 수 있게 해줍니다. 각각의 특성과 사용 방법에 대해 자세히 설명하겠습니다.

### Column 위젯

`Column` 위젯은 자식 위젯들을 수직으로 정렬합니다. 자식 위젯들은 위에서 아래로 배치되며, 주로 세로 방향의 레이아웃을 만들 때 사용됩니다.

#### 주요 속성
- **children**: Column에 포함될 자식 위젯들의 리스트입니다.
- **mainAxisAlignment**: 자식 위젯들이 주 축(main axis)에서 어떻게 정렬될지를 결정합니다. 예를 들어, `MainAxisAlignment.start`, `MainAxisAlignment.center`, `MainAxisAlignment.end`, `MainAxisAlignment.spaceBetween`, `MainAxisAlignment.spaceAround`, `MainAxisAlignment.spaceEvenly` 등이 있습니다.
- **crossAxisAlignment**: 교차 축(cross axis)에서 자식 위젯들의 정렬을 설정합니다. `CrossAxisAlignment.start`, `CrossAxisAlignment.center`, `CrossAxisAlignment.end`, `CrossAxisAlignment.stretch` 등을 사용할 수 있습니다.
- **mainAxisSize**: Column의 주 축 크기를 결정합니다. `MainAxisSize.max` (기본값)와 `MainAxisSize.min`이 있습니다.

#### 예제
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    Text('첫 번째 텍스트'),
    Text('두 번째 텍스트'),
    ElevatedButton(onPressed: () {}, child: Text('버튼')),
  ],
)
```

### Row 위젯

`Row` 위젯은 자식 위젯들을 수평으로 정렬합니다. 자식 위젯들은 왼쪽에서 오른쪽으로 배치되며, 주로 가로 방향의 레이아웃을 만들 때 사용됩니다.

#### 주요 속성
- **children**: Row에 포함될 자식 위젯들의 리스트입니다.
- **mainAxisAlignment**: 자식 위젯들이 주 축에서 어떻게 정렬될지를 결정합니다. `MainAxisAlignment.start`, `MainAxisAlignment.center`, `MainAxisAlignment.end`, `MainAxisAlignment.spaceBetween`, `MainAxisAlignment.spaceAround`, `MainAxisAlignment.spaceEvenly`를 사용할 수 있습니다.
- **crossAxisAlignment**: 교차 축에서 자식 위젯들의 정렬을 설정합니다. `CrossAxisAlignment.start`, `CrossAxisAlignment.center`, `CrossAxisAlignment.end`, `CrossAxisAlignment.stretch` 등을 사용할 수 있습니다.
- **mainAxisSize**: Row의 주 축 크기를 결정합니다. `MainAxisSize.max` (기본값)과 `MainAxisSize.min`이 있습니다.

#### 예제
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
    Icon(Icons.home),
    Icon(Icons.favorite),
    Icon(Icons.settings),
  ],
)
```

### Column과 Row의 조합

`Column`과 `Row` 위젯은 함께 사용하여 복잡한 레이아웃을 구성할 수 있습니다. 
예를 들어, `Column` 안에 `Row`를 넣어 세로 방향으로 정렬된 아이템 사이에 가로 방향의 아이콘을 추가하는 방식입니다.

#### 예제
```dart
Column(
  children: <Widget>[
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(Icons.home),
        Icon(Icons.favorite),
      ],
    ),
    Text('세로 텍스트'),
    ElevatedButton(onPressed: () {}, child: Text('버튼')),
  ],
)
```

### 결론

`Column`과 `Row` 위젯은 Flutter에서 레이아웃을 구성하는 데 필수적입니다. 
각각의 위젯은 다양한 속성을 통해 자식 위젯들의 정렬과 배치를 유연하게 조정할 수 있으며, 
이를 통해 사용자 인터페이스를 직관적으로 설계할 수 있습니다.
