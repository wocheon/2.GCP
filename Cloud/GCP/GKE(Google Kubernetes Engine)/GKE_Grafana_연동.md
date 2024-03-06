[install helm ]
 curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
 chmod 755 get_helm.sh
 ./get_helm.sh

[ prometheus stack ]
helm repo add prometcd .heus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm pull prometheus-community/kube-prometheus-stack
tar xvf kube-prometheus-stack-56.21.1.tgz
cd kube-prometheus-stack/


cat prom-values.yml
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


kubectl create ns monitor
helm install prometheus prometheus-community/kube-prometheus-stack -f prom-values.yml -n monitor
helm list -n monitor




[nvida driver]
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml


[dcgm-exporter]
kubectl apply -f dcgm_exporter.yaml --namespace monitor
kubectl apply -f pod_monitoring.yaml --namespace monitor


kubectl label servicemonitors.monitoring.coreos.com dcgm-exporter release=prometheus -n monitor