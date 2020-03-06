#!/bin/bash

systemctl stop kube-scheduler
systemctl disable kube-scheduler

cat <<EOF >/usr/lib/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler Plugin
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
 
[Service]
EnvironmentFile=-/opt/kubernetes/cfg/config
EnvironmentFile=-/opt/kubernetes/cfg/scheduler
User=kube
ExecStart=/opt/kubernetes/bin/kube-scheduler \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBE_MASTER \
            $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-scheduler
systemctl restart kube-scheduler
