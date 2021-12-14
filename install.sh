#!/usr/bin/env bash

echo "This script will install Prometheus and Grafana to your K8s cluster, and configure access to them using corresponding prefixes. Also, this script will add Prometheus server as a default data source in Grafana and add some dashboards to the installed Grafana"
cluster_url=""; while [ -z $cluster_url ]; do read -p "Enter your cluster URL (will be used in Grafana configuraton):" cluster_url; done
echo "Adding Helm repos"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo "Installing Prometheus"
helm install --wait --namespace monitoring --create-namespace  --set server.prefixURL=/prometheus --set server.baseURL=/prometheus prometheus prometheus-community/prometheus -f prometheus-values.yaml
echo "Installing Grafana"
rm -f grafana-*.tgz || continue
helm fetch grafana/grafana && tar xf grafana-*.tgz
rm -f grafana-*.tgz || continue
helm install --wait --namespace monitoring grafana grafana/. --set 'grafana\.ini'.server.root_url=${cluster_url}grafana -f grafana-values.yaml
grafana_secret=$(kubectl get secret --namespace monitoring grafana -o jsonpath='{.data.admin-password}' | base64 --decode ; echo)
kubectl create secret generic prometheus --from-literal=auth="admin:$(openssl passwd -apr1 ${grafana_secret})" --namespace=monitoring
echo "Adding ingresses"
kubectl apply -f grafana-ingress.yaml
kubectl apply -f alert-ingress.yaml
kubectl apply -f prometheus-ingress.yaml
clear
echo "Congratulations! Grafana and Prometheus were installed in your K8s cluster"
echo "Grafana link: ${cluster_url}grafana"
echo "Prometheus link: ${cluster_url}prometheus"
echo "Admin login for Grafana and Prometheus: admin"
echo "Admin password for Grafana and Prometheus: ${grafana_secret}"

