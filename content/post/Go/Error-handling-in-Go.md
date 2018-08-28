---
title: "Error handling in Go"
description: "Go에서 Error를 다루는 몇 가지 방법과 팁에 대해 알아봅니다."
date: 2018-08-28T11:31:10+09:00
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
draft: true
---

## *"Errors are values" <small><small>- Rob Pike</small></small>*
"Errors are values"는 **Go**의 개발자이신 Rob Pike님이 Go Proverbs를 발표하시면서 하신 말씀입니다. 그렇다면 **Go**에서의 Error가 도대체 뭐길래 값이란 걸까요? **Go**의 `error`는 다음과 같이 정의되어 있습니다.

```go
type error interface {
    Error() string
}
```

**Go**에서의 `interface`는 [덕 타이핑(Duck Typing)](https://ko.wikipedia.org/wiki/%EB%8D%95_%ED%83%80%EC%9D%B4%ED%95%91)으로 동작하기 때문에 `Error()` 메서드를 구현기만 하면 `error`로 쓰일 수 있고, 이로 인해 `error`는 자바와 같은 단순 예외가 아니라 하나의 값으로 쓰일 수 있습니다. 이 덕분에 **Go**에서는 다양한 방식으로 `error`를 처리할 수 있습니다.

이번 글에서는 **Go**에서 `error`를 처리하기 위한 몇 가지 방법과 팁을 공유해볼까 합니다.

## Error 만들기
물론 `error`를 만드는 방법은 너무나도 다양합니다. 심화된 내용에 앞서 **Go** 내부 패키지를 사용하여, 에러 메세지만을 가지고 간단한 `error`를 만들어보도록 하겠습니다.

```go
package main

import (
	"errors"
	"fmt"
)

func fError() error {
	return fmt.Errorf("fmt.Errorf error")
}

func nError() error {
	return errors.New("errors.New error")
}

func main() {
	err := nError()
	if err != nil {
		fmt.Println(err) // fmt.Errorf error
	}

	if err = fError(); err != nil {
		fmt.Println(err) // errors.New error
	}
}
```

위는 `fmt.Errorf()`와 `errors.New()` 같은 간단한 방법을 통해 만든 `error`를 사용한 코드입니다. 하지만 이와 같이 만든 `error`는 에러 메세지를 제외한 다른 어떠한 값도 같고 있지 않습니다. 에러 메세지만을 통해서도 에러에 대한 간략한 정보를 보여줄 수 있지만, 프로그램 내부에서 에러 메세지만을 가지고 에러를 다룬다는 것은 힘든 일입니다.

`error`를 보다 정교하게 다루기 위해선 에러가 발생 된 이유, 환경 등에 대한 값을 알아야 합니다. 그럼 값을 내장하고 있는 `error`를 만들어 보도록 하겠습니다.

```go
package main

import (
	"fmt"
)

type CalcError struct {
	Num1, Num2 int
	Message    string
}

type AddError struct {
	CalcError
}

func (a *AddError) Error()  string {
	return fmt.Sprintf("Add(%v, %v): %v", a.Num1, a.Num2, a.Message)
}

type DivisionError struct {
	CalcError
}

func (d *DivisionError) Error() string {
	return fmt.Sprintf("Division(%v, %v): %v", d.Num1, d.Num2, d.Message)
}

func Add(a, b int) (int, error) {
	if a == 4 || b == 4 {
		return 0, &AddError{
			CalcError: CalcError{
				Num1:    a,
				Num2:    b,
				Message: "I don't link 4",
			},
		}
	}

	return a + b, nil
}

func Division(a, b int) (int, error) {
	if b == 0 {
		return 0, &DivisionError{
			CalcError: CalcError{
				Num1:    a,
				Num2:    b,
				Message: "Division by zero",
			},
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
	err := Calc(100, 10)
	if err != nil {
		switch err.(type) {
		case *DivisionError:
			fmt.Printf("division error detected: %v\n", err)
		case *AddError:
			fmt.Printf("add error detected: %v\n", err)
		default:
			fmt.Printf("unknown error detected: %v\n", err)
		}
	}
}
```