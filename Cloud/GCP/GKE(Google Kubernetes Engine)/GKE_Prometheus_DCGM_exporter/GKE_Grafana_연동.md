# GKE - GPU 노드 모니터링 ( Grafana-DCGM_exporter )

## 작업 전 준비 사항
- GKE 클러스터 생성 
  - 리전 : asia-northeast3
  - 기본 노드영역 : asia-northeast3-b, asia-northeast3-c 
    - 둘중 하나만 선택해도 무방
    - 참고 : [GPU 리전 및 영역 가용](https://cloud.google.com/compute/docs/gpus/gpu-regions-zones?hl=ko)

- GKE 클러스터 - kubectl 연동 필요


## GKE gpu nodepool 추가 

### 생성 전 할당량 확인
- 프로젝트의 GPU	할당량이 0인경우 Nodepool 생성이 불가능하므로 다음 내용 확인
- 할당량이 부족한 경우 수정요청을 통해 1이상으로 변경
  - 승인요청 후 확인되면 다음 작업 진행

- 할당량 명칭
  - GPUs (all regions)	

### GPU 포함된 Nodepool 생성
  - nodepool 명 : gpu-pool-1
  - 노드영역 : asia-northeast3-c
  - 머신 유형: n1-standard-1
  - GPU :  NVIDIA T4 x 1
  - GPU 드라이버 설치 모드 : 사용자 관리형 설치

### nvida driver 설치 
- DaemonSet을 통해 GPU 드라이버 설치 진행 
  - 참고 : [NVIDIA GPU 드라이버 수동 설치](https://cloud.google.com/kubernetes-engine/docs/how-to/gpus?hl=ko#installing_drivers)

```bash
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml
```

## Grafana-Prometheus Stack 설치 

- helm을 통해 Grafana , Prometheus, 한번에 설치 진행

### helm
- Kubernetes 오픈소스 패키지매니저

- helm 구성요소
  
  - Chart
    - helm 리소스 패키지 
    - yum rpm파일, apt dpkg 파일 등과 비슷한개념으로 보면 됨
    
  - Repository 
    - Chart들을 모아두고 공유하는 저장소
  
  - Release
    - k8s 클러스터에서 구동되는 차트의 인스턴스 
    - 하나의 차트는 동일 클러스터내에 여러번 설치될수 있고, 설치할때마다 새로운 release 가 생성 
      - EX) 클러스터 내에 2대의 mysql 차트 설치 > 각각의 release name을 가지는 release 가 생성됨

### helm 설치 
- yum 기준
```bash
 curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
 chmod 755 get_helm.sh
 ./get_helm.sh
```

### k8s용 prometheus stack helm 차트 설치

- Prometheus 공식 helm repository 추가
```
helm repo add prometcd .heus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

- config 수정 후 올려야 하므로 Pull을 통해 차트 가져오기
```
helm pull prometheus-community/kube-prometheus-stack
tar xvf kube-prometheus-stack-56.21.1.tgz
cd kube-prometheus-stack/
```

- 추가 옵션 설정 
  - grafana 는 LoadBalancer를 통해 외부IP로 접근가능하도록 설정
  - pv를 생성하여 노드가 삭제되어도 내용이 지워지지 않도록 설정

>vi prom-values.yml
```
grafana:
  service:
    type: LoadBalancer

prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: standard
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
```

- 모니터링용 Namespace 생성
```
kubectl create ns monitor
```

- k8s용 prometheus stack helm 차트 설치

```bash
$ helm install prometheus prometheus-community/kube-prometheus-stack -f prom-values.yml -n monitor
NAME: prometheus
LAST DEPLOYED: Wed Mar  6 17:05:41 2024
NAMESPACE: monitor
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitor get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.


$ helm list -n monitor
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
prometheus      monitor         1               2024-03-06 17:05:41.812335341 +0900 KST deployed        kube-prometheus-stack-56.21.1   v0.71.2
```

### DCGM_Exporter 설치
- GPU 모니터링을 위한 NVIDIA Data Center GPU Manager(DCGM) 설치

```
kubectl apply -f dcgm_exporter.yaml --namespace monitor
kubectl apply -f pod_monitoring.yaml --namespace monitor
```

### DCGM_Exporter - Prometheus Stack 연동

- 두 방법중 하나의 방법을 사용하여 연동을 진행 
  - 연동이 안되면 매트릭 수집이 안됨

#### DCGM_Exporter에 label 추가 
- Prometheus Stack 과 별도로 설치되어 serviceMonitorSelector 가 설정되지 않아 매트릭이 수집되지 않는 문제 발생

- dcgm_exporter에 label을 추가
```
kubectl label servicemonitors.monitoring.coreos.com dcgm-exporter release=prometheus -n monitor
```

#### serviceMonitorSelectorNilUsesHelmValues를 false로 설정
- label을 확인해보면 helm으로 배포하면서 release 가 prometheus로 되어있는것을 확인 가능

```
 kubectl get servicemonitors.monitoring.coreos.com --show-labels --namespace monitor
```

- 다음 내용을 변경후 helm 재배포 진행


>vi prom-values.yml
```
grafana:
  service:
    type: LoadBalancer

prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false # 해당 구문을 추가
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: standard
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
```
