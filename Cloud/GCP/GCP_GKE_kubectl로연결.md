- 로컬 서버에서 kubectl 로 gke를 컨트롤 하는 방법


1. vm의 Cloud API 액세스 범위를 모든 Cloud API에 대한 전체 액세스 허용 으로 변경
    - 중지 후 변경하여 재부팅 필요

2. google-cloud-sdk 최신버전 설치
- https://cloud.google.com/sdk/docs/install?hl=ko#linux
```
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-461.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-461.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh
```

3. kubectl 설치
```
gcloud components install kubectl
kubectl version --client
```
4. gke 인증 플러그인 설치
```
gcloud components install gke-gcloud-auth-plugin
gke-gcloud-auth-plugin --version
```

4. kubectl 구성 업데이트 및 클러스터의 kubeconfig 컨텍스트를 생성
```
 gcloud container clusters list

gcloud container clusters get-credentials CLUSTER_NAME \
    --region=COMPUTE_REGION
```


5. docker 설치 
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce.x86_64
docker --version
systemctl enable docker --now


6. ngix 이미지 pull 하여 pod 생성하기
docker image pull nginx 

kubectl run my-app --image nginx --port=80

	
kubectl create deployment my-dep --image=nginx --port=80

kubectl scale deploy my-dep --replicas=2

kubectl expose deployment my-dep --type=NodePort

kubectl describe service my-dep 
