

도커 컴포즈 설치 ---------
1. curl  -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
2. chmod +x /usr/local/bin/docker-compose
3. docker-compose -v

yml 또는 yaml -> 야믈 파일 

- 도커 컴포즈는 야믈파일에 작성된 환경 내용을 읽어 해당 내용에서 원하는 대로 컨테이너, 컨테이너간 연결, 볼륨, 네트워크 등을 만들어 준다. 
- key: value 형태로 모든 내용을 작성한다
- 동일 환경을 다시 만들거나 이를 확장하거나 약간의 수정이 있을 경우 매우 편리하게 사용할 수 있다. 

------------------- 실습 docker-compose.yml 파일 ------------------------------
version: '3.1'

services:

  wordpress:
    image: wordpress    #base 이미지
    restart: always     #docker 데몬이 재부팅되더라도 항상 자동실행
    ports:
      - 8080:80         #호스트의 8080포트를 서비스의 80포트와 연결
    environment:        #-e옵션과 동일
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    volumes:
      - wordpress:/var/www/html #로컬에 wordpress라는 볼륨을 만들어 컨테이너의 /var/www/html에 붙임
    depends_on:
      - db                      #실행순서를 결정한다. (db가 먼저 실행되면 wordpress가 실행)
                                #(DB가 완전히 안정적으로 동작 뒤 실행하는 것은 아님, 그냥 실행순서만 결정)

  db:
    image: mysql:5.7        
    restart: always
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_ROOT_PASSWORD: test123
    volumes:
      - db:/var/lib/mysql    #db라는 볼륨을 만들어 붙임

volumes:
  wordpress:
  db:
  #둘사이의 연결은 링크가 필요없이 자동으로 연결된다.
------------------------------------------------------------------------
작성 완료후
docker-compose up -d

wordpress 와 mysql 컨테이너가 설치됨을 알수있음

*docker network/volume 확인
docker volume ls 
docker network ls

docker volume inspect 이름
docker network inspect 이름


-yml파일의 구분

1.버전지정 : docker compose의 버전 지정 
2.서비스 지정 : 컨테이너의 스펙 
3.볼륨 지정 컨테이너가 사용할 볼륨 지정 (옵션)
4.네트워크 지정 : 컨테이너 연결을위한 네트워크를 지정 (옵션)

줄 맞춤이 매우 중요하며
tab키 인식 불가능하므로 스페이스바를 이용해야한다.
일반적으로 2,4,6 혹은 3,6,9 단위로 띄워서 작성한다

도커 compe 파일 작성시 유의 사항
메인 작성사항
1.version 
2.services : 컨테이너 구성, 같은 기능을 하는 서비스끼리는 라인맞추기 중요 
옵션을 하나밖에 사용할수없는 경우에는 대쉬(-)를 사용하지않고
콜론다음에 한칸 띄워서 사용함 

환경변수 작성 방법은 두가지로 사용가능
1. WORDPRESS_DB_HOST: db
2. - WORDPRESS_DB_HOST=db

3.volume
4.networks
네트워크를 작성하지않으면 디폴트네트워크를 만들어줌
루트가 지정하지않고 실행하면  root_default 
user1이 지정하지않고 실행하면 user1_default 로 만들어짐
두 네트워크는 서로 독립적으로 존재한다.

만약 오버레이네트워크를 구성하는경우 꼭 명시해 주어야한다.


docker-compose ps : compose로 실행한 컨테이너를 확인 가능함 
(docker container ls 는 run + compose 모두 확인)

docker-compose stop : 정상 중지 시킴

docker-compose down : 강제 종료후 삭제 

docker-compose up -d --scale wordpress=3 --scale db=2
워드 프레스 3개 db2개 띄워라  > wordpress는 1개만 동작함 

yml파일에서 
ports:
      - 8080:80  를  8080-8088:80 으로 수정 (범위를 지정함)
      > 결국 전부 8080으로만 접속되게 된다. (볼륨에 처음 설치했던 설정이 남아있기때문임)

결국 여러대의 워드프레스 서버를 위해서는 자체 호스트 서버를 늘려야만 한다.
> 이를 자동으로 설정하는것이 auto-sclaing이다.


-클라우드(AWS)의 완전관리형 서비스
별도의 서버, 운영체제 과정없이 서비스 신청하면
즉시사용할수 있는 형태

OS서비스자원관리는  사용자관리가 아닌 공급자가처리 


docker compose파일에서 dockerfile을 사용하는방법
ex) 
services:
 webserver: 
    build: .

>docker build . 를 실행시킴     

클러스터링 : 클러스터를 구성하게되면 자원공유가 가능해진다.
일종의 풀에 자원을 넣고 공유하는 방식이다.
거리상 떨어져있어도 구성가능


[실습]-클러스터링 구성하기 
docker-compose down
systemctl restart Docker
docker system prune

init0 

풀클론으로 4개를 생성하기

docker01 manager manager01 211.183.3.100
docker02 worker worker01  211.183.3.101
docker03 worker worker02  211.183.3.102
docker04 worker worker03  211.183.3.103

모든 노드에는 아래의 내용을 /etc/hosts에 등록한다.

211.183.3.100 manager01
211.183.3.101 worker01 
211.183.3.102 worker02 
211.183.3.103 worker03 

모든 노드는 multi-user.target(CLI)로 부팅되도록 설정하고
SSH로 연결하기

apt-get install ssh; systemctl enable sshd ; systemctl set-default multi-user.tartget ; reboot

*manager 노드 : 클러스터 내부에서 작업을 주도하는 서버를 의미하며
클러스터 내부에 1대이상 존재해야한다.
기본적으로 worker의 기능을 겸업한다.

worker 노드 : manager의 작업지시를 받아서 이를 수행하는 서버

manager와 worker는 반드시 동일 네트워크상에 배치되어야하는 것은 아니며
물리적으로 떨어져있는 상태에서도 클러스터링이 가능하다.

manager를 하나만 사용하는 경우 만약 manager가 다운되면 작업지시가 불가능하므로
보통은 이중화를 통해 manager를 2대이상 배치한다.

user1@manager01:~$ docker swarm init --advertise-addr 211.183.3.100
Swarm initialized: current node (t53349nsr5c6ayljryesrlmdb) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4uttvii6wqyz5zosctj4scixq71lsdl3eqrgtwldeohprmr70h-1znj9tezgcbih8f6e47nf0m9x 211.183.3.100:2377 
#이줄을 복사해서 다른 노드에서 실행하기
To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

docker node ls > 노드간 연결상태 확인

docker service create --name web --replicas 4 -p 80:80 nginx
> 4개의 노드에서 각각 nginx 컨테이너로 접속하기

docker service ps web > swarm으로 실행된 컨테이너 확인

docker service rm web > swarm으로 실행된 컨테이너 모두 내리기

docker service create --name web --constraint 'node.role != manager'  --replicas 2 -p 80:80 nginx
> 매니저를 제외한 2개의 노드에서 ngix컨테이너를 배포시키기

*2개를 배포하여도 다른 곳에서 접근이 가능하다.
>클러스터를 구성하게되면 자동으로 오버레이 네트워크가 구성이된다.
그러므로 다른곳에서 접속이 가능해지는것임

docker service scale web=4
> 매니저에서는 배포하지않도록 설정했으므로 worker01에서 두개가 돌아감


docker node update --availability drain worker01
> 노드 하나를 중지시킴

docker service ps web로 확인해보면 3번에서 새로운 컨테이너를 만들어
동작시키고있는것을 확인 가능

docker service create --name web --constraint 'node.role != manager' --mode global -p 80:80 nginx
>매니저를 제외한 나머지 모든 노드에 공평하게 하나씩 컨테이너를 배포한다.













토큰 발행 이후 manager 를 2개로 늘리고 싶다면??
1. 첫번째 방법
user1@manager01:~$ docker swarm init --advertise-addr 211.183.3.100  <-- 토큰발행하고 이를 이용하여 워커들이 스웜 클러스터에 조인한다. 
Swarm initialized: current node (msfctow4b3bn44r6cc6ezqe1f) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5irkus71dikt64psicehk7s9llthtaik67a7g463eloknjro8z-akz0saaujn5a25i1m4s3q1mrh 211.183.3.100:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

user1@manager01:~$ docker swarm join-token manager    <--- 아래의 내용을 다른 노드에서 실행하면 매니저로 가입된다. 
To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5irkus71dikt64psicehk7s9llthtaik67a7g463eloknjro8z-3vny7i8bdldi2d51161ntd3j9 211.183.3.100:2377

user1@manager01:~$

2. 두번째 방법 
매니저에서 아래 내용을 실행한다.

docker node promote worker01 <-- worker01 을 worker 에서 manager 로 변경시킨다. 


#############컨테이너 배포 방법 정리#######################

docker container run 
각 컨테이너별 실행
두개이상 연결
동일 설정을 여러번해야하는 경우 부적함

docker-compose
yml파일에 필요한 서비스 네트워크 볼륨등을 작성하여
한번에 서비스를 배포한다.

모든 설정이 한대위에서만 구성된다.

docker-swarm cluster



----------------------------------------------------------------------------------
도커 클러스터가 구성되면 ingress네트워크가 새로 생성된다.
(docker network ls 로 확인이가능 )
NAME              DRIVER    SCOPE
ingress           overlay   swarm

롤링업데이트 : 동작중인 컨테이너의 이미지를 새로운이미지로 업데이트 시키는 것으로
서비스의 중단없이 신규 서비스를 배포할 수있다.

vim Dockerfile

FROM centos:7
RUN yum -y install httpd
ADD index.html /var/www/html
CMD /usr/sbin/httpd -D FOREGROUND

index.html에 vr1표시
docker build -t myweb:1.0 .
docker service create --name web --mode global --constraint 'node.role == worker' -p 80:                       80 nginx


index.html에 vr2표시
docker build -t myweb:2.0 .
docker service update --image myweb:2.0 myweb
docker service rollback myweb


-라벨을 추가하여 특정 노드에만 서비스 배포
docker node update --label-add srv=nginx worker01
docker node update --label-add srv=nginx worker02
docker node update --label-add os=centos worker02
docker node update --label-add os=centos worker03

docker service create --name nginx -p 8001:80 --constraint 'node.labels.srv == nginx' --replicas 2 nginx
docker service create --name httpd -p 8003:80 --constraint 'node.labels.os == centos' --replicas 2 httpd
> nginx : nginx 기본페이지 뜸  centos : itworks! 뜸 

docker service create --name nginx -p 8001:80 --constraint 'node.labels.srv == nginx' --replicas 2 nginx;
docker service create --name httpd -p 8003:80 --constraint 'node.labels.os == centos' --replicas 2 httpd


-docker hub에 이미지 올리기 
ubuntu에서 docker login입력후 로그인하기
docker push ciw0707/image:tag


-docker swarm 볼륨옵션 사용하기
docker service create --name nginx -p 80:80 --constraint 'node.role == worker' --replicas 2 --mount type=bind,source=/home/user1,target=/user/share/nginx/html nginx
> 모든 노드에 존재하는 디렉토리만 연결할수 있음

docker service create --name nginx -p 8001:80 --replicas 2 --mount type=volume,source=test,target=/root nginx

docker service create --name nginx2 -p 8001:80 --replicas 4 --mount type=volume,source=test,target=/root nginx
>각 서버별로 도커볼륨을 만들어 연결하기

>이러한 방법을 사용하면 각 컨테이너의 볼륨내의 정보가 동일하지않음
그러므로 외부에 있는 스토리지를 사용하여 nfs등으로 연결해준뒤 사용하는것이 추천됨


docker stack : docker swarm + docker-compose
서비스 제공환경을 yml파일에 작성하고 이를 클러스터(swarm)환경에 일괄적으로
배포할수 있다.



-----------------------------------------------------------
-82~83page 

docker network create --driver=overlay --attachable web 
>--attachable : docker container run으로 만들어진 컨테이너들도
오버레이네트워크에 속할수있음

/var/run/docker.sock > 

external : true > 껏다가 켜도 네트워크 정보를 유지하겠다.

centos 7 에 httpd 를 설치하고 웹페이지를 인터넷에서 받아서 사용하기
wget https://www.free-css.com/assets/files/free-css-templates/download/page266/radiance.zip
*add로 붙이는과정에서 디렉토리가 들어가버리는경우가 있으므로, unzip 하여 사용하기 

VMware networkmanager설정에서 nat네트워크의 port forwarding 설정하기
10.5.1.x:8080 > 211.183.3.100:80 >haproxy :80 > workers

-Dockerfile 작성
FROM centos:7
RUN yum install -y httpd
ADD ./radiance /var/www/html/
CMD /usr/sbin/httpd -D FOREGROUND
EXPOSE 80

docker build -t ciw0707/test:02 . 
>도커허브에 올리기위해 이름을 다음과 같이 작성해야함

docker login

docker push ciw0707/test:02

-다른노드들로 이동
도커허브에 이미지를 올린뒤 다른 노드에서 다운로드함
docker login 
docker pull ciw0707/test:02

yml파일 작성하기
vim web.yml
--------------------------------------------------
version: '3'

services:

  nginx:
    image: ciw0707/test:02
    deploy:
      replicas: 3
      placement:
        constraints: [node.role != manager]
      restart_policy:
        condition: on-failure
        max_attempts: 3
    environment:
      SERVICE_PORTS: 80
    networks:
      - web

  proxy:
    image: dockercloud/haproxy
    depends_on:
      - nginx
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80
    networks:
      - web
    deploy:
      mode: global
      placement:
        constraints: [node.role == manager]

networks:
  web:
    external: true
--------------------------------------------------------

docker stack deploy --compose-file=web.yml web

10.5.1.5:8080 혹은 211.183.3.100으로 접속하여 동작확인


yum install -y dialog
dialog --msgbox "hello all" 10 20
dialog --title "plz answer me" --yesno "doyou like me?" 10 20
echo $?

dialog --title "test" --inputbox "ur name?" 10 20 2>name.txt
cat name.txt



# apt-add-repository ppa:ansible/ansible
# apt-get update 
# apt-get install -y ansible

[centos의 경우]
yum -y update
yum -y install epel-release
yum -y install ansible

/etc/ansible/hosts 파일 가장아래에 
211.183.3.101
211.183.3.102
211.183.3.103 
을 등록한다

/etc/ssh/sshd_config에서
PremitRootLogin yes 으로 변경후
systemctl restart ssh
systemctl restart sshd

ansible all -m ping -k

ansible all -m user -a "name=user9" -k
ansible all -m shell -a "cat /etc/passwd | grep user9" -k
ansible all -m user -a "name=user9 state=absent" -k
ansible all -m shell -a "cat /etc/passwd | grep user9" -k



ansible all -m apt -a "name=git state=present" -k
 curl https://www.kbstar.com -o index.html




-visualizer yml파일
----------------------------------------------------------------
version: '3'

services:
  visual:
    image: dockersamples/visualizer
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      mode: global
      placement:
        constraints: [node.role == manager]
---------------------------------------------------------------

 docker stack deploy -c visual.yml visualizer
