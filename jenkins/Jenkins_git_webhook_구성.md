# Jenkins - git webhook 구성하기

## Git Webhook
* 사용자가 git push 실행
	- webhook(일종의 트리거역할)을 통해 자동으로 빌드 진행 
	`slave의 workspace/프로젝트명 디렉토리에 clone됨.`

## github token 발급 
* github 계정아이콘 클릭 후
	- settings > Developer Settings >Personal access tokens (classic)
		-  generate new token > generate new token(classic)
						
- 체크 항목 : repo, admin:org, admin:repo_hook
	
- generate 후 표기되는 token을 복사 <br>
$\textcolor{orange}{\textsf{ * 한번 생성하면 이후에 다시 나오지않으므로 복사해둘것 }}$ 
	

## github webhook 설정 
- 사용할 repository를 선택 후, settings > webhooks > add webhook 으로 이동 
	- Payload URL : http://[jenkins주소]/github-webhook/
	- Content type : application/json

### github 토큰을 jenkins credential 으로 등록 
- Jenkins 관리 > Credentials > System <br>
	- \> Global credentials (unrestricted) > Add credentials 
	
	* Credential option
		- Scope : global 
		- username : github id 입력 
		- password : github token 입력
		- ID : credential 명칭 입력 
<br>
	
## webhook 동작 테스트 진행
* New item > pipiline
		
* option
	- General : GitHub project 체크, Project url에 repository 주소 복사 
	- Build Triggers : GitHub hook trigger for GITScm polling
	
	- script 
```phython
pipeline {
	agent {
		label 'slave'    
	}
	stages {
		stage('Check Path') {
			steps {
				sh '''hostname 
					  hostname -i 
					  pwd'''
			}
		}
		stage('Checkout') {
			steps {
				git branch: 'master',
					credentialsId: 'github_token',
					url: 'https://github.com/wocheon/docker_images.git'
			}
		}
		stage('Deploy') {
			steps {
				sh '''cp -f index.html /var/www/html/index.html
					curl localhost
				   '''
			}
		}
	}
}
```


- 생성 완료 후 수동으로 빌드 시 문제없는지 확인.
	
- 웹상에서 commit 생성 후 빌드가 진행되는지 확인.
- local에서 push 후에도 정상적으로 빌드 되는지 확인.
