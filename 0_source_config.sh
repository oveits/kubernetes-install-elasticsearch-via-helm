REPLICAS=1
RELEASE=elasticsearch

[ "$REPLICAS" == "1" ] && MIN_REPLICAS=1 || MIN_REPLICAS=2