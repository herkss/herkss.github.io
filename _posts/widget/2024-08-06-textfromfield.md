---
title:  "TextFormField" 
excerpt: "TextFormField-텍스트폼필드"

categories:
  - Widget
tags:
  - [TextFormField, 플러터, 텍스트폼필드, ]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06
comments: true
---



`TextFormField`는 Flutter에서 사용자 입력을 처리하기 위해 사용하는 위젯입니다. `TextFormField`는 `TextField`의 확장으로, 폼의 일부로 사용되며 `Form` 위젯과 함께 사용할 때 유용합니다. `TextFormField`는 데이터 유효성 검사, 입력 형식 지정, 사용자 입력에 대한 피드백 제공 등의 기능을 지원합니다.

### 주요 속성

- **`controller`**: 입력 값을 제어하고 읽기 위해 사용됩니다. `TextEditingController` 인스턴스를 제공하여 사용자가 입력한 값을 추적할 수 있습니다.

- **`decoration`**: 입력 필드의 장식을 정의합니다. `InputDecoration` 클래스를 사용하여 필드의 레이블, 힌트, 아이콘 등을 설정할 수 있습니다.

- **`keyboardType`**: 사용자가 입력할 수 있는 키보드의 종류를 지정합니다. 예를 들어, 이메일 입력에는 `TextInputType.emailAddress`, 숫자 입력에는 `TextInputType.number`를 사용할 수 있습니다.

- **`obscureText`**: 비밀번호 입력 필드와 같이 입력된 텍스트를 숨기기 위해 사용합니다. `true`로 설정하면 입력된 문자가 별표(*)로 표시됩니다.

- **`validator`**: 입력 값의 유효성을 검사하는 함수입니다. 이 함수는 `String?` 값을 받아서 유효하지 않은 경우 오류 메시지를 반환합니다. 폼 제출 시 유효성 검사를 자동으로 호출합니다.

- **`onChanged`**: 사용자가 입력 필드의 값을 변경할 때 호출되는 콜백 함수입니다. 실시간으로 입력 값을 처리할 때 유용합니다.

- **`onSaved`**: 폼이 저장될 때 호출되는 콜백 함수입니다. 주로 폼 제출 시 입력 값을 저장하는 데 사용됩니다.

- **`autovalidateMode`**: 유효성 검사가 언제 수행될지를 정의합니다. `AutovalidateMode.onUserInteraction`을 설정하면 사용자가 입력 필드와 상호작용할 때 유효성 검사가 자동으로 수행됩니다.

### 예제

아래 예제는 `TextFormField`를 사용하여 이메일과 비밀번호를 입력받고 유효성 검사를 수행하는 간단한 Flutter 폼을 보여줍니다.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TextFormField Example',
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TextFormField Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // If the form is valid, display a snackbar.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: Text('Submit'),
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

- **`TextEditingController`**: `_emailController`와 `_passwordController`를 사용하여 각각 이메일과 비밀번호의 값을 제어합니다.
- **`InputDecoration`**: `labelText`, `hintText`, 및 `border`를 사용하여 입력 필드의 시각적 요소를 설정합니다.
- **`keyboardType`**: 이메일 입력에 적합한 키보드를 제공합니다.
- **`validator`**: 각 필드에 대해 유효성 검사를 수행하고, 오류 메시지를 반환합니다.
- **`obscureText`**: 비밀번호 필드에서 입력된 텍스트를 숨깁니다.

`TextFormField`를 통해 Flutter에서 사용자 입력을 효율적으로 처리하고 유효성 검사를 수행할 수 있습니다.
