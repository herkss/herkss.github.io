---
title:  "Dismissible 사용법(스와이프)" 
excerpt: "스와이프적용"

categories:
  - Flutter
tags:
  - [스와이프, Git, Github, ]

toc: true
toc_sticky: true
 
date: 2024-07-23
last_modified_at: 2024-07-23
comments: true
---


### Dismissible Widget?
List에서 특정 아이템을 좌,우로 움직였을 때, 특정 action을 취하고 아이템이 사라지도록하는 widget



### Properties and Methods

- background
child 아래에 있어서 child widget을 드래그해야 보이는 widget
secondaryBackground도 지정되어 있으면 background widget은 child를 아래 혹은 우로 드래그할 때 보인다.

- secondaryBackground
child 아래에 있어서 child widget을 드래그해야 보이는 widget
background widget이 존재해야만 의미가 있고 child를 위 혹은 좌로 드래그할 때 보인다.

- direction
드래그 했을 때 child widget이 사라지는 방향
default는 DismissDirection.horizontal

- onDismissed
child가 화면에서 사라지고 난 후에 호출

- confirmDismiss
dismiss가 동작하기 전에 유저에게 확인할 기회를 준다.



### 먼저 list generate function을 이용해서 30개의 list 아이템을 생성합니다.

```dart
final List<String> _items = List.generate(30, (index) => 'Item ${index + 1}');
ListView.builder()
listView.builder를 이용해서 위에서 만든 item list를 렌더링합니다.

ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(8),
          elevation: 8,
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${_items[index].split(' ')[1]}'),
            ),
            title: Text(
              _items[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );

```


### Dismissible
이제 Dismissble 기능을 사용하기 위해서 Card 부분에 Dismissible을 적용해줍니다.
Dismissible에서 꼭 필요한 것은 key와 child입니다.

```dart
Dismissible(
          key: Key(_items[index]),
          child: Card(
            margin: const EdgeInsets.all(8),
            elevation: 8,
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${_items[index].split(' ')[1]}'),
              ),
              title: Text(
                _items[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        )

```
### Background and SecondaryBackground
좌측으로 드래하냐 우측으로 드래그하냐에 따라 다른 화면을 보여주기 위해서 background와 secondaryBackground를 적용해보겠습니다.

```dart
Dismissible(
          key: Key(_items[index]),
          background: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.green,
            alignment: Alignment.centerLeft,
            child: const Icon(
              Icons.save,
              size: 36,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete,
              size: 36,
              color: Colors.white,
            ),
          ),
          child: Card(
            margin: const EdgeInsets.all(8),
            elevation: 8,
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${_items[index].split(' ')[1]}'),
              ),
              title: Text(
                _items[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        )

```

### onDismissed
onDismissed를 이용해서 드래그 이후의 동작을 구현합니다.


```dart
ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_items[index]),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              setState(() {
                _items.removeAt(index);
              });
            }
            if (direction == DismissDirection.startToEnd) {
              setState(() {
                _savedItems.add(_items[index]);
                _items.removeAt(index);
              });
            }
          },
          background: _buildBackgroundWidget,
          secondaryBackground: _buildSecondBackgroundWidget,
          child: _buildListItem(index),
        ),
      )
```
### confirmDismiss
confirmDismiss를 이용해서 드래그를 할때 최종 확인이 가능하도록 구현합니다.

```dart
ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_items[index]),
          onDismissed: (direction) => _onDismissed(direction, index),
          confirmDismiss: (direction) {
            if (direction == DismissDirection.endToStart) {
              return showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: Text('Now I am deleting ${_items[index]}'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            return Navigator.of(context).pop(false);
                          },
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            return Navigator.of(context).pop(true);
                          },
                          child: const Text('DELETE'),
                        ),
                      ],
                    );
                  });
            } else if (direction == DismissDirection.startToEnd) {
              return showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: Text('Now saving ${_items[index]}'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            return Navigator.of(context).pop(false);
                          },
                          child: const Text('CANCEL'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            return Navigator.of(context).pop(true);
                          },
                          child: const Text('SAVE'),
                        ),
                      ],
                    );
                  });
            }
            return Future.value(false);
          },
          background: _buildBackgroundWidget,
          secondaryBackground: _buildSecondBackgroundWidget,
          child: _buildListItem(index),
        ),
      )


```



출처 https://velog.io/@kjha2142/Flutter-Dismissible-Widget
