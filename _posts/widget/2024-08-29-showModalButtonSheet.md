---
title:  "ShowModalButtonSheet" 
excerpt: "ShowModalButtonSheet"

categories:
  - Widget
tags:
  - [ShowModalButtonSheet, flutter ]

toc: true
toc_sticky: true
 
date: 2024-07-26
last_modified_at: 2024-07-26
comments: true
---

# ShowModalButtonSheet

`showModalBottomSheet`는 Flutter에서 화면 하단에서 올라오는 모달 시트를 보여주는 데 사용되는 위젯입니다. 모달 시트는 사용자와의 상호작용을 위해 자주 사용되며, 선택 옵션, 사용자 입력, 추가 정보 등을 제공하는 데 적합합니다. 

### 기본 사용법

`showModalBottomSheet`의 기본 사용법은 다음과 같습니다:

```dart
showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Text('Hello from the bottom sheet!'),
      ),
    );
  },
);
```

### 주요 매개변수

1. **context**: `BuildContext`는 `showModalBottomSheet`를 호출하는 위젯의 컨텍스트입니다. 이 컨텍스트는 현재 위젯 트리에서 위치를 식별하는 데 사용됩니다.

2. **builder**: `builder`는 `BottomSheet`의 내용을 구성하는 위젯을 반환하는 함수입니다. `BuildContext`를 매개변수로 받아 `Widget`을 반환합니다.

### 고급 사용법

다양한 사용자 인터페이스 요구 사항에 맞게 `showModalBottomSheet`를 구성할 수 있습니다. 다음은 몇 가지 예제입니다.

#### 1. 리스트 항목을 포함한 바텀 시트

리스트를 포함하여 여러 항목을 선택할 수 있는 모달 시트를 만드는 예제입니다.

```dart
showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Container(
      height: 300,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.access_alarm),
            title: Text('Option 1'),
            onTap: () {
              Navigator.pop(context); // 바텀 시트 닫기
            },
          ),
          ListTile(
            leading: Icon(Icons.accessibility),
            title: Text('Option 2'),
            onTap: () {
              Navigator.pop(context); // 바텀 시트 닫기
            },
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Option 3'),
            onTap: () {
              Navigator.pop(context); // 바텀 시트 닫기
            },
          ),
        ],
      ),
    );
  },
);
```

#### 2. 사용자 입력 폼을 포함한 바텀 시트

사용자 입력을 받을 수 있는 폼을 포함한 모달 시트를 만드는 예제입니다.

```dart
showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Enter your name:'),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Your name',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () {
              Navigator.pop(context); // 바텀 시트 닫기
            },
          ),
        ],
      ),
    );
  },
);
```

#### 3. `isDismissible`과 `enableDrag` 속성 사용

`isDismissible`과 `enableDrag`을 사용하여 바텀 시트의 드래그와 닫기를 제어할 수 있습니다.

```dart
showModalBottomSheet(
  context: context,
  isDismissible: true, // 탭하여 닫을 수 있게 설정
  enableDrag: true, // 드래그하여 닫을 수 있게 설정
  builder: (BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Text('Drag down to dismiss'),
      ),
    );
  },
);
```

### 요약

- `showModalBottomSheet`는 화면 하단에서 모달 시트를 보여줍니다.
- `context`와 `builder` 매개변수를 사용하여 시트의 내용과 동작을 정의합니다.
- 다양한 위젯과 레이아웃을 사용하여 사용자 인터페이스를 구성할 수 있습니다.

이렇게 `showModalBottomSheet`를 활용하여 다양한 사용자 상호작용을 구현할 수 있습니다.
