
source 0_source_config.sh
SEQ_END=$( expr $REPLICAS - 1)

[ "$1" == "-d" ] && CMD=delete || CMD=apply

for i in $(seq 0 ${SEQ_END}); do
  kubectl get pvc data-${RELEASE}-data-${i} 2>/dev/null | grep Pending \
    && kubectl delete pvc data-${RELEASE}-data-${i}
  cat << EOF | kubectl $CMD -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: elasticsearch
    component: data
    release: ${RELEASE}
    role: data
  name: data-${RELEASE}-data-${i}
  namespace: elasticsearch
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: my-local-storage-class
  resources:
    requests:
      storage: 30Gi
  volumeMode: Filesystem
EOF
done

