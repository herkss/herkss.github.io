---
title:  "skeletonizer" 
excerpt: "skeletonizer"

categories:
  - Package
tags:
  - [skeletonizer, skeletonizer, widget, package]

toc: true
toc_sticky: true
 
date: 2024-09-24
last_modified_at: 2024-09-24
comments: true
---


**Skeletonizer**는 Flutter에서 기존 위젯에 스켈레톤(Skeleton) 애니메이션을 적용하는 데 사용되는 패키지입니다. Skeletonizer의 핵심은 기존의 UI를 자동으로 스켈레톤 형태로 변환하여 로딩 상태를 시각적으로 표현하는 데 있습니다. 일반적으로 데이터 로딩이 필요한 상황에서, Skeletonizer를 활용해 복잡한 UI를 빠르게 스켈레톤화하여 사용자 경험을 개선할 수 있습니다.

### Skeletonizer의 주요 특징

1. **기존 위젯을 스켈레톤으로 감싸기**:
   Skeletonizer는 기존의 Flutter 위젯을 직접 감싸서 로딩 상태를 표현할 수 있도록 해줍니다. 즉, 이미 구현된 UI를 별도로 수정하지 않고도 간단하게 스켈레톤 효과를 추가할 수 있는 장점이 있습니다.

2. **자동화된 스켈레톤 생성**:
   Skeletonizer는 UI 요소의 기본 모양과 크기를 기반으로 자동으로 스켈레톤을 생성합니다. 버튼, 텍스트, 이미지 등 다양한 요소에 대해 자동으로 적절한 스켈레톤이 적용되기 때문에, UI 요소별로 일일이 스켈레톤을 설정하지 않아도 됩니다.

3. **Shimmer 애니메이션**:
   Skeletonizer는 로딩 상태에 흔히 사용되는 **Shimmer 애니메이션**을 지원하여, 사용자에게 데이터가 로딩 중임을 직관적으로 보여줍니다. Shimmer 효과는 스켈레톤이 단순히 고정된 상태가 아니라 빛이 흐르는 듯한 애니메이션을 적용해 로딩 중이라는 느낌을 강화합니다.

4. **유연한 커스터마이징**:
   Skeletonizer는 자동으로 스켈레톤을 생성하지만, 사용자는 필요에 따라 커스터마이징할 수 있습니다. 각 요소에 대해 세부적인 스켈레톤 스타일, 애니메이션 효과 등을 지정할 수 있으며, 특정 부분에만 스켈레톤을 적용하거나 생략하는 것이 가능합니다.

### Skeletonizer의 사용 예시

1. **기본 사용법**:
   Skeletonizer는 기본적으로 UI 요소를 감싸는 방식으로 사용됩니다. 기존 위젯을 `Skeletonizer`로 감싸기만 하면, 해당 위젯이 자동으로 스켈레톤 상태로 변환됩니다.

   ```dart
   Skeletonizer(
     isLoading: true, // 로딩 상태를 나타냄
     child: Column(
       children: [
         Text("Skeletonizer 적용 전 텍스트"),
         ElevatedButton(
           onPressed: () {},
           child: Text("Skeletonizer 적용 전 버튼"),
         ),
       ],
     ),
   );
   ```
   이 경우, `isLoading`이 `true`일 때 텍스트와 버튼이 자동으로 스켈레톤 형태로 변환되어 보여집니다.

2. **커스텀 스켈레톤**:
   스켈레톤의 스타일을 직접 설정할 수 있습니다. 이를 통해 텍스트, 버튼, 이미지 등 다양한 UI 요소에 맞춤형 스켈레톤을 적용할 수 있습니다.
   
   ```dart
   Skeletonizer(
     isLoading: true,
     skeleton: Skeleton(
       baseColor: Colors.grey[300]!, // 스켈레톤의 기본 색상
       highlightColor: Colors.grey[100]!, // 하이라이트 색상
     ),
     child: ListTile(
       leading: CircleAvatar(
         radius: 30,
         backgroundImage: NetworkImage('https://example.com/image.jpg'),
       ),
       title: Text("Title"),
       subtitle: Text("Subtitle"),
     ),
   );
   ```
   위 코드는 `ListTile` 위젯을 스켈레톤으로 변환하며, 스켈레톤의 색상과 스타일을 커스터마이징한 예시입니다.

3. **특정 위젯만 스켈레톤 적용**:
   Skeletonizer를 사용하면 전체 UI가 아니라 특정 위젯에만 스켈레톤 효과를 적용할 수 있습니다. 이를 통해 중요한 UI 요소만 로딩 중인 상태로 표현할 수 있습니다.

   ```dart
   Skeletonizer(
     isLoading: true,
     skeleton: Skeleton(
       baseColor: Colors.blueGrey[300]!,
       highlightColor: Colors.blueGrey[100]!,
     ),
     child: Text("로딩 중인 텍스트", style: TextStyle(fontSize: 24)),
   );
   ```

4. **Skeletonizer와 상태 관리**:
   보통 로딩 상태는 비동기 통신이나 상태 관리 로직과 함께 사용됩니다. 예를 들어, API 요청 중에 Skeletonizer를 사용하여 로딩 상태를 표현하고, 데이터가 도착하면 실제 데이터를 보여줍니다.

   ```dart
   FutureBuilder(
     future: fetchData(), // 데이터를 가져오는 함수
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return Skeletonizer(
           isLoading: true,
           child: Placeholder(), // 실제 위젯 대신 Placeholder 사용
         );
       } else {
         return Text("데이터가 로드되었습니다.");
       }
     },
   );
   ```

### Skeletonizer의 주요 기능

- **isLoading 플래그**: 로딩 상태를 제어하는 중요한 속성으로, `true`일 때 스켈레톤이 표시되고, `false`일 때는 원래 위젯이 표시됩니다.
- **skeleton 속성**: 스켈레톤의 스타일(색상, 애니메이션 등)을 정의할 수 있는 속성입니다. 이를 통해 UI에 맞는 스켈레톤을 쉽게 설정할 수 있습니다.
- **Shimmer 애니메이션**: 기본적으로 스켈레톤에 Shimmer 효과가 적용되어, 정적인 화면 대신 부드러운 애니메이션을 제공함으로써 더 나은 사용자 경험을 제공합니다.
  
### Skeletonizer의 장점

- **간편한 통합**: 기존 UI를 수정하지 않고도 쉽게 로딩 상태를 구현할 수 있습니다.
- **자동화된 스켈레톤 생성**: 별도의 스타일링 없이도 기본 스켈레톤이 자동으로 생성되므로, 간단한 코드로 로딩 상태를 처리할 수 있습니다.
- **높은 유연성**: 특정 위젯에만 적용하거나 스켈레톤의 스타일을 원하는 대로 커스터마이징할 수 있어 다양한 상황에 맞게 사용할 수 있습니다.
  
### Skeletonizer의 단점

- **복잡한 UI에서는 제한적일 수 있음**: 매우 복잡한 UI나 특수한 커스텀 위젯에서는 자동 생성된 스켈레톤이 원하는 대로 동작하지 않을 수 있어, 세부 조정이 필요할 수 있습니다.

### 결론
**Skeletonizer**는 Flutter 앱에서 기존 UI를 쉽게 로딩 상태로 변환할 수 있는 강력한 도구입니다. 로딩 중인 데이터를 시각적으로 표현하여 사용자 경험을 향상시키며, 자동화된 스켈레톤 생성과 커스터마이징 가능성 덕분에 다양한 UI에서 쉽게 적용할 수 있습니다.
