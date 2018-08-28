---
title: "Go modules에서 local package import하기"
description: "Go modules에서 local package를 import하는 방법을 알아봅니다."
date: 2018-08-28T15:57:31+09:00
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
    "vgo",
    "vgo tutorial",
    "vgo 강의",
    "vgo란?",
    "golang vgo",
    "vgo 사용법",
    "dep",
    "glide",
    "maven",
    "npm",
    "Dependency",
    "의존성 관리",
    "go 1.11",
    "Go modules",
    "Go modules 사용법",
    "GO111MODULE",
    "local package",
    "GOPATH",
    "import",
    "local package import"
]
---

## 문제
Go modules와 `GOPATH`가 공존하고 있는 `go 1.11`에서 Go modules를 사용하면서 몇 가지 불편함을 겪을 수 있습니다. 그 중 local package를 Go modules 프로젝트에 import하는 방법에 대해 알아보도록 하겠습니다.

## 방법
1. **가짜 `go.mod` 추가하기**  
    Go modules 프로젝트에서 import하여 사용하고 싶은 package의 루트 디렉터리에 `go.mod` 파일을 추가합니다. `go.mod` 파일 안의 내용은 비어 있어도 괜찮습니다.
2. **require 추가하기**  
    Go modules 프로젝트의 `go.mod` 파일 안에 import할 package에 대한 의존성을 추가해야 합니다. `require`은 의존성을 추가하는 구문이고, `replace`가 모듈의 경로를 바꿔주는 구문입니다. `packagename`과 `packagepath`에 각각 import할 package의 이름과 경로를 넣어 주시면 됩니다.

    ```none
    module example/test

    require packagename v0.0.0

    replace packagename => packagepath
    ```

3. **import 하기**  
    이제 위에서 사용한 `packagename` 을 통해 코드에서 import한 후 사용하시면 됩니다.

    ```go
    // main.go
    package main // import "example/test"

    import (
        "fmt"

        "packagename"
    )

    func main() {
        fmt.Println(packagename.Sum(1, 3))
    }
    ```

## <div style="color: red; text-align: center;">:exclamation:권장되지 않는 방법일 수 있습니다.:exclamation:<div>
<p style="text-align: center;">더 좋은 방법을 알고 계시다면 댓글을 통해 알려주시면 감사하겠습니다. :smile:</p>
 