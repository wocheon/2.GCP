# 1. 최신 버전 google-cloud-cli (google-cloud-sdk) 설치
```
[root@gcp-ansible-test ~]# curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-461.0.0-linux-x86_64.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  190M  100  190M    0     0  26.3M      0  0:00:07  0:00:07 --:--:-- 28.9M
[root@gcp-ansible-test ~]# tar -xf google-cloud-cli-461.0.0-linux-x86_64.tar.gz
[root@gcp-ansible-test ~]# ./google-cloud-sdk/install.sh
Welcome to the Google Cloud CLI!
WARNING: You appear to be running this script as root. This may cause
the installation to be inaccessible to users other than the root user.

To help improve the quality of this product, we collect anonymized usage data
and anonymized stacktraces when crashes are encountered; additional information
is available at <https://cloud.google.com/sdk/usage-statistics>. This data is
handled in accordance with our privacy policy
<https://cloud.google.com/terms/cloud-privacy-notice>. You may choose to opt in this
collection now (by choosing 'Y' at the below prompt), or at any time in the
future by running the following command:

    gcloud config set disable_usage_reporting false

Do you want to help improve the Google Cloud CLI (y/N)?  Y


Your current Google Cloud CLI version is: 461.0.0
The latest available version is: 467.0.0

┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                     Components                                                     │
├──────────────────┬──────────────────────────────────────────────────────┬──────────────────────────────┬───────────┤
│      Status      │                         Name                         │              ID              │    Size   │
├──────────────────┼──────────────────────────────────────────────────────┼──────────────────────────────┼───────────┤
│ Update Available │ Google Cloud CLI Core Libraries                      │ core                         │  22.8 MiB │
│ Not Installed    │ App Engine Go Extensions                             │ app-engine-go                │   4.7 MiB │
│ Not Installed    │ Appctl                                               │ appctl                       │  21.0 MiB │
│ Not Installed    │ Artifact Registry Go Module Package Helper           │ package-go-module            │   < 1 MiB │
│ Not Installed    │ Cloud Bigtable Command Line Tool                     │ cbt                          │  16.5 MiB │
│ Not Installed    │ Cloud Bigtable Emulator                              │ bigtable                     │   7.1 MiB │
│ Not Installed    │ Cloud Datastore Emulator                             │ cloud-datastore-emulator     │  36.2 MiB │
│ Not Installed    │ Cloud Firestore Emulator                             │ cloud-firestore-emulator     │  44.4 MiB │
│ Not Installed    │ Cloud Pub/Sub Emulator                               │ pubsub-emulator              │  63.3 MiB │
│ Not Installed    │ Cloud Run Proxy                                      │ cloud-run-proxy              │  13.3 MiB │
│ Not Installed    │ Cloud SQL Proxy                                      │ cloud_sql_proxy              │   7.8 MiB │
│ Not Installed    │ Cloud Spanner Emulator                               │ cloud-spanner-emulator       │  36.0 MiB │
│ Not Installed    │ Cloud Spanner Migration Tool                         │ harbourbridge                │  20.9 MiB │
│ Not Installed    │ Google Container Registry's Docker credential helper │ docker-credential-gcr        │   1.8 MiB │
│ Not Installed    │ Kustomize                                            │ kustomize                    │   4.3 MiB │
│ Not Installed    │ Log Streaming                                        │ log-streaming                │  13.9 MiB │
│ Not Installed    │ Minikube                                             │ minikube                     │  35.4 MiB │
│ Not Installed    │ Nomos CLI                                            │ nomos                        │  28.7 MiB │
│ Not Installed    │ On-Demand Scanning API extraction helper             │ local-extract                │  14.4 MiB │
│ Not Installed    │ Skaffold                                             │ skaffold                     │  23.4 MiB │
│ Not Installed    │ Spanner migration tool                               │ spanner-migration-tool       │  23.5 MiB │
│ Not Installed    │ Terraform Tools                                      │ terraform-tools              │  66.1 MiB │
│ Not Installed    │ anthos-auth                                          │ anthos-auth                  │  21.8 MiB │
│ Not Installed    │ config-connector                                     │ config-connector             │  56.7 MiB │
│ Not Installed    │ enterprise-certificate-proxy                         │ enterprise-certificate-proxy │   8.6 MiB │
│ Not Installed    │ gcloud Alpha Commands                                │ alpha                        │   < 1 MiB │
│ Not Installed    │ gcloud Beta Commands                                 │ beta                         │   < 1 MiB │
│ Not Installed    │ gcloud app Java Extensions                           │ app-engine-java              │ 125.9 MiB │
│ Not Installed    │ gcloud app Python Extensions                         │ app-engine-python            │   8.4 MiB │
│ Not Installed    │ gcloud app Python Extensions (Extra Libraries)       │ app-engine-python-extras     │  31.5 MiB │
│ Not Installed    │ gke-gcloud-auth-plugin                               │ gke-gcloud-auth-plugin       │   7.9 MiB │
│ Not Installed    │ kpt                                                  │ kpt                          │  14.4 MiB │
│ Not Installed    │ kubectl                                              │ kubectl                      │   < 1 MiB │
│ Not Installed    │ kubectl-oidc                                         │ kubectl-oidc                 │  21.8 MiB │
│ Not Installed    │ pkg                                                  │ pkg                          │           │
│ Installed        │ BigQuery Command Line Tool                           │ bq                           │   1.6 MiB │
│ Installed        │ Bundled Python 3.11                                  │ bundled-python3-unix         │  74.9 MiB │
│ Installed        │ Cloud Storage Command Line Tool                      │ gsutil                       │  11.3 MiB │
│ Installed        │ Google Cloud CRC32C Hash Tool                        │ gcloud-crc32c                │   1.2 MiB │
└──────────────────┴──────────────────────────────────────────────────────┴──────────────────────────────┴───────────┘
To install or remove components at your current SDK version [461.0.0], run:
  $ gcloud components install COMPONENT_ID
  $ gcloud components remove COMPONENT_ID

To update your SDK installation to the latest version [467.0.0], run:
  $ gcloud components update


Modify profile to update your $PATH and enable shell command completion?

Do you want to continue (Y/n)?  Y

The Google Cloud SDK installer will now prompt you to update an rc file to bring the Google Cloud CLIs into your environment.

Enter a path to an rc file to update, or leave blank to use [/root/.bashrc]:
Backing up [/root/.bashrc] to [/root/.bashrc.backup].
[/root/.bashrc] has been updated.

==> Start a new shell for the changes to take effect.


For more information on how to get started, please visit:
  https://cloud.google.com/sdk/docs/quickstarts


[root@gcp-ansible-test ~]#


```

# 3 kubectl 설치 

```
gcloud components install kubectl


Your current Google Cloud CLI version is: 461.0.0
Installing components from version: 461.0.0

┌─────────────────────────────────────────────┐
│     These components will be installed.     │
├────────────────────────┬─────────┬──────────┤
│          Name          │ Version │   Size   │
├────────────────────────┼─────────┼──────────┤
│ gke-gcloud-auth-plugin │   0.5.8 │  7.9 MiB │
│ kubectl                │  1.27.9 │  < 1 MiB │
│ kubectl                │  1.27.9 │ 99.9 MiB │
└────────────────────────┴─────────┴──────────┘

For the latest full release notes, please visit:
  https://cloud.google.com/sdk/release_notes

Do you want to continue (Y/n)?  Y

╔════════════════════════════════════════════════════════════╗
╠═ Creating update staging area                             ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: gke-gcloud-auth-plugin                       ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: gke-gcloud-auth-plugin                       ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: kubectl                                      ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: kubectl                                      ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Creating backup and activating new installation          ═╣
╚════════════════════════════════════════════════════════════╝

Performing post processing steps...done.

Update done!

WARNING:   There are other instances of Google Cloud tools on your system PATH.
  Please remove the following to avoid confusion or accidental invocation:

  /usr/lib64/google-cloud-sdk/bin/anthoscli
/usr/lib64/google-cloud-sdk/bin/bq
/usr/lib64/google-cloud-sdk/bin/git-credential-gcloud.sh
/usr/lib64/google-cloud-sdk/bin/docker-credential-gcloud
/usr/lib64/google-cloud-sdk/bin/gsutil
/usr/lib64/google-cloud-sdk/bin/gcloud


$ kubectl version --client
WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
Client Version: version.Info{Major:"1", Minor:"27+", GitVersion:"v1.27.9-dispatcher", GitCommit:"8b508a33aafcd3ba51641b6b2ef203adbdd9de1e", GitTreeState:"clean", BuildDate:"2023-12-21T23:22:51Z", GoVersion:"go1.20.12", Compiler:"gc", Platform:"linux/amd64"}
Kustomize Version: v5.0.1


```


# 3. gke-gcloud-auth-plugin 설치
```
 gcloud components install gke-gcloud-auth-plugin


gke-gcloud-auth-plugin --version
Kubernetes v1.28.2-alpha+58ec6ae34b7dcd9699b37986ccb12b3bbac88f00
```

# 4. kubectl 로 GKE와 연결
```
gcloud container clusters list
NAME       LOCATION         MASTER_VERSION      MASTER_IP      MACHINE_TYPE  NODE_VERSION        NUM_NODES  STATUS
cluster-1  asia-northeast3  1.27.8-gke.1067004  34.64.112.202  g1-small      1.27.8-gke.1067004             RUNNING

$ gcloud container clusters get-credentials cluster-1 --location=asia-northeast3
Fetching cluster endpoint and auth data.
kubeconfig entry generated for cluster-1.
```




## Centos7

### docker 공식 repo 추가 
```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### 설치가능한 도커 버전 확인
```bash
yum list docker-ce --showduplicates | sort -r
```

### docker 최신버전 설치 
```bash
yum install -y docker-ce.x86_64
```

### 버전확인 
```bash
$ docker --version

Docker version 24.0.5, build ced0996

$ systemctl enable docker --now
```



## test

>kubectl_test.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-test-nginx-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      color: black
  template:
    metadata:
      name: my-test-nginx
      labels:
        color: black
    spec:
      containers:
      - name: my-test-nginx-ctn
        image: nginx
        ports:
        - containerPort: 80
          protocol: TCP

---
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  ports:
    - name: webport
      port: 8080
      targetPort: 80
      nodePort: 30001
  selector:
    color: black
  type: NodePort


```

```
 kubectl apply -f kubectl_test.yaml

 kubectl get all
NAME                                        READY   STATUS    RESTARTS   AGE
pod/my-test-nginx-deploy-778c54b49f-rtfgq   1/1     Running   0          16s
pod/my-test-nginx-deploy-778c54b49f-sbzd5   1/1     Running   0          16s
pod/my-test-nginx-deploy-778c54b49f-vljnh   1/1     Running   0          16s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/kubernetes   ClusterIP   10.200.0.1     <none>        443/TCP          42h
service/my-svc       NodePort    10.200.6.236   <none>        8080:30001/TCP   16s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-test-nginx-deploy   3/3     3            3           16s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/my-test-nginx-deploy-778c54b49f   3         3         3       16s


kubectl describe service/my-svc
Name:                     my-svc
Namespace:                default
Labels:                   <none>
Annotations:              cloud.google.com/neg: {"ingress":true}
Selector:                 color=black
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.200.6.236
IPs:                      10.200.6.236
Port:                     webport  8080/TCP
TargetPort:               80/TCP
NodePort:                 webport  30001/TCP
Endpoints:                10.196.0.21:80,10.196.0.22:80,10.196.0.23:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
[root@kubectl-test wocheon07]# curl 10.196.0.21:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>


```