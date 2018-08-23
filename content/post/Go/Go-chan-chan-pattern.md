---
title: "Go의 chan chan pattern"
description: "채널에 채널을 넘기는 Go의 chan chan pattern에 대해 알아봅니다."
date: 2018-08-23T21:40:48+09:00
categories: [
    "Go",
    "Development"
]
tags: [
    "Go",
    "golang",
    "Go언어",
    "프로그래밍"
]
keywords: [
    "Go",
    "golang",
    "Go언어",
    "프로그래밍",
    "goroutine",
    "channel",
    "chan chan",
    "concurrency",
    "queue"
]
---

## `chan chan T` Channel??
채널은 **Go**의 핵심 기능 중 하나로, Go루틴 간의 데이터 통신을 위해 사용되는 큐(Queue) 형태의 자료형입니다. `chan T` 형태를 가진 채널은 `T` 타입의 데이터를 주고 받을 수 있습니다. 그러다보니 간혹 쉽게 이해하기 힘든 형태를 가진 채널도 등장하게 됩니다. 바로 `chan chan T` 채널입니다.

사실 `chan chan T` 자체를 이해하는 것은 어렵지 않을 것입니다. `chan chan T`를 풀어서 보면 `chan T`를 넘기는 채널이라 볼 수 있고, 말 그대로 채널을 넘겨주는 채널일 뿐입니다. 하지만 글로만은 어떻게 사용해야할지 감이 쉽게 잡히지 않을 수 있으므로, 코드를 통해 살펴보도록 하겠습니다.

## 코드
일단 `chan chan T`를 사용한 간단한 코드를 통해 동작 흐름을 알아보도록 하겠습니다.

```go
package main

import (
    "fmt"
    "sync"
)

// reqCh를 통해 들어온 채널에 카운트 된 숫자를 보냅니다.
func Counter(reqCh <-chan chan int) {
	cnt := 0

	for resCh := range reqCh {
        // Do Stuff...
		resCh <- cnt // 결과를 resCh로 보냅니다.
		cnt++
	}
}

// reqCh에 처리에 대한 응답을 받을 resCh을 보내고 resCh에 들어온 값을 출력합니다.
func A(reqCh chan<- chan int) {
	resCh := make(chan int)
	defer close(resCh)

	reqCh <- resCh

	fmt.Println("A:", <-resCh)
}

// A와 동일합니다.
func B(reqCh chan<- chan int) {
	resCh := make(chan int)
	defer close(resCh)

	reqCh <- resCh

	fmt.Println("B:", <-resCh)
}

// A와 동일합니다.
func C(reqCh chan<- chan int) {
	resCh := make(chan int)
	defer close(resCh)

	reqCh <- resCh

	fmt.Println("C:", <-resCh)
}

func main() {
    // Counter와 A, B, C 사이의 요청을 위한 통로가 됩니다.
	pipe := make(chan chan int)

	go Counter(pipe)

	A(pipe)
	C(pipe)
	B(pipe)
	C(pipe)
    A(pipe)

    /*
    A: 0
    C: 1
    B: 2
    C: 3
    A: 4
    */
}
```

`chan chan T`의 이해를 돕기 위한 간단한 카운터 코드입니다. `Counter()`는`reqCh`을 통해 넘겨 받은 채널에 차례로 특정 작업을 한 후(위 코드에선 카운팅 된 숫자를 넘김) 결과를 넘겨줍니다. 각 `A()`, `B()`, `C()` 들은 `reqCh`을 통해 결과를 받을 `resCh`을 넘겨주고, `resCh`을 통해 받은 결과를 출력합니다.

위 코드를 응용하면 응답을 받을 채널과 값을 함께 넘길 수 있습니다.

```go
package main

import (
	"fmt"
)

type Data struct {
	a, b int
	resCh chan int
}

func (d Data) AddRequest(reqCh chan<- Data) {
	reqCh <- d
	fmt.Println("Result:", <-d.resCh)
}

func NewData(a, b int) *Data {
	return &Data {
		a: a,
		b: b,
		resCh: make(chan int),
	}
}

func Adder(reqCh <-chan Data) {
	for data := range reqCh {
		data.resCh <- data.a + data.b
	}
}


func main() {
	pipe := make(chan Data)

	go Adder(pipe)

	a := NewData(1, 2)
	b := NewData(100, 200)
	c := NewData(100, -200)

	a.AddRequest(pipe)
	b.AddRequest(pipe)
	c.AddRequest(pipe)
}
```

위에서 말씀드린대로 사실 `chan chan T`는 너무나도 단순합니다. 채널을 넘기는 채널이기에 위의 코드처럼 요청과 응답을 위해 사용되지 않더라도 다양하게 사용될 수 있습니다. 응용방법이 너무나 많아 모두 살펴볼 순 없겠지만, 이 글이 `chan chan T`를 이해하는데 있어 도움이 됐으면 좋겠네요. :smiley: