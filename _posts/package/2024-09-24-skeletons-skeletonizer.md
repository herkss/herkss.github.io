---
title:  "skeletons와 skeletonizer차이" 
excerpt: "skeletons와 skeletonizer차이"

categories:
  - Package
tags:
  - [skeletons, skeletonizer, widget, package]

toc: true
toc_sticky: true
 
date: 2024-09-24
last_modified_at: 2024-09-24
comments: true
---

플러터(Flutter)에서 **Skeletons**와 **Skeletonizer**는 비슷한 목적을 위해 사용되지만, 각각의 목적과 사용 방법이 다릅니다. 두 용어 모두 **로딩 상태**를 나타내는 UI를 처리하는 데 사용되지만, 차이점은 다음과 같습니다.

### 1. **Skeletons**
- **Skeletons 패키지**는 특정 UI 요소들이 데이터를 로드하는 동안, 기본적인 틀(즉, skeleton)을 보여주는 역할을 합니다. 로딩 중에 콘텐츠가 표시되지 않는 대신, 사용자에게 데이터가 로드되고 있다는 시각적 힌트를 제공합니다.
- 이 패키지는 일반적으로 **사전 정의된 스켈레톤 애니메이션**을 제공하여, 특정 위젯이나 화면에 쉽게 적용할 수 있습니다.
- 예시:
  ```dart
  SkeletonAvatar(
    style: SkeletonAvatarStyle(
      shape: BoxShape.circle,
    ),
  );
  ```

### 2. **Skeletonizer**
- **Skeletonizer**는 기존의 Flutter 위젯을 감싸서 스켈레톤 효과를 추가하는 데 사용됩니다.
- 기존 위젯에 **skeletonize**라는 기능을 적용하여, 쉽게 스켈레톤을 생성할 수 있게 하는 방식입니다. 즉, 특정 위젯에 대해 스켈레톤을 자동으로 생성해주는 **wrapper** 역할을 합니다.
- 이 패키지는 **커스텀 위젯**에 유연하게 스켈레톤 효과를 적용할 수 있도록 도와줍니다.
- 예시:
  ```dart
  Skeletonizer(
    child: YourWidget(),
  );
  ```

### 차이점 요약
- **Skeletons**: 사전 정의된 스켈레톤 스타일과 애니메이션을 제공하며, 쉽게 적용할 수 있는 UI 요소들을 포함.
- **Skeletonizer**: 기존의 위젯을 감싸서 자동으로 스켈레톤 효과를 부여할 수 있으며, 더 유연한 사용이 가능.

이 두 패키지는 로딩 상태를 더 효과적으로 관리하기 위한 도구로, 사용자의 요구에 따라 적절하게 선택할 수 있습니다.
