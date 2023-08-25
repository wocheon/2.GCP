# GCP - Cloud Storage Mount (gcsfuse)
## gcsfuse 설치 
### 참조
- https://cloud.google.com/storage/docs/gcsfuse-mount?hl=ko

### Ubuntu 또는 Debian
*  Cloud Storage FUSE 배포URL 및 공개키 추가
```bash
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```
* Cloud Storage FUSE 설치
```bash
sudo apt-get update -y
sudo apt-get install -y gcsfuse
```

### CentOS 또는 RedHat
*  Cloud Storage FUSE repo 연결 및 공개키 추가
```bash
sudo tee /etc/yum.repos.d/gcsfuse.repo > /dev/null <<EOF
[gcsfuse]
name=gcsfuse (packages.cloud.google.com)
baseurl=https://packages.cloud.google.com/yum/repos/gcsfuse-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
      https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```

* Cloud Storage FUSE 설치
```bash
sudo yum install -y gcsfuse
```


## gcsfuse로 버킷 mount 

* 버킷 목록 확인 
```bash
$ gsutil ls

gs://gcp-in-ca-daisy-bkt-asia-northeast3/
gs://gcp-in-ca-test-bucket-wocheon07/
gs://gcp-in-ca-vm-image/
gs://gcp-in-ca.appspot.com/
gs://staging.gcp-in-ca.appspot.com/
```


* 버킷을 마운트할 디렉토리 생성

```bash
mkdir /GCP_Storage
```

* 버킷 마운트 

```bash
gcsfuse —file–mode=755 gcp-in-ca-test-bucket-wocheon07 /GCP_Storage
gcsfuse -o allow_other gcp-in-ca-test-bucket-wocheon07 /GCP_Storage

mount -t gcsfuse -o allow_other gcp-in-ca-test-bucket-wocheon07 /GCP_Storage
mount -t gcsfuse -o rw,user  gcp-in-ca-test-bucket-wocheon07 /GCP_Storage
```

### 권한 문제 발생 시
- 인스턴스 API 권한 문제로 인해 읽기만 가능하며 쓰기는 불가능 한 상태로 마운트 됨
- 변경방법 
    - 인스턴스 중지
    - 인스턴스 수정 
        - API 및 ID 관리 
            - 저장소 : 사용중지됨 > 전체로 변경
    - 인스턴스 재시작



## 마운트 해제 
```
fusermount -u /GCP_Storage
```


## 영구 마운트 진행 

- fuse.conf 파일 수정 

>vi /etc/fuse.conf 
```bash
# /etc/fuse.conf - Configuration file for Filesystem in Userspace (FUSE)
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#mount_max = 1000

# Allow non-root users to specify the allow_other or allow_root mount options.
user_allow_other
# user_allow_other 주석해제
```

- 최초 접속 계정의 uid , gid 확인

```
$ id wocheon07
uid=1003(wocheon07) gid=1004(wocheon07)
```

- /etc/fstab 수정

vi /etc/fstab
```
gcp-in-ca-test-bucket-wocheon07 /GCP_Storage gcsfuse rw,_netdev,allow_other,uid=1003,gid=1004
```

- 적용확인
```
mount -a
```