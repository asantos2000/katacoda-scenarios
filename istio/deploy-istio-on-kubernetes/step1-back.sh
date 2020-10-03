#!/bin/bash
until kubectl cluster-info | grep -m 1 "is running at"; do :; done
echo "done" >> /root/k8s-background-finished
