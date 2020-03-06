#!/bin/bash

MASTER_ADDRESS=$1
ETCD_SERVERS=$2

systemctl stop kube-apiserver
systemctl disable kube-apiserver

cat <<EOF >/opt/kubernetes/cfg/kube-apiserver

KUBE_APISERVER_OPTS="--logtostderr=false \\
--v=8 \\
--enable-aggregator-routing \\
--anonymous-auth=false \\
--audit-log-maxage=30 \\
--audit-log-maxbackup=3 \\
--audit-log-maxsize=100 \\
--audit-log-path=/opt/kubernetes/log/kube-audit.log \\
--audit-policy-file=/opt/kubernetes/cfg/audit-policy.yaml \\
--log-file=/opt/kubernetes/log/apiserver.log \\
--etcd-servers=${ETCD_SERVERS} \\
--etcd-cafile=/opt/etcd/ssl/ca.pem \\
--etcd-certfile=/opt/etcd/ssl/server.pem \\
--etcd-keyfile=/opt/etcd/ssl/server-key.pem \\
--service-cluster-ip-range=10.254.0.0/16 \\
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction \\
--bind-address=${MASTER_ADDRESS} \\
--secure-port=6443 \\
--client-ca-file=/opt/kubernetes/ssl/ca.pem \\
--token-auth-file=/opt/kubernetes/cfg/token.csv \\
--allow-privileged=true \\
--tls-cert-file=/opt/kubernetes/ssl/admin.pem  \\
--tls-private-key-file=/opt/kubernetes/ssl/admin-key.pem \\
--service-account-key-file=/opt/kubernetes/ssl/ca-key.pem \\
--advertise-address=${MASTER_ADDRESS} \\
--authorization-mode=RBAC,Node \\
--kubelet-https=true \\
--enable-bootstrap-token-auth \\
--kubelet-certificate-authority=/opt/kubernetes/ssl/ca.pem \\
--kubelet-client-key=/opt/kubernetes/ssl/admin-key.pem \\
--kubelet-client-certificate=/opt/kubernetes/ssl/admin.pem \\
--service-node-port-range=30000-50000"

EOF

cat <<EOF >/usr/lib/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-apiserver
ExecStart=/opt/kubernetes/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl restart kube-apiserver
