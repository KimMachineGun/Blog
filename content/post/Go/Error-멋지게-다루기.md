---
title: "Error 멋지게 다루기(1)"
description: "Go에서 Error를 다루는 몇 가지 방법과 팁에 대해 알아봅니다."
date: 2018-08-29T11:31:10+09:00
categories: [
    "Go",
    "Development"
]
tags: [
    "Go",
    "golang",
    "Go언어",
	"프로그래밍",
	"Error 멋지게 다루기"
]
keywords: [
    "Go",
    "golang",
    "Go언어",
	"프로그래밍",
	"Go언어 error",
	"error handling",
	"interface",
	"golang error",
    "error 핸들링",
    "type error interface",
    "golang interface",
    "덕타이핑",
    "assertion"
]
---

## *"Errors are values" <small><small>- Rob Pike</small></small>*
"Errors are values"는 **Go**의 개발자이신 Rob Pike님이 Go Proverbs를 발표하시면서 하신 말씀입니다. 그렇다면 **Go**에서의 Error가 도대체 뭐길래 값이란 걸까요? **Go**의 `error`는 다음과 같이 정의되어 있습니다.

```go
type error interface {
    Error() string
}
```

**Go**에서의 `interface`는 [덕 타이핑(Duck Typing)](https://ko.wikipedia.org/wiki/%EB%8D%95_%ED%83%80%EC%9D%B4%ED%95%91)으로 동작하기 때문에 `Error()` 메서드를 구현기만 하면 `error`로 쓰일 수 있고, 이로 인해 `error`는 자바와 같은 단순 예외가 아니라 하나의 값으로 쓰일 수 있습니다. 이 덕분에 **Go**에서는 다양한 방식으로 `error`를 처리할 수 있습니다.

[Error 멋지게 다루기 시리즈](/tags/error-멋지게-다루기/)를 통해 **Go**에서 `error`를 처리하기 위한 몇 가지 방법과 팁을 공유해볼까 합니다.

## 값을 내장한 Error
**Go**에서 `error`를 만드는 방법은 너무나도 다양합니다. 값을 내장한 `error`를 살펴보기 전에 에러 메세지만을 갖는 간단한 `error`를 먼저 살펴보도록 하겠습니다.

```go
package main

import (
	"fmt"
	"errors"
)

var AddError = errors.New("I don't like 4")
var DivisionError = errors.New("Division by zero")

func Add(a, b int) (int, error) {
	if a == 4 || b == 4 {
		return 0, AddError
	}

	return a + b, nil
}

func Division(a, b int) (int, error) {
	if b == 0 {
		return 0, DivisionError
	}

	return a / b, nil
}

func Calc(a, b int) error {
	val, err := Add(a, b)
	if err != nil {
		return err
	}

	fmt.Println("Add:", val)

	val, err = Division(a, b)
	if err != nil {
		return err
	}

	fmt.Println("Division:", val)

	return nil
}

func main() {
	err := Calc(100, 0)
	if err != nil {
		switch err {
		case AddError:
			fmt.Printf("add error detected: %v\n", err)
		case DivisionError:
			fmt.Printf("division error detected: %v\n", err)
		default:
			fmt.Printf("unknown error detected: %v\n", err)
		}
	}
}

// Add: 100
// division error detected: Division by zero
```

위는 `errors.New()`를 통해 `error`를 만드는 코드입니다. `fmt.Errorf()`를 이용하여 특정 형식의 에러 메세지를 갖는 `error` 또한 만들 수 있습니다. 이러한 `error`는 값 비교를 통해 어떤 `error`인지 알 수 있고, 에러 메세지를 통해 `error`에 대한 간단한 정보를 확인할 수 있습니다. 

하지만, 이와 같은 `error`는 에러 메세지를 제외한 다른 어떠한 값도 갖고 있지 않아 복잡한 `error`의 경우 효과적으로 다루기 힘듭니다.

복잡한 `error`를 보다 효과적으로 다루기 위해선 `error`가 발생 이유, 환경 등에 대한 정보가 필요합니다. 그럼 코드를 통해 값을 내장한 `error`에 대해 살펴보도록 하겠습니다.

```go
package main

import (
	"fmt"
)

type calcError struct {
	Num1, Num2 int
	Message    string
}

type AddError calcError

func (a *AddError) Error()  string {
	return fmt.Sprintf("Add(%v, %v): %v", a.Num1, a.Num2, a.Message)
}

type DivisionError calcError

func (d *DivisionError) Error() string {
	return fmt.Sprintf("Division(%v, %v): %v", d.Num1, d.Num2, d.Message)
}

func Add(a, b int) (int, error) {
	if a == 4 || b == 4 {
		return 0, &AddError{
			Num1:    a,
			Num2:    b,
			Message: "I don't like 4",
		}
	}

	return a + b, nil
}

func Division(a, b int) (int, error) {
	if b == 0 {
		return 0, &DivisionError{
			Num1:    a,
			Num2:    b,
			Message: "Division by zero",
		}
	}

	return a / b, nil
}

func Calc(a, b int) error {
	val, err := Add(a, b)
	if err != nil {
		return err
	}

	fmt.Println("Add:", val)

	val, err = Division(a, b)
	if err != nil {
		return err
	}

	fmt.Println("Division:", val)

	return nil
}

func main() {
	err := Calc(100, 0)
	if err != nil {
		switch err := err.(type) {
		case *AddError:
			fmt.Printf("a: %v\t b: %v\t message: %v\n", err.Num1, err.Num2, err.Message)
			fmt.Printf("add error detected: %v\n", err)
		case *DivisionError:
			fmt.Printf("a: %v\t b: %v\t message: %v\n", err.Num1, err.Num2, err.Message)
			fmt.Printf("division error detected: %v\n", err)
		default:
			fmt.Printf("unknown error detected: %v\n", err)
		}
	}
}

// Add: 100
// a: 100	 b: 0	 message: Division by zero
// division error detected: Division(100, 0): Division by zero
```

위 코드는 `Error()` 메서드를 구현한 타입을 `error`로 사용한 코드입니다. 위와 같은 `error`는 `type assertion`을 통해 어떤 `error`인지 확인하고, `error` 내부의 값에 접근하여 복잡한 `error`를 보다 효과적으로 다룰 수 있습니다.

## 마치며
이번 글에서는 `typed error`를 통해 `error`에 값을 추가하여, 복잡한 `error`를 보다 효과적으로 다루는 방법에 대해 살펴보았습니다. 물론 `typed error`만이 복잡한 `error`를 효과적을 다루기 위한 정답은 아닙니다. 상황에 맞게 적절한 방법을 선택하여 사용하는 것이 가장 멋지게 `error`를 다루는 방법이 아닐까 싶네요. :smiley:

## 다음 글
**Go**에서는 보통 함수의 마지막 인자로 `error`를 리턴하여 `error`를 다루곤 합니다. 하지만 별도의 처리 없이 이와 같은 방법으로 `error`를 다루다 보면 어떤 함수에서, 왜 발생하였는지 `error`가 내장한 정보만으로 디버깅하기 힘들어질 때가 있습니다. 이와 같은 문제를 해결하기 위한 방법을 다음 글에서 살펴보도록 하겠습니다.