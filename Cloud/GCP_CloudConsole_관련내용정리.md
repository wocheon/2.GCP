*로컬 PC에서 SSH를 통해서 GCP VM의 외부주소로 접속하는 방법 

[LOCAL PC ]
-cmd 혹은 powershell 에서 ssh 키를 생성할 위치로 이동
cd .ssh

-다음 명령어를 통해 ssh 키 생성 
ssh-keygen -t rsa -f .ssh/GCP_KEY -c [ GCP에서 접속중인 GMAIL 계정 ]
*옵션은 전부 엔터로 처리

[GCP]
- 생성된 키중 공개키(.pub) 를 GCP 메타데이터 > SSH키 혹은 VM 생성 후에 메타데이터에 입력 
- 방화벽 규칙에서 22포트 연결을 허용 (0.0.0.0/0 혹은 주소 범위를 지정)


*mobaxterm 접속 
session  > Advanced SSH settings의 Use Private Key 체크 
           개인키 파일 선택 후 접속 확인.

*putty 
puttygen 으로 개인키 파일 불러온뒤 save private key 로 ppk 파일 생성 (genrate아님)
만들어진 ppk 파일을 Connection > Auth > Credentials 에서 private key로 불러온뒤 접속확인.

[GCP 인스턴스 일정 적용시 권한 부여 방법]

IAM >  Google 제공 역할 부여 포함 체크 하여 모든 사용자 확인

Compute Engine Service Agent 에 Compute 인스턴스 관리자(v1) 역할을 추가 


인스턴스 일정 생성 후 인스턴스 추가하여 정상작동 확인.

[ 고정 외부 IP 관련 사항 ]
- 고정 외부 IP를 다른 리소스에 할당하지 않고 그대로 둔경우 비용이 많이 발생하므로 
  확인후에 할당 혹은 삭제 할것.


#*CentOS 7	
sudo -i << EOF
echo "root:welcome1" | /sbin/chpasswd
echo "wocheon07:welcome1" | /sbin/chpasswd
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config ; setenforce 0
systemctl disable firewalld --now
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
yum install -y git curl wget ansible bash-completion
echo "$(hostname -i) $(hostname)" >> /etc/hosts
EOF


#* Ubuntu
sudo -i << EOF
echo "root:welcome1" | /usr/sbin/chpasswd
echo "wocheon07:welcome1" | /usr/sbin/chpasswd
apt-get install -y git
EOF
