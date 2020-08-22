#!/bin/sh

HPA_OBJECT=$(kubectl get hpa -A)
HPA_COUNT=$(echo $HPA_OBJECT | grep -c 'apache')

if [ "$HPA_COUNT" -eq "1" ]
then 
  echo 'done'
fi
