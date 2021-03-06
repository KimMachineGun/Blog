---
title: "Go언어란?"
description: "Go언어에 대해 알아봅니다."
date: 2018-07-15T02:14:43+09:00
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
    "프로그래밍"
]
image: "post/Go/Go언어란/cover.jpg"
---

## Go언어의 역사
**Go**는 로버트 그리즈머, 롭 파이크, 켄 톰슨에 의해 디자인된 프로그래밍 언어로 2007년 구글에서 프로젝트가 시작되었습니다. 그로부터 2년 후인 2009년 11월 **Go**언어가 공식 발표되었고, 2012년 3월 `1.0` 버전이 릴리즈되었습니다. `1.0` 버전이 릴리즈되고 3년 후인 2015년 8월 컴파일러를 **C**언어에서 **Go**언어로 다시 작성한 `1.5` 버전이 릴리즈 되었습니다. **Go** 프로젝트는 지속적으로 발전하여 현재(2018/07/15) `1.10` 버전이 릴리즈 된 상태입니다.

## Go언어의 특징
- **오픈소스 언어입니다.**  
    [GitHub](https://github.com/golang/go)에서 확인하실 수 있습니다.
- **컴파일 언어입니다.**  
    컴파일 언어 중에서도 매우 빠른 컴파일 속도를 자랑합니다. 또한, 바이너리 파일로 컴파일되기 때문에 몇 가지 환경변수(`GOOS`와 `GOARCH`) 수정만으로도 다른 OS에서 동작하는 바이너리 파일을 쉽게 만들 수 있습니다.
- **정적 타입 언어입니다.**  
- **문법이 특이하지만 간단합니다.**  
    타입을 변수명 뒤에 작성하고, 세미콜론을 찍지 않는 등 문법이 기존 언어들과 많이 다릅니다. 하지만, 키워드 수가 25개 밖에 되지 않기 때문에 문법 자체는 간단한 편입니다.
- **강력하고 편한 동시성 프로그래밍이 가능합니다.**  
    `go routine`과 `channel`을 통하여 강력한 성능을 가진 동시성 프로그램을 쉽게 작성할 수 있습니다.

## Go를 공부하게 된 이유
사실 제가 **Go**를 공부하게 된 이유는 단순합니다. 고등학교에 입학하고 학교에서 C를 배우면서 다른 언어도 한번 배워보고 싶었습니다. 친구의 추천으로 [A Tour of Go](https://tour.golang.org/welcome/1)를 해보게 되었고, **Go**의 매력에 빠져  **Go**를 본격적으로 공부하게 되었습니다.

## 앞으로의 포스팅 계획
**Go**의 기본적인 내용은 많은 책과 블로그, [A Tour of Go](https://tour.golang.org/welcome/1)를 통해 쉽게 접할 수 있을 것 같다 생각하여, 기본적인 내용보다는 심화적인 내용과 실제 코드를 위주로 포스팅할 예정입니다.