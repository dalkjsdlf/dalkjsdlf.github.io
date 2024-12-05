---
layout: single
title: "[기타] 파워쉘 꾸미기"
categories: 
 - Etc
date: 2024-12-05 11:30:00 +0900
---
2022.7.3 11:25 작성

파워쉘로 많은 일을 하지는 않지만(윈도우에서 커맨드를 사용할 일이 그닥 많지 않기 때문에) 종종 유용하게 사용할 때가 있다. 

Windows10 환경에서 도커를 설치하여 마리아디비를 세팅하는데 그 터미널 작업을 파워쉘에서 하게 되었다. 하지만 비주얼이 너무 별로여서(가독성도 많이 떨어진다...) 파워쉘을 좀 꾸밀 수 없을까 해서 여기저기 찾다가 알아낸 방법을 적어볼까 한다.

1\. 설치

```
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

Oh my posh : 파워쉘에서 테마적용하게 해주는 모듈

posh-git : git을 사용하지 않으면 굳이 설치하지 않아도 된다.

2.  설정

> notepad $PROFILE

위 명령어로 profile을 열면 아래와 같이 경고창이 뜨는데 '예' 선택하고 아래 내용을 입력해주면 된다.

![](https://blog.kakaocdn.net/dn/Q9009/btqZRrjAeqd/Xv866mr9ZW4wga3ezOgne1/img.png)

> Import-Module posh-git  
> Import-Module oh-my-posh  
> Set-PoshPrompt -Theme jandedobbeleer

저장 후 powershell을 끄고, 새로운 powershell을 관리자 모드로 열어준다.

대부분 아래와 같은 에러가 생길 것인데

이 시스템에서 스크립트를 실행할 수 없으므로 ~\\Documents\\WindowsPower  
Shell\\Microsoft.PowerShell\_profile.ps1 파일을 로드할 수 없습니다.

**. . .**

 + CategoryInfo          : 보안 오류: (:) \[\], PSSecurityException  
 + FullyQualifiedErrorId : UnauthorizedAccess

당황하지 말고 다음 명령어로 해결하자.

> Set-ExecutionPolicy RemoteSigned

규칙 변경하겠냐고 물어보면 당연히 y 를 눌러 진행한다.

> 끝! 확인해보자 내 예쁜 터미널을!

## Windows Terminal 접속

jandedobbeleer 테마가 적용 된 모습!

![](https://blog.kakaocdn.net/dn/dzVcre/btqZMninw8o/doHwXd7j0L6G9M90SSAnPk/img.png)

다른 여러 테마들은 요기서 확인 👉🏻 [oh my Posh: Themes](https://ohmyposh.dev/docs/themes)

하거나! 명령어로 직접 터미널에서 바로 볼 수도 있다!

> Get-PoshThemes

테마 이름과 적용 모습이 순서대로 나온다!여기서 예쁘다고 생각하는 테마의 이름을 .omp 를 떼어내고 아까 수정했던 $PROFILE에 Set-PoshPrompt -Theme 옵션을 수정하면 된다!

![](https://blog.kakaocdn.net/dn/cGthPJ/btqZLtiSQn5/Zn0JSO6A9haeYDDKfLFe9K/img.png)

특정 폰트들은 깨져서 왠 네모블럭이 나타나곤 하는데 이땐 당황하지말고 지원하는 폰트로 바꿔주면된다.

출처: [https://proni.tistory.com/entry/PowerShell-테마로-예쁘게-쓰기-with-Windows-Terminal](https://proni.tistory.com/entry/PowerShell-테마로-예쁘게-쓰기-with-Windows-Terminal) \[Programmer Leni 🤪:티스토리\]