---
layout: single
title: "[항해+] 공통 아키텍쳐 및 패키지구조"
categories: 
 - Hhp
date: 2024-12-15 11:45:30:00 +0900
---
# 1. 들어가기

본격적으로 비즈니스 도메인을 개발하기에 앞서서 패키지와 아키텍쳐의 구조가 먼저 준비가 되면 좀 더 효과적이고 체계적인 어플리케이션이 될 수 있을 것이라고 생각이 들었다. 문득 필요한 단위는 세가지였다. 

1. 시스템 공통영역
2. 도메인 의존 공통영역
3. 비즈니스 도메인영역

위 세가지 내용에 대하여 아래 간략하게 설명하도록 하겠다.

## 1. 시스템공통영역

시스템 공통영역이란 특정 어플리케이션에 종속되지 않는 범용적인 영역을 뜻한다. 즉 콘서트 예매라는 어플리케이션 혹은 API 모듈이 있다고 가정한다면, 해당영역은 다른 어플리케이션에서도 사용가능한 시스템 영역인 것이다. 예를들어 Persistence 설정, Advisor, Common Error Exception,  타입전환, 동시성 제어를 위한 LOCK제어, 문제열제어, 공통 메시징 처리, 공통 인터셉터, 어노테이션 설정, Reponse 등이 있다. 

볼륨이 크지 않아서 ‘플랫폼’이라는 용어는 부끄럽지만 나는 새로운 프로젝트를 개발하고 싶은 마음이 있으면 해당 시스템 공통영역을 다시 사용할 계획이다. 

## 2. 도메인 의존 공통영역

비즈니스 도메인영역은 성공적인 비즈니스 기능을 수행하기 위한 어플리케이션 의존 공통영역이다. 해당 영역은 모든 도메인 영역에 걸쳐 공통적으로 사용하는 기능을 정의하지만, 어플리케이션 의존성이 있어 다 시스템에서는 활용이 어려운 영역이다. 즉 어플리케이션에 특화된 영역인 것이다.

## 3. 비즈니스 도메인 영역

실제 비스니스 도메인이 정의된 영역이다. 해당 비즈니스 도메인 영역은 API영역과 도메인 영역으로 나뉘어져 있다. API영역과 도메인 영역을 분리시킨 이유는 순수 도메인으로써, 그 독립성을 지키고 싶었기 때문이다. 

# 2. 레이어 아키텍쳐

스프링에서 사용하고 있는 기본적인 MVC2 구조는 아래와 같다.

![image-right](/assets/images/post/2024-12-15-common-architecture/layer.png){: .align-center}


위 그림은 하나의 단일 도메인에 대하여 작성된 기본적인 MVC2구조이다. 

도메인 주도 설계를 진행하다보면 여기서 가장 자주 일어나는 현상이 발생하는데 바로 상호 도메인간 데이터를 하나의 오브젝트에 담아서 Client에 Response해줘야 할 때가 있다. 도메인 간 참조는 막는것이다. 또한 로직상 요청은 두 개 이상의 도메인의 조합이 될 수 있다.  

따라서 독립적인 도메인과 요청을 받아서 도메인들의 기능을 ‘사용’하게 하는 영역을 나누기로 하였다. 즉 사용자의 요청을 받아 서비스를 선택하는 영역인 컨트롤러와 서비스부터 시작하는 하위 레벨을 분리하였다.

그런데 과연 컨트롤러에서 직접 여러 도메인의 서비스를 호출하는 것이 맞을까? 나는 이 방식에 문제점을 고려해 보았을때 다음과 같았다. 

1. 레이어 역할에 적합하지 않음
2. 여러 도메인의 서비스 처리가 one transaction일 경우 컨트롤러에 transaction을 잡는것은 부적절
3. API 기능에 대한 도메인 즉 서비스와의 관계가 명확히 드러나 보이지 않음
4. 다양한 플랫폼으로부터 외부 요청을 대응해야 할 때, 혹은 Admin 요청과 사용자 요청의 컨트롤러를 다르게 구성해야 할때 도메인과 직접적인 의존성을 없앨 수 있다. 

도메인 영역 패키지 구조는 

# 3. 패키지 구조

패키지 구조는 크게 Business 영역을 담당하는 패키지(biz), Application 공통(common), 시스템 공통(system) 이렇게 세 가지로 나뉘었다.

```java
├── ConcertReservationApplication.java
├── biz
│   ├── api
│   └── domain
├── common
│   ├── annotation
│   ├── aop
│   ├── constants
│   └── serialize
└── system
├── config
├── constants
├── entity
├── exception
└── threadhandle
```

common과 system을 좀 더 펼쳐보면 다음과 같다.

```java
├── common
│   ├── annotation
│   │   └── ValidationToken.java
│   ├── aop
│   │   └── TokenValidationInterceptor.java
│   ├── constants
│   │   └── AppConst.java
│   └── serialize
│       ├── LocalDateTimeTypeAdapter.java
│       └── PayMethodConvertor.java
└── system
    ├── config
    │   ├── JpaConfig.java
    │   └── WebConfig.java
    ├── constants
    │   └── WebApiConst.java
    ├── entity
    │   └── AuditableFields.java
    ├── exception
    │   ├── ApiControllerAdvice.java
    │   ├── ErrorResponse.java
    │   ├── ReservationErrorResult.java
    │   └── ReservationException.java
    └── threadhandle
        ├── LockByKey.java
        └── SimultaneousEntriesLockByKey.java
```

common은 ‘ConcertReservation’이라는 Application에 맞춘 공통기능 영역이며, 대기열 토큰검사 annotaion 및 interceptor, dto에서 형변환 관련 공통기능이 포함되어 있다. 

system은 ConcertReservation이 아닌 다른 어플리케이션에서도 사용될 수 있는 영역이다.