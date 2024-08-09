---
title:  "Validation 유효성검사" 
excerpt: "유효성검사 Validation"

categories:
  - Flutter
tags:
  - [validation, validator, flutter, widget,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06
comments: true
---

Flutter에서 폼 유효성 검사는 사용자 입력을 검증하고 올바른 데이터만 서버로 전송되도록 하는 중요한 기능입니다. Flutter에서 폼 유효성 검사를 구현하려면 `Form`, `TextFormField`, 및 `Validator`를 사용합니다.

### 설명

- **`Form` 위젯**: 여러 개의 `TextFormField`를 포함할 수 있으며, 폼 전체에 대해 유효성 검사를 관리합니다.
- **`TextFormField` 위젯**: 사용자로부터 텍스트 입력을 받을 수 있는 필드입니다.
- **`Validator`**: 유효성 검사를 정의하는 함수로, `TextFormField`의 `validator` 속성에 사용됩니다.

### 예제 코드

다음은 Flutter에서 유효성 검사를 사용하는 간단한 예제입니다. 사용자가 입력한 이메일과 비밀번호가 유효한지 검증하는 폼을 만들어보겠습니다.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Validation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingController는 상태를 관리하기 위해 필요합니다
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Validation Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  // 이메일 형식 유효성 검사
                  final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  // 비밀번호 길이 검사
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // If the form is valid, display a snackbar. In a real app, you'd often want to use
                      // a Navigator to move to another screen or show some other response.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 설명

1. **`_formKey`**: `Form` 위젯의 상태를 관리하기 위해 필요합니다.
2. **`TextEditingController`**: 사용자가 입력한 값을 읽어오기 위해 필요합니다.
3. **`validator`**: `TextFormField`의 `validator` 속성에 유효성 검사 로직을 넣습니다.
   - 이메일 형식 유효성 검사와 비밀번호 길이 검사를 추가했습니다.
4. **`onPressed`**: 버튼을 눌렀을 때 폼의 유효성을 검사하고, 유효하면 `SnackBar`를 표시합니다.

이 코드를 통해 사용자는 이메일과 비밀번호를 입력하고 제출할 때 유효성 검사를 수행하여 오류 메시지를 받을 수 있습니다.



### autoValidateMode 


`autovalidateMode`와 `validate()` 메서드는 Flutter의 폼 유효성 검사에서 서로 다른 역할을 수행합니다. 이 두 가지의 차이를 아래와 같이 설명할 수 있습니다.

### 1. `autovalidateMode`
- **정의**: `autovalidateMode`는 `TextFormField`와 같은 입력 위젯에서 유효성 검사를 자동으로 수행하는 방식을 설정하는 속성입니다.
- **기능**:
  - 사용자가 입력을 시작하거나 특정 이벤트가 발생할 때 유효성 검사를 자동으로 실행합니다.
  - 세 가지 모드가 있습니다:
    - `AutovalidateMode.disabled`: 자동 유효성 검사를 비활성화합니다.
    - `AutovalidateMode.always`: 항상 유효성 검사를 수행합니다.
    - `AutovalidateMode.onUserInteraction`: 사용자가 입력을 시작한 후에만 유효성 검사를 수행합니다.
- **사용 목적**: 사용자에게 실시간 피드백을 제공하여 입력 오류를 즉시 알릴 수 있도록 합니다.

### 2. `validate()` 메서드
- **정의**: `validate()` 메서드는 `FormState` 클래스의 메서드로, 현재 폼의 모든 필드에 대해 유효성 검사를 수동으로 수행합니다.
- **기능**:
  - 호출 시 모든 입력 필드의 `validator` 함수를 실행하여 유효성을 검사합니다.
  - 각 필드의 유효성 검사 결과를 기반으로 true 또는 false를 반환합니다.
- **사용 목적**: 일반적으로 사용자가 제출 버튼을 클릭했을 때 호출되어 폼의 전체 유효성을 확인하고, 모든 필드가 유효한 경우에만 특정 작업(예: 데이터 저장)을 수행하도록 합니다.

### 요약
- **`autovalidateMode`**는 유효성 검사를 자동으로 수행하는 방식과 시점을 설정하는 속성입니다.
- **`validate()`**는 폼의 유효성을 수동으로 검사하는 메서드로, 주로 폼 제출 시 호출됩니다.

이 두 가지를 함께 사용하면, 사용자가 입력하는 동안 실시간으로 피드백을 제공하면서도, 최종적으로 제출할 때 전체 폼의 유효성을 확인할 수 있습니다. 
`autovalidateMode`는 Flutter의 `TextFormField`와 같은 입력 위젯에서 유효성 검사를 자동으로 수행하는 방식을 설정하는 데 사용됩니다. 이 속성을 통해 사용자가 입력하는 동안 유효성 검사를 어떻게 처리할지를 정의할 수 있습니다.

## `autovalidateMode`의 옵션
- **`AutovalidateMode.disabled`**: 자동 유효성 검사를 비활성화합니다. 사용자가 제출 버튼을 클릭할 때만 유효성 검사가 수행됩니다.
- **`AutovalidateMode.always`**: 입력 필드가 포커스를 잃거나 사용자가 입력을 시작할 때마다 유효성 검사를 수행합니다.
- **`AutovalidateMode.onUserInteraction`**: 사용자가 입력을 시작한 후에만 유효성 검사를 수행합니다. 즉, 사용자가 필드에 포커스를 두고 입력을 시작하면 유효성 검사가 활성화됩니다.

## 예제 코드
아래는 `autovalidateMode`를 사용하는 간단한 Flutter 애플리케이션의 예제입니다.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('AutovalidateMode Example')),
        body: MyForm(),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction, // 유효성 검사 모드 설정
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력하세요';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return '유효한 이메일 주소가 아닙니다';
                }
                return null; // 유효한 경우 null 반환
              },
              onSaved: (value) {
                _email = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('이메일: $_email')),
                  );
                }
              },
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 코드 설명
1. **Form 위젯**: `GlobalKey<FormState>`를 사용하여 폼의 상태를 관리합니다.
2. **autovalidateMode**: `AutovalidateMode.onUserInteraction`으로 설정하여 사용자가 입력을 시작하면 유효성 검사가 자동으로 수행됩니다.
3. **TextFormField**: 이메일 입력 필드로, 유효성 검사 로직을 `validator` 속성에 정의합니다. 이메일 형식이 올바르지 않거나 비어 있을 경우 오류 메시지를 반환합니다.
4. **제출 버튼**: 버튼 클릭 시 폼의 유효성을 검사하고, 유효한 경우 입력된 이메일을 스낵바로 표시합니다.

이 예제를 통해 `autovalidateMode`의 사용법과 유효성 검사 자동화의 이점을 이해할 수 있습니다. 사용자가 입력하는 즉시 피드백을 제공하여 더 나은 사용자 경험을 제공합니다. 



