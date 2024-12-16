---
layout: single
title: "[기타] 맥북 한영키 right command로 설정하는법"
categories: 
 - Etc
date: 2024-12-16 08:34:00 +0900
---
오른쪽 alt키는 시스템키이기 때문에 별도의 설정이 불가능하다 따라서 right command키를 특정 키(f18)로 매핑을 진행하기 위한 별도의 방법을 사용해야 한다.

먼저 아래 명령어를 수행한다.

```jsx
mkdir -p /Users/Shared/bin
echo '''#!/bin/sh\nhidutil property --set '\'{\"UserKeyMapping\":\[\{\"HIDKeyboardModifierMappingSrc\":0x7000000e7,\"HIDKeyboardModifierMappingDst\":0x70000006d\}\]\}\''''' > /Users/Shared/bin/userkeymapping
chmod 755 /Users/Shared/bin/userkeymapping
sudo cat<<: >/Users/Shared/bin/userkeymapping.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>userkeymapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/Shared/bin/userkeymapping</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
:
sudo mv /Users/Shared/bin/userkeymapping.plist /Library/LaunchAgents/userkeymapping.plist
sudo chown root /Library/LaunchAgents/userkeymapping.plist
sudo launchctl load /Library/LaunchAgents/userkeymapping.plist
```

아래 사항을 차례대로 수행한다.

시스템>키보드>키보드단축키>입력소스>이전입력소스선택을 누른뒤

오른쪽 커맨드를 누르면 f18이 입력된다.

더이상 외부 프로그램(karabiner elements)를 사용하지 않아도 한영전환이 가능하다.

![image-right](/assets/images/post/2024-12-05-etc-mac-ko-en-key-change/settings.png){: .align-center}

![image-right](/assets/images/post/2024-12-05-etc-mac-ko-en-key-change/settings2.png){: .align-center}

### 비활성화 방법

```bash
sudo launchctl remove userkeymapping
sudo rm /Library/LaunchAgents/userkeymapping.plist
sudo rm /Users/Shared/bin/userkeymapping
```