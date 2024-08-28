---
title:  "MvvM" 
excerpt: "MVVM model"

categories:
  - Flutter
tags:
  - [mvvm, mvvm_model flutter, widget,]

toc: true
toc_sticky: true
 
date: 2024-08-07
last_modified_at: 2024-08-07
comments: true
---
플러터에서 MVVM(Model-View-ViewModel) 모델은 애플리케이션 구조를 관리하는 데 유용한 패턴입니다. MVVM은 UI와 비즈니스 로직을 분리하여 코드의 유지보수성과 테스트 용이성을 높입니다. 각 구성 요소의 역할은 다음과 같습니다.

### 1. Model
- **정의**: 애플리케이션의 데이터와 비즈니스 로직을 포함합니다.
- **역할**: API 호출, 데이터베이스 접근, 상태 관리 등을 처리합니다. 데이터 구조를 정의하고, 데이터를 가져오고 저장하는 기능을 제공합니다.

### 2. View
- **정의**: 사용자 인터페이스(UI)를 구성하는 요소입니다.
- **역할**: 사용자에게 정보를 표시하고, 사용자의 입력을 받습니다. Flutter에서는 Widget으로 구현됩니다. View는 ViewModel에서 제공하는 데이터를 바인딩하여 화면에 표시합니다.

### 3. ViewModel
- **정의**: View와 Model 간의 중재자 역할을 합니다.
- **역할**: Model의 데이터를 가져와서 View에 전달하고, View에서 발생하는 사용자 이벤트를 처리하여 Model에 전달합니다. 비즈니스 로직을 포함하고 있으며, 데이터 변화를 관찰할 수 있도록 변수를 구성합니다.

### MVVM의 흐름
1. **데이터 바인딩**: View는 ViewModel의 데이터를 구독하고, ViewModel의 상태가 변경되면 자동으로 UI를 업데이트합니다.
2. **사용자 입력 처리**: 사용자가 UI와 상호작용하면 View는 ViewModel에 이벤트를 전달합니다.
3. **데이터 업데이트**: ViewModel은 Model에 변경 사항을 반영하고, Model의 데이터가 변경되면 ViewModel이 다시 View를 업데이트합니다.

### Flutter에서의 MVVM 구현
- **Provider**: 상태 관리를 위해 `Provider` 패키지를 사용하여 ViewModel을 관리할 수 있습니다.
- **ChangeNotifier**: ViewModel은 `ChangeNotifier`를 상속받아 데이터 변경 시 `notifyListeners()`를 호출하여 UI를 갱신할 수 있습니다.
- **Consumer**: View에서는 `Consumer` 위젯을 사용하여 ViewModel의 변경 사항을 구독하고, 필요한 데이터를 표시합니다.

### 예제 코드
```dart
class UserModel {
  String name;
  UserModel(this.name);
}

class UserViewModel extends ChangeNotifier {
  UserModel _user = UserModel('이름 없음');

  String get userName => _user.name;

  void updateUserName(String name) {
    _user.name = name;
    notifyListeners(); // UI 갱신
  }
}

// View
class UserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Text(viewModel.userName),
            ElevatedButton(
              onPressed: () {
                viewModel.updateUserName('새 이름');
              },
              child: Text('이름 변경'),
            ),
          ],
        );
      },
    );
  }
}
```

이러한 방식으로 MVVM 패턴을 사용하면 코드의 가독성과 유지보수성을 높일 수 있습니다. 추가적인 질문이나 구체적인 부분에 대해 더 알고 싶으신가요? 


## 예제

GetX에서 MVVM 패턴을 사용하는 예제를 소개하겠습니다.

### 1. 모델 (Model)

먼저, 모델 클래스를 정의합니다. 예를 들어, 사용자 정보를 저장하는 간단한 모델을 만들어 보겠습니다.

```dart
class User {
  String name;
  int age;

  User({required this.name, required this.age});
}
```

### 2. 뷰모델 (ViewModel)

다음으로, 뷰모델을 정의합니다. GetX의 `GetxController`를 상속받아 상태를 관리합니다.

```dart
import 'package:get/get.dart';

class UserController extends GetxController {
  var user = User(name: '', age: 0).obs;

  void updateUser(String name, int age) {
    user.update((val) {
      val?.name = name;
      val?.age = age;
    });
  }
}
```

### 3. 뷰 (View)

이제 뷰를 만듭니다. GetX의 `Obx` 위젯을 사용하여 상태 변화를 감지하고 UI를 업데이트합니다.

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserView extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MVVM with GetX')),
      body: Column(
        children: [
          Obx(() => Text('Name: ${userController.user.value.name}')),
          Obx(() => Text('Age: ${userController.user.value.age}')),
          TextField(
            onChanged: (value) {
              userController.updateUser(value, userController.user.value.age);
            },
            decoration: InputDecoration(labelText: 'Enter Name'),
          ),
          TextField(
            onChanged: (value) {
              userController.updateUser(userController.user.value.name, int.parse(value));
            },
            decoration: InputDecoration(labelText: 'Enter Age'),
          ),
        ],
      ),
    );
  }
}
```

### 4. 메인 (Main)

마지막으로, 메인 함수를 정의하여 앱을 실행합니다.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: UserView()));
}
```

### 설명

- **모델**: 사용자 정보를 저장하는 간단한 클래스입니다.
- **뷰모델**: `UserController`에서 모델의 데이터를 관리하고, 업데이트하는 메서드를 제공합니다.
- **뷰**: `UserView`에서 사용자의 입력을 받고, 상태 변화를 감지하여 UI를 업데이트합니다.

이렇게 GetX에서 MVVM 패턴을 적용하여 상태 관리를 효율적으로 할 수 있습니다. 추가적인 질문이 있으면 말씀해 주세요! 

