#!/bin/bash
until kubectl cluster-info | grep -m 1 "is running at"; do :; done
#while ! kubectl wait --for=condition=available --timeout=600s deployment/coredns -n kube-system; do sleep 1; done
echo "there" >> /root/hello
