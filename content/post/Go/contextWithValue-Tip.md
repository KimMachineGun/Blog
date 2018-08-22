---
title: "context.WithValue() 안전하게 사용하기"
description: "context.WithValue()를 보다 안전하게 사용할 수 있는 방법에 대해 알아봅니다."
date: 2018-08-21T21:16:58+09:00
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
    "context",
    "WithValue()",
    "interface{}"
]
---

## Context란?
`Go 1.7`에서 빌트인 패키지에 포함된 `context` 패키지는 중첩된 구조의 API에서 문맥을 공유하기 위해 사용됩니다. `context` 패키지는 `context.WithCancel()`이나 `context.WithTimeout()`을 통해 API 종료를 처리하기도 하고, `context.WithValue()`를 값을 공유하기도 합니다. 오늘은 `context.WithValue()`를 통해 값을 보다 안전하게 공유할 수 있는 팁을 알아보도록 하겠습니다. `context` 패키지에 대해 아직 이해가 잘 되지 않으신다면 [Go Concurrency Patterns: Context](https://blog.golang.org/context)를 먼저 보고 오시는 것을 추천드립니다.

## 문제

```go
package main

import (
	"context"
	"fmt"
)

func main() {
	ctx := context.Background() // 새로운 context를 생성합니다.

	ctx = context.WithValue(ctx, "key", "value") // 첫 번째 인자로 받은 ctx룰 부모로하고 key에 따른 value를 얻을 수 있는 context를 반환합니다.

	fmt.Println(ctx.Value("key")) // value

	ctx = context.WithValue(ctx, "key", "what the...") // 값이 덮어 씌워집니다.

	fmt.Println(ctx.Value("key")) // what the...    : 예상치 못한 결과가 나옵니다.
}
```

위 코드는 `context.WithValue()`를 통해 값을 저장하고, `Context.Value()` 메서드를 통해 값을 읽어오는 아주 간단한 예제입니다. `context.WithValue()`의 두 번째, 세 번째 인자 모두 `interface{}` 타입이지만 보통의 경우 key에 string 타입을 많이 사용합니다. 그러다보면 key가 중복되는 일이 생길 수 있고, 기존 값이 덮어 씌워지며 큰 문제를 불러 일으키기도 합니다.  

위 코드와 같이 간단한 구조라면 key가 중복되는 일이 거의 생기지 않고, 만약 생긴다 하더라도 문제를 어렵지 않게 찾을 수 있지만, 중첩된 구조에서 다양한 함수를 넘나들며 많이 사용되는 `context`의 특성상 디버깅이 쉽지 않을 때도 있습니다. 그렇다면 이 문제를 어떻게 해결할 수 있을까요?

## 해결법
외부 패키지에서의 key와 중복되지 않도록 하기위한 몇 가지 방법에 대해 알아보도록 하겠습니다. 첫 번째 방법은 key에 특정 값을 추가하는 함수를 만들어 사용하는 것입니다.

```go
package main

import (
	"context"
	"fmt"
)

func createContextKey(key string) string { // 함수를 소문자로 시작하여 패키지 내부에서만 사용할 수 있도록 합니다.
	return "specific value" + key // key에 특정 문자열을 더해 key의 중복을 막습니다.
}

func main() {
	ctx := context.Background() // 새로운 context를 생성합니다.

	ctx = context.WithValue(ctx, createContextKey("key"), "value") // createkey()를 사용해 key를 만들어 사용합니다.

	fmt.Println(ctx.Value("key")) // <nil>
	fmt.Println(ctx.Value(createContextKey("key"))) // value
}
```

위와 같이 key 값에 특정 문자열을 붙이는 함수를 만들어 다른 패키지에서 추가한 key와의 중복을 방지할 수 있습니다. 

```go
package main

import (
	"context"
	"fmt"
)

type contextKey string // 새로운 타입을 정의합니다.

func main() {
	ctx := context.Background()

	ctx = context.WithValue(ctx, contextKey("key"), "value") // string 타입을 contextKey 타입으로 캐스팅하여 key로 사용합니다.

	fmt.Println(ctx.Value("key")) // <nil>
	fmt.Println(ctx.Value(contextKey("key"))) // value
}
```

또 다른 방법으로 함수를 사용하지 않고, 새로운 타입을 정의하여 key의 중복을 피할 수 있습니다.

```go
package main

import (
	"context"
	"fmt"
)

type contextKey struct{}

func main() {
	ctx := context.Background()

	ctx = context.WithValue(ctx, contextKey{}, "value") // contextKey{}를 key로 사용합니다.

	fmt.Println(ctx.Value(contextKey{})) // value
}
```

만약 패키지 단에서 단 하나의 key만을 필요로 한다면, 위와 같이 `struct{}` 타입을 사용하여 key의 중복을 미연에 방지할 수 있습니다.