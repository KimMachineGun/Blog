---
title: "Error 멋지게 다루기2"
description: "Go에서 Error를 다루는 몇 가지 방법과 팁에 대해 알아봅니다."
date: 2018-09-03T22:36:58+09:00
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

## 중첩된 함수 구조
[전편](/2018-08-29/error-멋지게-다루기1/)에서 말씀드린 것 처럼 중첩된 함수 구조를 통과하는 `error`를 다루다 보면 `error`가 내장한 값 만으로는 디버깅이 힘들어지기도 합니다. 

[Error 멋지게 다루기 시리즈](/tags/error-멋지게-다루기/)의 두 번째 편인 이번 편에서는 이러한 중첩된 함수 구조에서 `error` 처리를 편하게 할 수 있는 몇가지 방법에 대해 알아보도록 하겠습니다.

## 문제
**Go**에서는 보통 함수의 마지막 반환 값으로 `error`를 넘겨 `error`를 다룹니다. 하지만 중첩 된 구조에서 반복되는 `error`의 반환은 디버깅을 힘들게 만듭니다.

코드를 보고 문제에 대해 더 자세히 알아보도록 하겠습니다.

```go
package main

import "errors"

func A() error {
	// do stuff

	if err := B(); err != nil {
		return err
	}

	return nil
}

func B() error {
	// do stuff

	if err := C(); err != nil {
		return err
	}

	return nil
}

func C() error {
	// do stuff

	if err := Occur(); err != nil {
		return err
	}

	return nil
}

func Occur() error {
	return errors.New("error detected!!!")
}

func main() {
	if err := A(); err != nil {
		panic(err)
	}
}
```

위 코드는 추가적인 처리 없이 단순히 `error`가 발생하면 해당 `error`를 반환하는 충첩된 함수 구조를 간략하게 나타낸 코드입니다. 물론 이 코드는 매우 극단적인 예시지만, 중첩된 함수 구조에서의 `error` 처리가 디버깅하기 힘들다는 사실은 변하지 않습니다.

그럼 실행 결과를 살펴보도록 하겠습니다.

![실행 결과](/post/Go/Error-멋지게-다루기2/실행결과.JPG)

위와 같이 단순한 코드에서는 굳이 결과를 보지 않고도 `Occur()`에서 `error`가 발생했구나! 하고 알아차릴 수 있지만 코드가 복잡해지는 경우 위와 같은 에러메세지는 그닥 도움이 되지 않을 것입니다.

`error`가 값을 내장하고 있다면 `error`가 발생한 이유나 환경에 대한 정보를 확인할 순 있겠지만, 이마저도 복잡한 코드에서는 어떤 함수에서 `error`가 발생하였고, 어떤 함수를 통해 전달되어 왔는지 확인하는 데에는 큰 도움이 되지 않습니다. 

## 에러 메세지 래핑
위와 같은 문제를 해결하기 위해 할 수 있는 가장 간단한 방법을 먼저 살펴보겠습니다. 

```go
if err := Occur(); err != nil {
    return fmt.Errorf("execute Ocuur() failed: %v", err)
}

// execute Ocuur() failed: error detected!!!
```

`error`를 그저 반환하지 않고, `error`가 일어난 과정에 대한 정보를 에러 메세지에 추가하는 것입니다. 이와 같은 간단한 에러 메세지 래핑은 `fmt.Errorf()`를 사용할 수 있습니다. 이로써 `error`가 전달된 과정에 대한 추가적인 정보를 확인하여 더욱 편리한 디버깅이 가능합니다.

하지만, 이 방법에도 문제가 있습니다. `fmt.Errorf()`를 사용하면 `Error()` 메서드를 통해 기존 `error`의 에러 메세지만을 얻어올 수 있고, 값에 접근할 수 없게 됩니다. 때문에 값을 내장한 `error`라 하더라도 그를 활용할 수 없게 됩니다.

## 에러 래핑
위에서 에러 메세지를 래핑하였다면, 이번에는 메세지가 아닌 `error` 자체를 래핑하여 보도록 하겠습니다. 아래는 `error` 래핑을 위한 간단한 코드입니다.

```go
type WrappedError struct {
	cause error
	message string
}

func (w *WrappedError) Error() string {
	return fmt.Sprintf("%v: %v", w.message, w.cause)
}

func (w *WrappedError) Cause() error {
	return w.cause
}

func Wrapping(err error, message string) error {
	return &WrappedError{
		cause: err,
		message: message,
	}
}
```

사실 위 코드는 무척 단순합니다. `Wrapping()` 함수를 통해 래핑 된 에러를 만들고, 래핑되기 전 `error`를 `WrappedError.Cause()` 메서드를 통해 접근할 수 있도록 한 것입니다.

아래는 위 함수를 사용하여 `error`를 래핑한 코드입니다.

```go
type TypedError struct {
	Code int
}

func (t *TypedError) Error() string {
	return fmt.Sprintf("typed error: %v", t.Code)
}

func Occur() error {
	return &TypedError{
		Code: 404,
	}
}

func Example() error {
	if err := Occur(); err != nil {
		return Wrapping(err, "execute Occur() failed")
	}

	return nil
}

func main() {
	if err := Example(); err != nil {
		if wrapped, ok := err.(*WrappedError); ok {
			switch cause := wrapped.Cause().(type) {
			case *TypedError:
				log.Printf("err code: %v", cause.Code)
			default:
				panic(cause)
			}
		} else {
			panic(err)
		}
	}
}

// 2018/09/04 01:21:28 err code: 404
```

이제 `error`를 래핑하여 에러 메세지에 정보를 추가하고, 기존 `error`에도 접근이 가능합니다. 이를 통해 중첩된 함수 구조에서 여러 함수를 통과하는 `error`를 더욱 쉽게 디버깅할 수 있습니다.

## 바퀴의 재발명
사실, `error`를 래핑하는데 더 강력한 기능을 가진 [pkg/errors](https://github.com/pkg/errors) 라이브러리가 이미 있습니다. 이 라이브러리를 사용하면 에러 메세지뿐만 아니라 StackTrace와 함께 `error`를 래핑 가능하여 더 쉽게 `error`를 다룰 수 있습니다.

 물론, 직접 `error` 래핑 코드를 작성해 사용하는 것도 나쁘진 않지만, 좋은 라이브러리를 굳이 마다할 이유는 없다고 생각하면서 위 라이브러리를 한 번쯤은 사용해 보시길 추천드립니다.

## [Error 멋지게 다루기 시리즈](/tags/error-멋지게-다루기/)를 마치며
첫 글에서 말씀드렸던 것처럼 **Go**에서는 매우 다양한 방법으로 `error`를 다룰 수 있습니다. 그러다보니 당연하게도 제가 공유한 방법만이 정답은 아니란 것을 말씀드리고 싶습니다.

저도 아직 **Go**를 공부하고 있는 학생인지라, 부족한 점이 많습니다. 혹시 `error`를 다루기 위한 더 좋은 방법이나, 잘못된 내용이 있다면 댓글을 통해 알려주시면 정말 감사하겠습니다. :smiley:

