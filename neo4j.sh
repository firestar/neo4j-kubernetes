#!/usr/bin/env bash

set -exuo pipefail

# Clean up anything from a prior run:
kubectl delete statefulsets,pods,persistentvolumes,persistentvolumeclaims,services -l app=neo4j

# Make persistent volumes and (correctly named) claims. We must create the
# claims here manually even though that sounds counter-intuitive. For details
# see https://github.com/kubernetes/contrib/pull/1295#issuecomment-230180894.
for i in $(seq 0 $1); do
  cat <<EOF | kubectl create -f -
kind: PersistentVolume
apiVersion: v1
metadata:
  namespace: $2
  name: pv${i}
  labels:
    type: local
    app: neo4j
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/${i}"
EOF

  cat <<EOF | kubectl create -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  namespace: $2
  name: datadir-neo4j-core-${i}
  labels:
    app: neo4j
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
done;

# kubectl create -f neo4j.yaml
