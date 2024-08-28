---
title:  "key and globalkey" 
excerpt: "key and globalKey"

categories:
  - Flutter
tags:
  - [key, widget, Github,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06
comments: true
---

Dart와 Flutter에서 `Key`와 `GlobalKey`는 위젯의 식별과 상태 관리를 위해 중요한 역할을 합니다. 이들은 특히 복잡한 위젯 트리와 상태를 관리할 때 유용합니다. 아래에서 `Key`와 `GlobalKey`의 사용법과 중요성을 매우 상세하게 설명하겠습니다.

## Key

### 1. 기본 개념

`Key`는 위젯의 고유 식별자를 제공하여 Flutter가 위젯의 상태를 추적하고 올바르게 재구성할 수 있도록 돕습니다. 특히, 리스트나 컬렉션에서 위젯을 추가하거나 제거할 때 `Key`는 위젯의 상태를 유지하는 데 중요한 역할을 합니다.

### 2. 종류

- **ValueKey**: 값 기반으로 식별자를 설정합니다. `ValueKey`는 주로 값을 기반으로 위젯을 식별하는 데 사용됩니다.

  ```dart
  ValueKey<String>('myKey');
  ```

- **UniqueKey**: 유일한 식별자를 생성합니다. `UniqueKey`는 고유한 키를 생성하므로, 위젯이 고유한 식별자를 필요로 할 때 사용합니다.

  ```dart
  UniqueKey();
  ```

- **ObjectKey**: 객체를 기반으로 식별자를 설정합니다. `ObjectKey`는 객체의 `==` 연산자를 사용하여 비교합니다.

  ```dart
  ObjectKey(myObject);
  ```

### 3. 사용 예

리스트에서 `Key`를 사용하면 Flutter가 리스트의 항목을 효율적으로 재구성할 수 있습니다.

```dart
class MyWidget extends StatelessWidget {
  final List<String> items;

  MyWidget(this.items);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items.map((item) => ListTile(
        key: ValueKey(item),  // ValueKey를 사용하여 항목을 식별
        title: Text(item),
      )).toList(),
    );
  }
}
```

위 예제에서 `ValueKey`는 리스트의 각 항목을 식별하는 데 사용됩니다. 항목이 변경되면 Flutter는 `Key`를 사용하여 위젯을 올바르게 업데이트할 수 있습니다.

## GlobalKey

### 1. 기본 개념

`GlobalKey`는 전역적으로 고유한 식별자를 제공하여 위젯의 상태를 추적하거나 위젯의 컨텍스트에 접근할 수 있게 해줍니다. `GlobalKey`는 위젯 트리에서 특정 위젯의 상태를 직접 접근할 수 있게 하여, 상태를 유지하거나 업데이트하는 데 유용합니다.

### 2. 사용 예

#### 2.1. 위젯의 상태 접근

`GlobalKey`를 사용하여 위젯의 상태에 접근할 수 있습니다. 예를 들어, 폼의 상태를 조작할 때 유용합니다.

```dart
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Process data.
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

여기서 `_formKey`는 `GlobalKey<FormState>`로 정의되어 폼의 상태를 접근하고 `validate()` 메서드를 호출할 수 있습니다.

#### 2.2. 위젯의 컨텍스트 접근

`GlobalKey`를 사용하여 위젯의 `BuildContext`에 접근할 수 있습니다.

```dart
class MyWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: Text('My Widget'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            widget.scaffoldKey.currentState?.showSnackBar(
              SnackBar(content: Text('Hello, world!')),
            );
          },
          child: Text('Show SnackBar'),
        ),
      ),
    );
  }
}
```

여기서 `scaffoldKey`는 `GlobalKey<ScaffoldState>`로 정의되어 `Scaffold`의 상태를 직접 조작할 수 있습니다.

### 3. 주의사항

- **성능 고려**: `GlobalKey`는 비교적 무겁고, 많은 `GlobalKey`를 사용하면 성능 문제를 일으킬 수 있습니다. 필요한 경우에만 사용하고, 가능한 경우 `LocalKey`나 `ValueKey`를 사용하는 것이 좋습니다.
- **전역 상태 관리**: `GlobalKey`는 전역적으로 접근할 수 있는 상태를 관리할 수 있지만, 모든 상태를 전역으로 관리하는 것은 권장되지 않습니다. 상태 관리 패턴 (예: Provider, Bloc)을 고려하는 것이 좋습니다.

### 요약

- **`Key`**는 위젯의 식별자를 제공하여 상태를 효율적으로 관리하는 데 사용됩니다. `ValueKey`, `UniqueKey`, `ObjectKey` 등의 타입이 있으며, 주로 리스트나 컬렉션에서 위젯을 식별하는 데 유용합니다.
- **`GlobalKey`**는 전역적으로 고유한 식별자를 제공하여 위젯의 상태에 접근하거나 위젯의 컨텍스트에 접근할 수 있게 해줍니다. 상태 관리 및 특정 위젯에 대한 직접적인 접근이 필요할 때 사용됩니다.

이해를 돕기 위해 간단한 예제와 함께 개념을 설명하였습니다. `Key`와 `GlobalKey`를 올바르게 사용하면 Flutter 애플리케이션의 상태와 레이아웃을 보다 효율적으로 관리할 수 있습니다.
