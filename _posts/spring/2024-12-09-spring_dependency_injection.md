---
layout: single
title: "[스프링] 다양한 의존성 주입"
categories: 
 - Spring
date: 2024-12-09 00:06:00 +0900
toc: true
toc_sticky: true
---
스프링에서 사용되는 의존성 주입 방법 3가지

### 1. 생성자 주입

{% include code-header.html %}
```java
@Service
public class UserService{

	private UserRepositroy userRepository;
	private MemberService memberService;
	
	public UserService(
		UserRepository userRepository,
		MemberService memberService
	){
		this.userRepository = userRepository;
		this.memberService = memberService;
	}
}
```

- 생성자 주입은 생성자 호출시 1회 호출되는것을 보장한다.
    - 생성자는 한번만 호출될 수 있고 그 때문에 1회호출만 생성자 생성시에만 호출되는것을 보장한다.
- 1회 주입이 필수이며, 앞으로 주입된 객체가 변하지 않는다고 강제할 경우 사용한다.(불변성)
- 그렇기 때문에 Spring에서 Component 등록시 그 Component의 생성자에는 @Autowired가 생략되어도 주입이 가능하다.

 

### 2. 수정자 주입

{% include code-header.html %}
```java
@Service
public class UserService{
	private UserRepositroy userRepository;
	private MemberService memberService;
	
	@Autowired
	public void setUserRepository(UserRepository userRepository){
		this.userRepostiroy = UserRepository;
	}
	
	@Autowired	
	public void setMemberService(MemberService memberService){
		this.memberService = memberService;
	}
}
```

- 주입받는 객체가 변경될 가능성이 있을 경우에 사용된다.
- setXX메서드는 언제나 호출이 가능하기 때문에 수정가능성을 열어둔 방법이다.
- setXX메서드를 불러오지 않으면 객체가 주입되지 않기때문에 오류가 발생한다.
- 만약 주입없이 오류없이 실행하고 싶다면 @Autowired(required=false)를 설정한다.

### 3. 필드주입

{% include code-header.html %}
```java
@Service
public class UserService{
	@Autowired
	private UserRepository userRepository;
	
	@Autowired
	private MemberService memberService;
}
```

- 작성이 간편하다는 장점이 있는 반면 외부 주입이 어렵다.
- 외부주입이 불가능하기 때문에 TEST코드 작성시 Spring통합테스트(Spring이 주입시켜줘야되니깐)로 진행해야 되고 슬라이스 테스트가 불가능하게 된다.

### 4. 생성자 주입을 사용해야 하는 이유

1) 불변성을 보장한다.(무분별하게 주입객체를 수정하지 못한다.)

- 생성자 주입시를 제외하고는 주입이 불가능하게 된다.

1) 스프링 비침투적인 코드 작성이 가능하다.(Spring에 의해 주입이 필요없다.)

2) 슬라이스 테스트가 가능하다.

- 필드주입은 프레임워크 단위로 주입이 되고, 수정자 주입같은 경우에는 직접주입이 필요한데 주입되지 않을 경우 NPE이 발생하여 문제가 된다.
- 생성자주입이 아니면 주입이 안될 경우 런타임시 에러가 발생하지만, 생성자 주입같은 경우에 컴파일 시점에 에러를 내 밷는다.

4) final 키워드 및 lombok과의 연동이 가능하다.(이것은 직접 봐야 이해될것 같음)

- 주입할 필드 객체에 final 키워드를 붙이게 되면 lombok의 @RequiredArgsConstructor 어노테이션을 통해 생성자 주입을 할 수 있다.

5) 순환 참조 에러 방지(이것도 무슨말인지 직접 봐봐야 알 수 있을 것 같음)

- 만약 두 객체가 서로의 객체를 필드객체로 의존성 주입을 하고 있다면 순환참조에러가 발생할 것이다.
- 생성자 주입이 아닌경우에는 이러한 문제를 런타임중에 발견할 수 있겠지만 생성자 주입을 사용할 경우에는 어플리케이션 구동중에 에러를 내 뱉기 때문에 조기에 발견할 수 있다.