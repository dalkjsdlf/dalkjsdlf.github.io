---
layout: single
title: "[항해+] 책임분리를 통한 어플리케이션 구현 관련 회고"
categories: 
 - Hhp
date: 2024-12-15 11:45:30:00 +0900
---
## 1. 과제의 핵심

- 트랜잭션 범위 분석 및 분리
- 이벤트를 통한 관심사 분리
- 카프카 비동기 메시지를 통한 책임분리

## 2. 이번 주 나의 고민

- 현재 구현된 ‘콘서트 예약’로직에서 지연이 발생(긴 트랜잭션)되는 지점 탐색
    - 없다면 데이터플랫폼에 기록하는 모듈을 하나 만들어서 외부 이벤트 통신 해보기
- 어떤 범위로 트랜젝션을 나눌지 고민
- 이벤트가 올바르게 발행되었다는 보장을 할 수 있는 방법?
- 어떤 케이스에 이벤트를 사용하는가?

## 3. 고민을 좀 더 상세하게

### 1) 트랜젝션이 되는 지점 탐색

하나의 트랜잭션 내에 여러 기능이 수행될 수 있다 콘서트 예약으로 예를 든다면 아래와 같다.

```java
tx{
	좌석이미예약확인() -> Concert 도메인 호출
	예약정보생성() -> 내부 로직 
	좌석예약상태변경() -> Concert 도메인 호출
}
```

만약 서비스가 Reservation과 Concert(Seat, Schecule은 포함)이 분리되어 있다면, 아래와 같은 상황이 예상 될 수 있다.

Concert 도메인 호출 시 통신오류 및 서버 오류로 장애가 발생할 수도 있다.

Concert 도메인 처리지연이 발생할 수 도 있다.(네트워크, DB 락 등)

이럴 경우 콘서트 좌석예약 전체에 대한 트랜잭션에 문제가 발생할 수 있다.

또한 예약 도메인이 콘서트정보관리에 대한 도메인에 의존성을 가지게 된다는 단점 또 한 가지고 있다. 

이는 콘서트정보관리 로직의 변경의 영향도가 예약도메인에 미칠 수 있다는 문제점을 야기할 수 있다.

그렇다면 이러한 상황에서 트래잭션 레이턴시를 줄이고 트랜잭션 응답속도를 높일 수 있는 방법이 있을까?

또한 도메인간 의존성을 낮추는 방법이 없을까?

일단 트랜잭션 레이턴시를 줄이는 방법은 비동기 로직으로 처리하는 것이다. 비동기로 처리하는 방식은 단순 어씽크로 처리하는 방식이 있고 HTTP통신으로 API 호출을 비동기로 처리하는 방식이 있고 이벤트 발행등을 통해서 비동기 처리하는 방식이 있다.

그런데! 

중요한 것은 내 로직이 비동기 처리가 가능한가를 판단하는 것이다. 

콘서트 좌석 예약은 좌석이미예약 확인, 예약정보생성, 좌석예약처리 등의 단계가 모두 …

순차적으로 처리되어야 한다…

즉 동기처리가 필요한 로직들인 것이다. 

이벤트 아키텍처 방식을 적용하는 것이 적절한지가 의심스럽다. (가져갈 수 있는 이점이 있는가?)

이점이라 하면 의존성을 완전히 분리할 수 있다는 것?

## 4. KEEP

실질적인 과제를 제대로 진행하지는 못해서 굉장히 아쉬운 9주차였다. 이유는 생소하고 잘 몰라서…

부족한 개념을 채우는 방향으로 시간될 때 짬짬히 도서와 블로그를 읽으며 이벤트 기반 아키텍처에 대해 알아보았다. 

이번 주차에 내가 잘한 점은 ‘왜?’ 라는 질문에 대한 답인 것 같다.

카프카, 이벤트 기반 방식, 분산환경, saga patern, outbox pattern 등등 … 여러 용어와 개념을 들었지만 정작 왜? 쓰는지에 대해서 이해를 제대로 못하고 있었다. 이번 주차에는 그 ‘왜?’라는 물음으로 부터 시작하여 

## 5. PROBLEM

직접 구현을 통해 시제로 테스트 해보며 과정을 경험하지 못한게 가장 큰 문제였다. 

이벤트 발행시 어떤 흐름으로 이벤트가 전이되는지 후처리는 어떻게 되는지 그러면서 발생되는 트랜잭션 이슈에 대해서 어떻게 조치 할 것인지를 직접 겪어봐야 OUTBOX패턴과 같은 패턴의 필요성을 느끼게 되고 더 깊이 있는 이해가 될 수 있는데 개념적으로만 알고 있는 느낌이라 아쉬움이 있다.

 

## 6. TRY

1. 마저 마무리 하지 못했던 9주차 과제 + 아웃박스 패턴 적용 프로젝트 새로 생성하여 설계 구현 해보기
2. 구현하면서 단순 모놀로직구조에서 분산환경으로 프로젝트를 나누면서 과정을 기록해보기
3. 과정 중 겪었던 문제들에 대한 이슈에 대해 기록하고 트러블슈팅을 기록한다.