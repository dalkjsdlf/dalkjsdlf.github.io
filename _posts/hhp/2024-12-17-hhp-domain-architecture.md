---
layout: single
title: "[항해+] 아키텍처 레이어 설계: UseCase 중심의 레이어 설계와 고민들"
categories: 
 - Hhp
date: 2024-12-17 02:00:30:00 +0900
toc: true
toc_sticky: true
---

도메인 영역의 architecture 고민

# **아키텍처 레이어 설계: UseCase 중심의 레이어 설계와 고민들**

---

## **1. 시작하며**

아키텍처 설계는 개발에서 가장 중요한 결정 중 하나다.  
특히 레이어드 아키텍처(layered architecture)를 설계할 때, 각 레이어의 역할과 책임을 명확히 정의하는 것은 프로젝트의 유지보수성과 확장성을 좌우하는 핵심이다.  

나는 도메인 중심의 설계를 지향하며, 기존의 MVC 패턴에서 조금 변형된 구조를 도입했다.  
그 결과, 다음과 같은 **4개의 레이어**로 구성된 아키텍처를 설계하게 되었다:

- **Controller → UseCase → Component → Repository**

이번 글에서는 이 구조를 설계한 이유와 각 레이어의 역할, 그리고 실제로 설계하면서 고민했던 점들을 공유하고자 한다.

---

## **2. 설계한 레이어의 구조와 역할**

### **2.1 레이어 구성**
설계한 레이어는 크게 다음과 같이 구성된다:

1. **Controller**:  
   - 클라이언트의 요청을 받고 응답을 반환한다.
   - 데이터를 전달받아 UseCase와 통신한다.
   - **DTO(Data Transfer Object)**를 사용해 데이터와 요청을 주고받는다.

2. **UseCase**:  
   - **Facade 패턴**으로 여러 도메인의 조합을 처리한다.
   - 비즈니스 로직을 최소화하고, 조합된 Component 호출을 관리한다.
   - UseCase의 이름은 **"동사 형태"**로 지어져, 실행할 작업의 의도를 명확히 표현한다.

3. **Component**:  
   - 도메인 영역의 세부 로직을 처리한다.
   - 작은 단위의 기능을 구현하며, 각 클래스는 보통 1~2개의 메서드만 가진다.
   - **Domain 객체**를 사용하여 데이터를 주고받는다.

4. **Repository**:  
   - 데이터베이스와 직접적으로 통신한다.
   - **Interface**로 정의하며, 이를 구현한 JpaRepository를 통해 DB 작업을 처리한다.
   - Component에서는 Repository의 **Interface**만 주입받아 사용한다.

---

### **2.2 기존 MVC 패턴과의 차별점**

#### **MVC 패턴의 한계**
- 일반적으로 MVC는 **Controller → Service → Repository**로 구성된다.
- 그러나 Service 레이어는 종종 여러 도메인의 로직이 뒤섞여 관리되거나, 과도한 비즈니스 로직이 추가되어 점점 복잡해진다.
- 결과적으로 도메인 간의 결합도가 높아지고, 변경이 어려워진다.

#### **UseCase와 Component로 개선한 구조**
- **UseCase**를 중간에 두어 여러 도메인의 조합을 담당하도록 설계했다.  
  - 예를 들어, A 도메인과 B 도메인이 조합된 결과를 반환하는 작업은 UseCase 레이어에서 수행된다.
  - UseCase는 "조합과 호출"만 담당하고, 비즈니스 로직은 Component에 위임한다.
- **Component**는 Service보다 작은 단위로 분리하여 각 도메인의 책임을 명확히 했다.  
  - 도메인 간 참조를 없애고, 필요한 데이터만 처리하도록 설계했다.

---

## **3. 레이어 간의 데이터 전환 방식**

이 설계에서 가장 신경 쓴 부분은 **레이어 간의 데이터 전환**이다.  
각 레이어는 다음과 같은 데이터 객체를 사용한다:

- **Controller ↔ UseCase**: **DTO**를 사용해 데이터를 주고받는다.
- **UseCase ↔ Component**: **Domain 객체**를 사용해 데이터를 주고받는다.
- **Component ↔ Repository**: **Entity 객체**를 사용해 데이터를 주고받는다.

### **이 방식의 장점**
- **책임 분리**:  
  - Controller와 UseCase는 **웹 API 영역**으로 분리되며, Component는 **도메인 영역**, Repository는 **인프라 영역**으로 역할이 명확히 나뉜다.
  - 각 레이어가 자신만의 데이터를 사용하므로, 서로의 변경에 영향을 받지 않는다.
- **도메인 중심 설계**:  
  - Component에서 도메인 객체를 사용해 비즈니스 로직을 구현함으로써, 도메인 모델을 유지하고 관리하기 쉬워진다.

### **이 방식의 단점**
- **레이어 간 데이터 전환 비용**:  
  - DTO, Domain, Entity 간 데이터를 변환하는 코드가 많아진다.
  - 특히 복잡한 데이터 구조를 처리할 때 변환 코드가 길어져 생산성이 떨어질 수 있다.
- **중복 코드**:  
  - 변환 로직이 여러 곳에 흩어져 중복 코드가 발생할 가능성이 있다.

---

## **4. 고민과 해결**

### **4.1 레이어 간 전환 비용**
레이어 간의 데이터 전환 비용이 많아지면, 가독성과 유지보수성이 떨어질 수 있다.  
이를 해결하기 위해 **Mapper**나 **Converter**를 사용하여 변환 로직을 재사용 가능한 방식으로 추출했다.

#### **해결 방법: Mapper 사용**
{% include code-header.html %}
```java
@Component
public class UserMapper {
    public UserDto toDto(UserDomain userDomain) {
        return new UserDto(userDomain.getName(), userDomain.getEmail());
    }

    public UserDomain toDomain(UserEntity userEntity) {
        return new UserDomain(userEntity.getName(), userEntity.getEmail());
    }
}
```
이 방식으로 변환 코드를 별도의 클래스에 분리하여, 중복을 최소화하고 유지보수성을 높였다.

### **4.2 UseCase와 Component의 역할 구분**

UseCase와 Component가 각자 맡는 역할을 명확히 구분해야 중복된 책임이 생기지 않는다.

- **UseCase**는 여러 도메인의 조합과 호출만 담당하며, 로직 구현을 최소화한다.
- **Component**는 도메인의 비즈니스 로직을 책임지고, 필요한 경우 다른 Component를 호출하여 처리한다.

#### **역할 구분의 예시**

1. **UseCase의 역할**:
   - 여러 Component를 조합하여 클라이언트 요청에 대한 결과를 반환.
   - 예를 들어, `OrderUseCase`는 주문 데이터를 처리하기 위해 `PaymentComponent`와 `InventoryComponent`를 호출.
  {% include code-header.html %}
   ```java
   public class OrderUseCase {
       private final PaymentComponent paymentComponent;
       private final InventoryComponent inventoryComponent;

       public OrderUseCase(PaymentComponent paymentComponent, InventoryComponent inventoryComponent) {
           this.paymentComponent = paymentComponent;
           this.inventoryComponent = inventoryComponent;
       }

       public OrderResponse processOrder(OrderRequest request) {
           paymentComponent.processPayment(request.getPaymentInfo());
           inventoryComponent.reserveStock(request.getProductId(), request.getQuantity());
           return new OrderResponse("SUCCESS");
       }
   }
   ```

   	2.	Component의 역할:
	•	각 도메인에 특화된 비즈니스 로직을 처리.
	•	단일 책임 원칙(SRP)을 준수하며, 한 클래스가 하나의 도메인 작업만 담당.
  
{% include code-header.html %}
```java
    public class PaymentComponent {
      public void processPayment(PaymentInfo paymentInfo) {
          // 결제 처리 로직
      }
  }

  public class InventoryComponent {
      public void reserveStock(Long productId, int quantity) {
          // 재고 예약 로직
      }
  }
  ```

  #### 구분의 장점
	•	UseCase는 단순히 “조합자”로서의 역할만 수행하며, 복잡한 도메인 로직을 피할 수 있다.
	•	Component는 “작업자”로서 도메인별 로직을 책임지므로, 변경이나 확장이 용이하다.

  ### **5. 정리하며**

이번 설계는 도메인 중심으로 레이어를 설계하고, 각 레이어의 역할과 데이터를 명확히 분리하는 데 초점을 맞췄다.
	•	Controller ↔ UseCase ↔ Component ↔ Repository라는 구조를 통해 책임을 분리했다.
	•	UseCase를 추가하여 여러 도메인의 조합을 처리하고, Component를 통해 세부 로직을 관리했다.
	•	DTO, Domain, Entity를 활용해 레이어 간 데이터를 전환하며, Mapper를 통해 전환 비용을 줄이려고 노력했다.

#### 장점
	1.	책임 분리: 레이어마다 명확한 책임을 가지고 있어 변경에 유연하다.
	2.	유지보수성: 도메인 간 결합도를 낮추어 코드의 재사용성과 안정성을 높였다.
	3.	테스트 용이성: UseCase와 Component를 단위로 테스트하기 쉬워졌다.

#### 단점
	1.	데이터 전환 비용: 각 레이어 간 전환 작업이 많아 코드가 장황해질 수 있다.
	2.	설계 복잡성: 구조가 단순한 프로젝트에서는 오히려 과한 설계가 될 수 있다.

### **결론**

도메인 중심 설계를 지향하면서도 실용성을 고려한 설계가 필요하다.
레이어 간 데이터 전환의 비용과 책임 분리의 장점을 비교하여, 프로젝트의 복잡도와 요구사항에 맞는 구조를 선택하는 것이 핵심이다.

이 설계를 통해 더 확장성과 유지보수성이 높은 시스템을 만들 수 있을 것이다.