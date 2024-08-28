---
title:  "decoration" 
excerpt: "decoration"

categories:
  - Widget
tags:
  - [decoration, 플러터, 데코레이션,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06
comments: true
---
Flutter의 `BoxDecoration` 클래스는 위젯의 시각적 디자인을 꾸미는 데 사용됩니다. 주로 `Container` 위젯의 `decoration` 속성에 활용되며, 다양한 시각적 속성을 설정할 수 있습니다. `BoxDecoration`은 배경색, 테두리, 그림자, 모서리 둥글기 등 여러 스타일 속성을 지원합니다.

### `BoxDecoration`의 주요 속성

1. **`color`**
   - 배경 색상을 설정합니다.
   - `Color` 클래스를 사용하여 색상을 정의합니다.

   ```dart
   BoxDecoration(
     color: Colors.blue,
   )
   ```

2. **`border`**
   - 테두리를 설정합니다.
   - `Border` 클래스와 그 하위 클래스 (`BorderSide`)를 사용하여 테두리의 두께, 색상, 스타일 등을 정의합니다.

   ```dart
   BoxDecoration(
     border: Border.all(
       color: Colors.black,
       width: 2.0,
     ),
   )
   ```

   ```dart
   BoxDecoration(
     border: Border(
       top: BorderSide(color: Colors.red, width: 4.0),
       bottom: BorderSide(color: Colors.blue, width: 2.0),
     ),
   )
   ```

3. **`borderRadius`**
   - 모서리의 둥글기를 설정합니다.
   - `BorderRadius` 클래스를 사용하여 각 모서리의 둥글기를 정의합니다.

   ```dart
   BoxDecoration(
     borderRadius: BorderRadius.circular(15.0),
   )
   ```

   ```dart
   BoxDecoration(
     borderRadius: BorderRadius.only(
       topLeft: Radius.circular(10.0),
       bottomRight: Radius.circular(20.0),
     ),
   )
   ```

4. **`boxShadow`**
   - 위젯에 그림자를 추가합니다.
   - `BoxShadow` 클래스를 사용하여 그림자의 색상, 흐림 반경, 확산 반경, 위치 등을 설정합니다.

   ```dart
   BoxDecoration(
     boxShadow: [
       BoxShadow(
         color: Colors.black.withOpacity(0.5),
         blurRadius: 10.0,
         spreadRadius: 2.0,
         offset: Offset(0, 4),
       ),
     ],
   )
   ```

5. **`gradient`**
   - 그라데이션 배경을 설정합니다.
   - `LinearGradient`, `RadialGradient`, `SweepGradient` 클래스를 사용하여 다양한 그라데이션 효과를 적용할 수 있습니다.

   ```dart
   BoxDecoration(
     gradient: LinearGradient(
       colors: [Colors.red, Colors.orange],
       begin: Alignment.topLeft,
       end: Alignment.bottomRight,
     ),
   )
   ```

   ```dart
   BoxDecoration(
     gradient: RadialGradient(
       colors: [Colors.blue, Colors.transparent],
       center: Alignment.center,
       radius: 0.5,
     ),
   )
   ```

6. **`image`**
   - 배경 이미지 설정을 지원합니다.
   - `DecorationImage` 클래스를 사용하여 이미지를 배경으로 설정하고, 이미지의 위치와 크기를 조정할 수 있습니다.

   ```dart
   BoxDecoration(
     image: DecorationImage(
       image: NetworkImage('https://example.com/image.jpg'),
       fit: BoxFit.cover,
     ),
   )
   ```

7. **`shape`**
   - 박스의 형태를 설정합니다.
   - `BoxShape.rectangle` (기본값)과 `BoxShape.circle`을 사용하여 사각형 또는 원형 박스를 정의할 수 있습니다.

   ```dart
   BoxDecoration(
     shape: BoxShape.circle,
     color: Colors.blue,
   )
   ```

### 사용 예제

여러 속성을 조합하여 `BoxDecoration`을 활용한 예제를 살펴보겠습니다.

```dart
Container(
  width: 200,
  height: 200,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.0),
    border: Border.all(color: Colors.black, width: 2.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10.0,
        offset: Offset(5, 5),
      ),
    ],
    gradient: LinearGradient(
      colors: [Colors.blue, Colors.purple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    image: DecorationImage(
      image: AssetImage('assets/images/background.png'),
      fit: BoxFit.cover,
    ),
  ),
)
```

이 예제에서는 다음과 같은 스타일을 설정하고 있습니다:
- 배경 색상: 흰색
- 모서리 둥글기: 20.0
- 테두리: 검정색, 두께 2.0
- 그림자: 흐림 반경 10.0, 위치 (5, 5)
- 그라데이션: 파랑에서 보라색으로
- 배경 이미지: 자산에서 로드한 이미지

### 요약

`BoxDecoration`은 Flutter에서 위젯의 시각적 디자인을 구성하는 데 매우 강력한 도구입니다. 
배경 색상, 테두리, 그림자, 그라데이션, 이미지, 형태 등을 설정하여 다양한 디자인 효과를 적용할 수 있습니다. 
`Container`, `DecoratedBox`와 같은 위젯에서 `BoxDecoration`을 사용하여 복잡한 레이아웃과 스타일링을 손쉽게 구현할 수 있습니다.
