[ GCP K8S 설치 ] 

-master
리전 : asia-northeast3-a
출시버전 : 20.04 LTS
OS 이미지 : ubuntu
E2-medium
부팅디스크 크기 : 10G

-worker 1 ,2
리전 : asia-northeast3-a
출시버전 : 20.04 LTS
OS 이미지 : ubuntu
E2-small
부팅디스크 크기 : 10G

*SSH 접속 
-LOCAL CMD에서 SSH 키 생성
ssh-keygen -t rsa -f ~/.ssh/[KEY_FILENAME] -C [USERNAME]

-GCP의 메타데이터 > SSH 부분에 공개키 값을 입력 

-mobaXterm 접속시 Advanced SSH setting 에서 Use private key 체크 , 생성된 개인키 파일 선택 

-Remote Host : 외부 IP / port : 22로 접속 


[기본세팅]
-패키지 업데이트
apt update -y && apt upgrade -y

-SWAP 메모리 해제
(각 노드에서 kubelet이라는 컴포넌트가 제대로 동작하기 위해 리눅스의 SWAP 메모리 기능을 해제.)
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab ; swapoff -a ; cat /etc/fstab

[DOCKER 설치]
1.  도커 설치에 필요한 패키지 다운로드
sudo apt-get update

sudo apt-get install ca-certificates curl gnupg lsb-release
	

2. 도커 공식 GPG key 등록	
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

3. 도커 Repository 설정
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  
4. 도커 설치
 sudo apt-get update ; sudo apt-get install docker-ce docker-ce-cli containerd.io  
 
 
 5. 도커 cgroup driver 설정
도커가 설치 후, 도커가 사용하는 드라이버를 쿠버네티스가 권장하는 systemd로 설정.
(자세한 내용은 아래 링크를 참고)
 https://kubernetes.io/ko/docs/setup/production-environment/container-runtimes/
 
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

6. 도커 재시작 및 부팅시 시작 설정
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker


7. Container.d 런타임에 대해서 CRI 비활성화 해제 ('23.01 추가)
오랜만에 재설치를 해보려고 하니 k8s 버전도 올라가면서 수정된 사항이 있어서 추가 기술합니다.
위에서 Docker 를 설치하고 실질적으로 container.d 를 런타임으로 사용하는데, 기본적으로 CRI가 비활성화 되어 있습니다.
k8s에서 CRI를 사용할 수 있게 아래와 같은 처리가 필요합니다. (Master, Worker Node 모두)
편집기를 통해 아래 파일을 열어줍니다.

 vi /etc/containerd/config.toml
 ->
 disabled_plugins = ["cri"]  주석처리 후 저장
 
systemctl restart containerd
 
 
 
-방화벽 및 네트워크 환경설정
(중요) 아래 작업은 VM 4개 모두 공통으로 각각 진행해줍니다.
추후 쿠버네티스 환경에서 서로 노드간의 CNI를 통해서 통신을 하게 될 예정인데,
그 전에 필요한 네트워크 및 방화벽 환경 설정을 진행합니다. 
modprobe overlay
modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF


-kubeadm, kubelet, kubectl 설치하기
*참고 
kubeadm: 클러스터를 부트스트랩하는 명령이다.
kubelet: 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트이다.
kubectl: 클러스터와 통신하기 위한 커맨드 라인 유틸리티이다.


1.패키지 업데이트 및 설치 시 필요한 패키지 다운로드
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl


2.구글 클라우드의 공개 사이닝 키 다운로드
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -


3.쿠버네티스 Reposiotry 추가
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

4.kubelet, kubeadm, kubectl 설치
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl



kubeadm init 으로 클러스터 초기화하기
이 과정은 "마스터 노드" 역할을 수행하는 VM에서만 진행합니다.
아래 명령어를 master node(의 역할을 하는 VM)와 연결되어 있는 터미널 창에 입력합니다.
vi /etc/hosts
10.178.0.14	master
10.178.0.15	worker1



kubeadm init --apiserver-advertise-address 10.178.0.14 --pod-network-cidr=192.168.0.0/16
->CNI로 calico를 사용하려면 pod-network-cidr 는 192.168.0.0/16 로 고정

##########################################################################
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube;sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;sudo chown $(id -u):$(id -g) $HOME/.kube/config;export KUBECONFIG=/etc/kubernetes/admin.conf

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.178.0.14:6443 --token 8lszl8.29tcsnpsxl1n8ex5 \
        --discovery-token-ca-cert-hash sha256:b5ea4609103a0f476b0e55e30c341b7fb913dfd1679fab1e8e4d67bec193a56c
##########################################################################


-Pod network add-on (CNI) 설치하기
구성한 클러스터 내에 CNI (Container Network Interface)를 설치하여, Pod들이 서로 통신이 가능하도록 해줘야 합니다.

-master Node에서 실행
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml

vim calico-resources.yaml
##################################################################
# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---

# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer 
metadata: 
  name: default 
spec: {}
##################################################################


$ sudo firewall-cmd --add-port=179/tcp --permanent
$ sudo firewall-cmd --add-port=4789/udp --permanent
$ sudo firewall-cmd --add-port=5473/tcp --permanent
$ sudo firewall-cmd --add-port=443/tcp --permanent
$ sudo firewall-cmd --add-port=6443/tcp --permanent
$ sudo firewall-cmd --add-port=2379/tcp --permanent
$ sudo firewall-cmd --reload
 

#kubectl 자동완성 설정 
 sudo yum install bash-completion -y
source /usr/share/bash-completion/bash_completion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source /usr/share/bash-completion/bash_completion
# 터미널 다시 접속
