[install helm ]
 curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
 chmod 755 get_helm.sh
 ./get_helm.sh

[ prometheus stack ]
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


cat prom-values.yml
```
grafana:
  service:
    type: LoadBalancer
```


kubectl create ns monitor
helm install prometheus prometheus-community/kube-prometheus-stack -f prom-values.yml -n monitor
helm list -n monitor


[dcgm-exporter]
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm repo update