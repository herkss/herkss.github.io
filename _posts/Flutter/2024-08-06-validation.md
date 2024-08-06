
---
title:  "Validation 유효성검사" 
excerpt: "유효성검사 Validation

categories:
  - Flutter
tags:
  - [validation, validator, flutter, widget,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06

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
