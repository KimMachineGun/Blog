---
title: "Go modules 살펴보기"
description: "Go 1.11에 추가된 Go modules에 대해 알아봅니다."
date: 2018-08-25T16:34:42+09:00
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
    "GO111MODULE"
]
---

## Go += Package Versioning
Go는 초기 패키지를 관리하기 위한 마땅한 도구가 없었습니다. 하지만 의존성 관리는 프로젝트를 진행하며 꼭 필요한 기능인지라, 시간이 지나며 의존성 관리를 위한 다양한 써드파티 라이브러리들이 등장하기 시작했습니다. 마침내 **Go**에서 의존성 관리를 위한 툴인 [dep](https://github.com/golang/dep)을 발표하였고, dep은 공식 툴로 자리잡게 되었습니다.

dep은 강력하고, 유용하게 사용되긴 했지만 패키지 버저닝을 위한 궁극적인 커맨드 툴은 아니였습니다. 조금 더 Go-ish하고 넓은 범위에서 패키지를 관리할 툴이 필요했습니다. 그리고 마침내 Russ Cox의 제안으로 vgo 프로젝트가 패키지 버저닝을 위한 **Go**의 공식 프로젝트로 채택되었고, `go 1.11` 버전에서는 Go modules가 도입되어 시험적으로 사용할 수 있게 되었습니다.

## vgo는 잠시 안녕...
vgo를 설치하여 Go modules을 사용할 수도 있지만, 이 글에선 `go 1.11` 버전의 `go mod` 커맨드를 통하여 Go modules을 사용할 예정입니다. vgo의 설치는 `go get -u golang.org/x/vgo`을 통해 하실 수 있습니다. vgo 사용법과 더 자세한 내용은 [Go & Versioning](https://research.swtch.com/vgo)에서 살펴보실 수 있습니다.

## GO111MODULE
`go 1.11` 버전에서 Go modules가 등장하며 기존 `GOPATH`와 `vendor/`에 따라 동작하던 `go` 커맨드와의 공존을 위한 `GO111MODULE`이라는 임시 환경변수가 생겼습니다. 이 환경변수에는 세 가지 값이 올 수 있습니다. 

만약 `GO111MODULE`의 값이 `on`인 경우 `go` 커맨드는 `GOPATH`에 전혀 관계없이 Go modules의 방식대로 동작합니다. `off`인 경우 Go modules는 전혀 사용되지 않고 기존에 사용되던 방식대로 `GOPATH`와 `verdor/`를 통해 `go` 커맨드가 동작합니다. 만약 값을 설정하지 않았거나 `auto`로 설정한 경우, `GOPATH/src` 내부에서의 `go` 커맨드는 기존의 방식대로, 외부에서의 `go` 커맨드는 Go modules의 방식대로 동작합니다. 

이 글에선 별도로 환경변수를 설정하지 않고 진행하도록 하겠습니다.

## 시작하기
일단 프로젝트가 위치할 디렉터리를 만들도록 하겠습니다. 환경변수를 설정하지 않았으므로, Go modules을 사용하기 위해 경로는 `GOPATH/src` 밖에 위치하도록 하겠습니다.

```none
test/
```

이제 내부에 코드를 추가하도록 하겠습니다. 저는 echo를 사용한 간단한 서버 코드를 넣었습니다.

```go
// main.go
package main // import "github.com/KimMachineGun/hello"

import (
	"net/http"
	
	"github.com/labstack/echo"
)

func main() {
	e := echo.New()

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})

	e.Logger.Fatal(e.Start(":1323"))
}
```

이 코드 중 주목해서 보셔야 할 곳은 첫 줄의 `// import "github.com/KimMachineGun/hello"` 입니다. 이는 Module이 위치한 경로를 나타냅니다. 일반적으론 `// import "github.com/<user-name>/<repo-name>"`을 사용합니다. 이를 추가하지 않고 모듈을 생성하려면 `go mod init <module-name>`을 사용하시면 됩니다.

모듈을 생성하기 위해 프로젝트 루트 디렉터리에서 `go mod init` 커맨드를 실행합니다. 커맨드가 정상적으로 실행되었다면, 프로젝트 디렉터리의 내부 모습은 다음과 같을 것입니다.

```none
test/
    go.mod
    main.go
```

`go.mod` 파일은 모듈에 대한 정보가 담겨 있습니다. 아직 프로젝트 초기화 외의 다른 작업은 하지 않았기 때문에, 현재 모듈의 정보만 담겨있을 것입니다.

```none
module github.com/KimMachineGun/test
```

이제 아무런 `go` 커맨드를 실행하면 import 된 패키지의 정보가 업데이트 될 것입니다. 저는 바로 빌드하기 위해 `go build` 커맨드를 사용하겠습니다.

```cmd
>go build
go: finding github.com/labstack/echo v3.2.1+incompatible
go: downloading github.com/labstack/echo v3.2.1+incompatible
go: finding github.com/labstack/gommon/color latest
go: finding github.com/labstack/gommon/log latest
go: finding github.com/labstack/gommon v0.2.1
go: finding golang.org/x/crypto/acme/autocert latest
go: downloading github.com/labstack/gommon v0.2.1
go: finding golang.org/x/crypto/acme latest
go: finding golang.org/x/crypto latest
go: downloading golang.org/x/crypto v0.0.0-20180820150726-614d502a4dac
go: finding github.com/valyala/fasttemplate latest
go: finding github.com/mattn/go-isatty v0.0.3
go: finding github.com/mattn/go-colorable v0.0.9
go: downloading github.com/mattn/go-isatty v0.0.3
go: downloading github.com/mattn/go-colorable v0.0.9
go: downloading github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4
go: finding github.com/valyala/bytebufferpool latest
go: downloading github.com/valyala/bytebufferpool v0.0.0-20160817181652-e746df99fe4a
```

`go` 커맨드를 사용하면 자동으로 import 된 패키지를 찾고 `GOPATH/pkg/mod/` 하위에 버전에 따라 설치됩니다. 이 때 프로젝트 루티 디렉터리에 `go.sum` 파일도 함께 생성됩니다. 이 파일은 설치된 모듈의 hash 값을 저장하고, `go` 커맨드가 실행되기 전에 모듈과 `go.sum`의 해쉬값을 비교하여 설치된 모듈의 유효성을 검증합니다. 

`go build` 커맨드를 사용했기 때문에, 바로 빌드까지 완료되어 실행 파일까지 생성되어 프로젝트 디렉터리는 다음과 같은 모습일 것입니다.

```none
test/
    go.mod
    go.sum
    main.go
    test.exe
```

이제 의존성이 확인되고 모듈들이 설치되었으므로, `go.mod` 파일 내부에 의존성에 관련된 정보도 추가되었을 것입니다.

```none
module github.com/KimMachineGun/test

require (
	github.com/labstack/echo v3.2.1+incompatible
	github.com/labstack/gommon v0.2.1 // indirect
	github.com/mattn/go-colorable v0.0.9 // indirect
	github.com/mattn/go-isatty v0.0.3 // indirect
	github.com/valyala/bytebufferpool v0.0.0-20160817181652-e746df99fe4a // indirect
	github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4 // indirect
	golang.org/x/crypto v0.0.0-20180820150726-614d502a4dac // indirect
)
```

우리는 `go.mod` 파일을 수정하여 패키지 실행에 필요한 모듈을 관리할 수 있습니다.

만약, 새로운 모듈을 추가하고 싶다면 `go get <module-path>@<module-query>` 커맨드를 사용하시면 됩니다. Module query에 대한 더 자세한 내용은 [공식 문서](https://golang.org/cmd/go/#hdr-Module_queries)를 통해 확인하실 수 있습니다. 버전 지정이 필요가 없다면 코드에서 바로 import 하면 `go` 커맨드가 실행될 때 자동으로 추가될 것입니다.

저는 `fatih/color` 모듈을 가장 최신 버전으로 추가해 보도록 하겠습니다.

```cmd
>go get github.com/fatih/color@latest
go: finding github.com/fatih/color v1.7.0
go: downloading github.com/fatih/color v1.7.0
```

커맨드가 정상적으로 실행됐다면 `go.mod` 파일에 `fatih/color`에 대한 정보가 추가됐을 것입니다.

```none
module github.com/KimMachineGun/test

require (
	github.com/fatih/color v1.7.0 // indirect
	github.com/labstack/echo v3.2.1+incompatible
	github.com/labstack/gommon v0.2.1 // indirect
	github.com/mattn/go-colorable v0.0.9 // indirect
	github.com/mattn/go-isatty v0.0.3 // indirect
	github.com/valyala/bytebufferpool v0.0.0-20160817181652-e746df99fe4a // indirect
	github.com/valyala/fasttemplate v0.0.0-20170224212429-dcecefd839c4 // indirect
	golang.org/x/crypto v0.0.0-20180820150726-614d502a4dac // indirect
)
```

이제 다시 빌드하고 정상적을 동작하는지 확인해 보겠습니다.

![실행 결과](/post/Go/Go-modules-살펴보기/실행결과.JPG)

정상적으로 동작하는군요!! 이로써 `go 1.11`에 추가된 Go modules 사용법에 대해 간략하게나마 살펴본 것 같습니다. 위에서 다루지 않았지만 간혹 사용될 것 같은 커맨드에 대해선 아래에 추가로 정리하도록 하겠습니다. 

## 커맨드 정리
- **go mod init [module-name]**  
모듈을 생성합니다. 커맨드에서 `[module-name]`을 생략했다면, `// import "<import-path>"`를 추가하여야 합니다.
- **go get \<module-path>@\<module-query>**  
버전을 지정해 모듈을 추가합니다. `<module-query>`에 대해서는 [공식 문서](https://golang.org/cmd/go/#hdr-Module_queries)를 참고하시면 될 것 같습니다.
- **go mod tidy [-v]**  
`go.mod` 파일과 소스코드를 비교하여, import 되지 않은 의존성은 제거하고, import 되었지만 의존성 리스트에 추가되지 않은 모듈은 추가합니다. `-v` 플래그를 통해 더 자세한 정보를 확인할 수 있습니다.
- **go mod vendor [-v]**  
`vendor/` 디렉터리를 생성합니다. `-v` 플래그를 통해 더 자세한 정보를 확인할 수 있습니다.
- **go mod verify**  
로컬에 설치된 의존성 모듈의 해시와 `go.sum`을 비교하여 모듈이 변경되지 않았는지 확인합니다.

## 마치며
포스팅을 하며 **Go**를 시작하며 낯설고, 복잡하게 느껴지는 `GOPATH`와 의존성 관리 문제가 Go modules로 해결될 수 있겠다는 느낌을 받았습니다. 저는 특별한 이슈가 발견되지 않는다면 Go modules를 적극 활용하고 싶네요. :smiley: