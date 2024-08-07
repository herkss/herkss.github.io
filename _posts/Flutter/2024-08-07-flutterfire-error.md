---
title:  "Flutterfire Error" 
excerpt: "Flutterfire error"

categories:
  - Flutter
tags:
  - [flutterfire, firebase, error,]

toc: true
toc_sticky: true
 
date: 2024-08-06
last_modified_at: 2024-08-06

---



lutterfire configure --project=~~

명령어를 입력할 때 flutterfire의 환경변수가 제대로 추가되어 있지 않으면 zsh(현재 shell) 가 제대로 찾지 못하기 때문이다.

이 명령어 전에 아래 명령어를 통해 cli를 설치했다면 

dart pub global activage flutterfire_cli
 

warning으로 친절히 해결법을 같이 알려줬을 것이다.

Warning: Pub installs executables into $HOME/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, etc.):

  export PATH="$PATH":"$HOME/.pub-cache/bin"
zhc를 사용한다면 위 경로를 .zshrc 를 열어 추가해준다.
```dart
vi ~/.zshrc
추가했다면 실행해주고

source ~/.zshrc
제대로 추가되었는지 확인해본다.
```
which flutterfire
경로를 알려주면 해결!

 

이후 다시 flutterfire configure를 해보자.

 flutterfire configure --project=~~
