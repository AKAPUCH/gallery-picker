## 프로젝트 번호 : 프로젝트 이름

간략한 설명

이 앱의 레퍼런스는 [soapyigu의 Swift-30-Projects](https://github.com/soapyigu/Swift-30-Projects)입니다.

기본 기능을 모두 구현했다면, 디자인 및 추가 기능 구현은 자유롭게 해주세요.

## 가이드

영상 가이드는 [코드스쿼드 pr연습](https://www.youtube.com/watch?v=lFinZfu3QO0)을 참조해주세요.

1. 본인 이름으로 브랜치(ex: PAKA)를 생성한 후, 자신의 레포로 fork해주세요.

2. fork 한 레포에서 기능 또는 화면 단위로 새 브랜치(ex: pr1)를 생성 후 작업 및 커밋합니다. 

3. 커밋했던 브랜치(pr1)에서 자신의 이름 브랜치(PAKA)로 PR을 올려주세요.

4. 코드 리뷰를 받고 모든 수정사항을 반영한 후 `squash and merge` 옵션으로 자신의 브랜치에 merge해주세요.

5. merge했던 브랜치(pr1)에서 fork한 레포의 main 브랜치로 checkout후 해당 브랜치(pr1)를 삭제합니다.

6. 다음 명령어들을 순차적으로 실행합니다.

```
    git remote add upstream https://github.com/Swift-Master/Project1-GoodAsOldPhones
    
    git fetch upstream `본인의 브랜치명(ex:PAKA)`
    
    git rebase upstream `upstream/본인의브랜치명(ex:PAKA)`
```

7. 2번으로 돌아가 새로운 작업을 반복합니다.

## 실제 화면
![시뮬레이터화면](./이미지이름.gif)
