---
title:  "상태관리-state management" 
excerpt: "상태관리-state management"

categories:
  - Flutter
tags:
  - [state, state_management, flutter, widget,]

toc: true
toc_sticky: true
 
date: 2024-08-07
last_modified_at: 2024-08-07
comments: true
---

Flutter의 상태 관리는 애플리케이션의 UI와 데이터 간의 동기화를 관리하는 중요한 개념입니다. 상태란 애플리케이션의 현재 상황을 나타내는 데이터로, 사용자 인터페이스(UI)가 어떻게 보여야 하는지를 결정합니다. 상태 관리의 목적은 UI가 상태 변화에 따라 적절하게 업데이트되도록 하는 것입니다.

### 1. **상태의 종류**

- **로컬 상태**: 특정 위젯에만 관련된 상태로, 해당 위젯 내에서만 사용됩니다. 예를 들어, 버튼의 클릭 여부나 텍스트 필드의 입력값 등이 있습니다.
- **글로벌 상태**: 애플리케이션 전역에서 사용되는 상태로, 여러 위젯에서 공유됩니다. 예를 들어, 사용자 인증 정보나 장바구니의 아이템 수 등이 있습니다.

### 2. **상태 관리 방법**

Flutter에서는 여러 가지 상태 관리 방법이 있습니다. 각 방법은 특정 상황에 따라 장단점이 있으므로, 필요에 따라 적절한 방법을 선택해야 합니다.

#### 1. **setState()**

가장 기본적인 상태 관리 방법으로, StatefulWidget에서 사용됩니다. 상태가 변경되면 `setState()`를 호출하여 UI를 업데이트합니다.

```dart
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

#### 2. **InheritedWidget**

상태를 위젯 트리의 상위에서 하위로 전달할 수 있는 방법입니다. 여러 위젯에서 동일한 상태를 공유할 수 있습니다.

```dart
class MyInheritedWidget extends InheritedWidget {
  final int data;

  MyInheritedWidget({required this.data, required Widget child}) : super(child: child);

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return oldWidget.data != data;
  }
}
```

#### 3. **Provider 패키지**

가장 널리 사용되는 상태 관리 패턴 중 하나로, InheritedWidget을 기반으로 하여 더 간편하게 상태를 관리할 수 있습니다. `ChangeNotifier`를 사용하여 상태 변화를 감지하고 UI를 업데이트합니다.

```dart
class Counter with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 상태 변화 알림
  }
}

// 사용 예
ChangeNotifierProvider(
  create: (context) => Counter(),
  child: MyApp(),
);
```

#### 4. **Riverpod**

Provider의 발전된 형태로, 더 안전하고 유연한 상태 관리를 제공합니다. 전역 상태를 쉽게 관리할 수 있으며, 테스트가 용이합니다.

```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() {
    state++;
  }
}
```

### 3. **상태 관리 선택 기준**

- **애플리케이션의 규모**: 작은 앱은 `setState()`로 충분할 수 있지만, 큰 앱은 Provider나 Riverpod 같은 패턴이 더 적합합니다.
- **상태의 복잡성**: 상태가 복잡하고 여러 위젯에서 공유된다면, InheritedWidget이나 Provider를 사용하는 것이 좋습니다.
- **유지보수성**: 코드의 가독성과 유지보수성을 고려하여 적절한 상태 관리 방법을 선택해야 합니다.










### 4. **결론**







Flutter의 상태 관리는 애플리케이션의 UI와 데이터 간의 동기화를 관리하는 중요한 요소입니다. 다양한 상태 관리 방법이 있으며, 각 방법의 장단점을 이해하고 애플리케이션의 요구에 맞는 방법을 선택하는 것이 중요합니다. 상태 관리의 올바른 사용은 애플리케이션의 성능과 유지보수성을 크게 향상시킬 수 있습니다. 

