
source 0_source_config.sh

SEQ_END=$( expr $REPLICAS - 1)

[ "$1" == "-d" ] && CMD=delete || CMD=apply

for i in $(seq 0 ${SEQ_END}); do
  kubectl get pvc data-${RELEASE}-master-${i} 2>/dev/null | grep Pending \
    && kubectl delete pvc data-${RELEASE}-master-${i} 
  cat << EOF | kubectl $CMD -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: elasticsearch
    component: master
    release: ${RELEASE}
    role: master
  name: data-${RELEASE}-master-${i}
  namespace: elasticsearch
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ${STORAGE_CLASS}
  resources:
    requests:
      storage: 4Gi
  volumeMode: Filesystem
EOF
done
