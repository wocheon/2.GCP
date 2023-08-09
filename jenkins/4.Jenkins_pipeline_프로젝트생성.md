# Jenkins - PIPELINE 프로젝트 생성

## Pipeline 생성
- NEW ITEM > Pipeline 로 추가 

## Pipeline script

* ### 현재 작업 위치 및 PIPELINE의 동작 확인
```ruby
pipeline {
  agent any
  stages {
      stage('execute ls command') {
        steps {
          echo 'execute ls command'
          sh 'ls -la'
        }
      }
      stage('Where do ls command execute?') {
        steps {
          echo 'Here is default.'
          sh 'ls -la'
          echo 'you can define where to execute command.'
          echo 'For example, I want to view root directory'
          sh 'ls -la /'
        }
      }
      stage('Is there any other way?') {
        steps {
          echo 'Maybe sh is independent'
          sh 'cd /'
          sh 'pwd'
          sh 'ls -la'
          echo 'If you want to execute multiple commands in one sh.'
          sh '''cd /
          pwd
          ls -la'''
        }
      }
    }
  }
```

  
* ### 각 Node별로 stage 진행 
```ruby
pipeline {
    agent{
        label 'master'
    }
  stages {
      stage('Master_Check') {
        steps {
          echo 'execute ls command'
          sh 'pwd; ls -la'
          sh 'hostname'
        }
      }
       stage('Slave_Check') {
       agent {
	    label 'master'
        }
        steps {
          echo 'execute ls command'
          sh 'pwd; ls -la'
          sh 'hostname'
        }
      }
    }
 }
```
