[ "$REPLICAS" == "" ] && REPLICAS=1
[ "$RELEASE" == "" ] && RELEASE=elasticsearch-v1

# get storageClassName of first available volume:
kubectl get pv | grep -v 'Available' && echo "WARNING: no persistent volume available!"
[ "$STORAGE_CLASS" == "" ] && STORAGE_CLASS=$(kubectl get pv $(kubectl get pv | grep 'Available' | head -n 1 | awk '{print $1}') -o yaml | grep '^[ ]*storageClassName' | head -n 1 | awk '{print $2}')

[ "$REPLICAS" == "1" ] && MIN_REPLICAS=1 || MIN_REPLICAS=2
