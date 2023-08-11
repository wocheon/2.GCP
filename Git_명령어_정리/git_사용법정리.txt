*GIT BASH 명령어 및 사용법 정리

-git repository에 파일 업로드 방법

1.git repository 생성

2.git bash에서 cd로 해당 디렉토리로 이동

3.로컬 repository 생성 
git init 
*이름 및 이메일 설정 ( github 정보와 동일하게 )
git config - -global user.name “Your name”
git config - -global user.email “Your email address”
git config - -global - -list


4.github repository (외부저장소) 연결 
git remote add origin [git_repositroy_주소]

5. branch 지정 
git branch main

5.연결 확인 
git remote -v 
git status
git log 

6. git add 및 commit 진행 

git add . 
=> 현재 위치에 있는 파일 전부 추가

git commit -m "upload"

7. push 
git push origin master

-원격저장소 연결 해제 
git remote remove origin

-git init 해제 
ls -la 로 .git 폴더 확인 후 rm -rf .git 

-이전 commit 내용 삭제
git rebase -i {제거하려고 하는 커밋의 직전 커밋 id}

-원격저장소 복제 
git clone <저장소 url>

-git clone 해제
git remote remove origin
or 
.git 디렉토리 삭제

-branch 변경 
git checkout [브랜치명]


-branch간 변경내역 merge 진행
1. master
2. main 

main에서 파일 변경 > add > commit  > git push orgin main
checkout으로 master 브랜치로 변경 > git merge main > add > commit > git push origin master


$ git log --branches --oneline


* git 로그인 정보 저장 방법
git config --global user.email "ciw0707@naver.com"
git config --global user.name "wocheon"
git config --global user.password "[devleoper > personal access token]"
git config credential.helper store --global
