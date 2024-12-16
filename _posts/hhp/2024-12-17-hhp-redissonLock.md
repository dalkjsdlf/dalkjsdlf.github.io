---
layout: single
title: "[항해+] 100만 명이 동시에 예매를 시도한다면? Redisson으로 분산 락 해결하기"
categories: 
 - Hhp
date: 2024-12-17 02:00:30:00 +0900
toc: true
toc_sticky: true
---

콘서트의 좌석 예약과 관련하여 동시성 이슈를 해결하기 위한 Lock 선택

---

## 1. 들어가기: 왜 이 문제를 고민했을까?

콘서트 예매 시스템을 만들면서 한 가지 문제를 만났다.  
같은 좌석을 예매하려는 요청이 **동시에 100만 건** 들어온다면, 누군가 먼저 선점해서 좌석을 예약해야 하는데, 서버가 이를 제대로 관리하지 못하면 **여러 사용자가 같은 좌석을 차지하려고 하거나** 데이터가 꼬이는 문제가 생길 수 있다.  
이 문제를 해결하기 위해 어떤 락(lock) 메커니즘을 사용할지 고민했고, 여러 후보를 비교한 끝에 최적의 선택을 내렸다.

---

## 2. 문제 상황: 왜 이런 일이 생길까?

### 상황 설명
1. 같은 공연, 같은 시간, 같은 좌석에 대해 예매 요청이 몰려온다.
2. 좌석의 상태를 업데이트하는 과정에서 **race condition**이 발생한다.
   - 두 명 이상이 동시에 좌석 상태를 "예약 중"으로 변경하려고 하면 충돌이 발생한다.
   - 동일 좌석이 여러 사람에게 할당될 가능성이 생긴다.
3. **결과**:
   - 데이터 불일치가 발생한다.
   - 사용자는 좌석 예매 성공을 기대하지만, 실제로는 다른 사람에게 뺏길 수도 있다.

### 제약 조건
- **먼저 선점한 사용자만** 좌석을 차지해야 한다.
- 100만 명의 요청이 서버에 몰리는 상황에서도 효율적으로 처리해야 한다.
- 데이터베이스와 서버의 자원 사용을 최소화해야 한다.

---

## 3. 해결 시도: 비관적 락, 낙관적 락, 분산 락 비교

문제를 해결하기 위해 사용할 수 있는 세 가지 메커니즘을 비교해 봤다. 각각의 장단점을 분석하면서 고민했던 과정을 정리해본다.

### **(1) 비관적 락**
- **작동 방식**: 데이터베이스의 `SELECT ... FOR UPDATE`를 사용해 좌석(Row)을 락으로 묶어서 다른 트랜잭션이 접근하지 못하도록 한다.
- **장점**:
  - 데이터 충돌을 완벽히 방지할 수 있다.
  - 락이 유지되는 동안 다른 사용자가 접근할 수 없으므로 데이터 일관성을 보장한다.
- **단점**:
  - **성능 문제**: 100만 건의 동시 요청에서 다수의 트랜잭션이 대기 상태로 전환되어 병목 현상이 발생한다.
  - **Deadlock 가능성**: 교착 상태를 예방하기 위해 추가적인 관리가 필요하다.

---

### **(2) 낙관적 락**
- **작동 방식**: 좌석 데이터의 `version` 필드를 이용해서 업데이트 시 충돌 여부를 확인한다.  
  데이터가 이미 변경되었다면 예매를 취소하거나 재시도를 한다.
- **장점**:
  - 락을 유지하지 않으므로 성능이 우수하다.
  - 충돌이 적을 경우 효율적이다.
- **단점**:
  - 100만 건의 동시 요청에서 충돌이 빈번히 발생하면 **재시도 횟수가 폭발적으로 증가**한다.
  - 실패율이 높아지고, 사용자 응답 시간이 길어질 위험이 있다.

---

### **(3) 분산 락**
- **작동 방식**: Redis와 같은 분산 락 메커니즘을 사용하여 좌석의 락을 중앙에서 관리한다.  
  Redis의 `SETNX`(set if not exists) 명령어로 하나의 사용자만 락을 획득하도록 한다.
- **장점**:
  - **최초 선점 보장**: 동시 요청 중 하나의 트랜잭션만 락을 획득하도록 설계 가능하다.
  - **성능 우수**: Redis는 메모리 기반이라 100만 건의 요청도 고속 처리 가능하다.
  - **Deadlock 방지**: TTL(Time-To-Live)을 설정해 락이 자동으로 해제되도록 관리할 수 있다.
- **단점**:
  - 외부 시스템(예: Redis)에 의존해야 한다.
  - TTL 설정과 장애 상황 처리에 대한 추가 관리가 필요하다.

---

### 결론: **분산 락을 선택한 이유**

비관적 락은 **병목 현상**이 심각해서 실현 가능성이 낮았고, 낙관적 락은 충돌이 많아지는 환경에서 **재시도 오버헤드**가 발생했다.  
반면, 분산 락은 **최초 선점을 보장**하면서도 성능을 유지할 수 있었고, Redis의 TTL 설정을 활용해 안정성도 확보할 수 있었기 때문에 최적의 선택이라고 판단했다.

---

## 4. 해결: RedissonClient로 분산 락 구현하기

### 구현 방법
Redisson은 Redis를 활용한 Java 기반의 분산 락 라이브러리다.  
여기서 RedissonClient를 사용해 락을 구현했고, 핵심 코드는 아래와 같다.

```java
@Transactional(isolation = Isolation.READ_COMMITTED, propagation = Propagation.REQUIRES_NEW)
public void execute(List<Seat> seats, Long userId) {
    // Redis 분산 락 키 설정
    String key = "seatLock";
    RLock lock = redissonClient.getLock(key);

    try {
        // 락 획득 시도 (5초 대기, 2초 TTL)
        lock.tryLock(5, 2, TimeUnit.SECONDS);

        log.info("[{}] Thread가 좌석 검사하기 전", Thread.currentThread().getName());

        // 1. 좌석이 이미 예약되었는지 확인
        seatSupportor.checkAlreadyReservedSeatOfSeats(seats);
        log.info("[{}] Thread가 좌석 검사 후", Thread.currentThread().getName());

        // 2. 좌석의 스케줄 ID 조회
        Long scheduleId = seatReader.readScheduleIdOfSeats(seats);

        // 3. 좌석들의 가격 합계 계산
        Long totalPrice = seatSupportor.sumTotalPrice(seats);

        // 4. 예약 객체 생성
        Reservation reservation = ReservationCreator.create(
                userId,
                scheduleId,
                seats.size(),
                totalPrice,
                PaymentStatus.WAIT);

        // 5. 예약 정보 추가
        Reservation addReservation = reservationModifier.addReservation(reservation);

        // 6. 좌석 상태 업데이트 (예약 처리)
        seatModifier.reserveSeats(seats, addReservation.getId());

        // 테스트: 예외 발생
        throw new ReservationException(ReservationErrorResult.UNKNOWN_EXCEPTION);

    } catch (InterruptedException e) {
        throw new ReservationException(ReservationErrorResult.UNKNOWN_EXCEPTION);
    } finally {
        // 락 해제
        lock.unlock();
    }
}
```

## 5. 느낀 점: 분산 락으로 문제를 해결하며 배운 것들

### 1. 문제 이해가 핵심이다

락을 선택하기 전에 비관적 락, 낙관적 락, 분산 락을 비교하면서 각각의 장단점을 파악했다.
100만 건의 동시 요청에서는 분산 락이 유일하게 실현 가능한 방법이라는 결론을 내렸다.

### 2. Redisson의 강력함

RedissonClient는 락 관리가 간단하고, TTL 설정으로 Deadlock 문제를 예방할 수 있어서 정말 효율적이었다.
또한, 테스트 환경에서 10만 건 이상의 동시 요청도 문제없이 처리할 수 있었다.