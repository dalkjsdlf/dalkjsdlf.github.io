---
layout: single
title: "[네트워크] DNS 서버 구축"
categories: 
 - Network
date: 2024-12-09 00:06:00 +0900
---

DNS 서버 구축방법을 알아보자
DNS 서버를 구축하기 위해 해당 네임서버에 ‘bind9’이 설치되어야 한다.

'bind9'는 널리 사용되는 DNS 서버 중 하나 이다. 이 소프트웨어는 네임서버에 설치되어 인터넷 도메인 이름을 IP 주소로 변환하는 역할을 한다. 'bind9'는 다양한 플랫폼에서 사용할 수 있으며, 높은 안정성과 유연성을 제공한다.

---

리눅스에서 DNS 서버를 구축하는 기본적인 방법은 다음과 같습니다.

1. 먼저, bind9 패키지를 설치해야 합니다. 이는 대부분의 리눅스 배포판의 기본 리포지토리에 포함되어 있습니다. 설치는 다음의 명령어로 수행할 수 있습니다: `sudo apt-get install bind9`
2. 설치가 완료되면, `/etc/bind` 디렉토리에 DNS 설정 파일들이 생성됩니다. 이 중에서 `named.conf.local` 파일이 주요 설정 파일입니다.
3. `named.conf.local` 파일을 열어서, 자신의 도메인에 대한 존(zone) 정보를 추가해야 합니다. 예를 들면 다음과 같습니다:

```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
};

```

1. 추가한 존 정보에 맞는 DNS 레코드를 담고 있는 파일 (위 예에서는 `db.example.com`)을 생성하고, 필요한 레코드 정보를 입력합니다.
2. 모든 설정이 완료되면, bind9 서비스를 재시작합니다: `sudo service bind9 restart`

이 과정을 통해 DNS 서버가 구축됩니다. 그러나 실제 환경에서는 각 단계마다 보안 고려사항이 있으므로, 세부 설정에는 주의가 필요합니다.

- 실행 결과
![image-right](/assets/images/post/2024-12-09-network_make_dns/result.png){: .align-center}