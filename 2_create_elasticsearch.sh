

CMD=$1
[ "$CMD" == "" ] && CMD=install

if [ "$CMD" != "install" ] && [ "$CMD" != "template" ] && [ "$CMD" != "delete" ] && [ "$CMD" != "del" ]; then
  echo "usage: bash $0 [install|template]"
  exit 1
fi 

source 0_source_config.sh

OPTIONS="--name ${RELEASE} \
      --set client.replicas=${MIN_REPLICAS} \
      --set master.replicas=${REPLICAS} \
      --set master.persistence.storageClass=${STORAGE_CLASS} \
      --set data.replicas=${MIN_REPLICAS} \
      --set master.podDisruptionBudget.minAvailable=${MIN_REPLICAS} \
      --set cluster.env.MINIMUM_MASTER_NODES=${MIN_REPLICAS} \
      --set cluster.env.RECOVER_AFTER_MASTER_NODES=${MIN_REPLICAS} \
      --set cluster.env.EXPECTED_MASTER_NODES=${MIN_REPLICAS} \
      --namespace elasticsearch"

[ "$STORAGE_CLASS" != "" ] && OPTIONS="$OPTIONS \
      --set data.persistence.storageClass=${STORAGE_CLASS}"

case $CMD in
  "delete"|"del")
    helm ls --all ${RELEASE} && helm del --purge ${RELEASE}
    bash 4_create_pvc_master.sh -d
    bash 3_create_pvc_data.sh -d
    ;;
  "install") 
    helm ls --all ${RELEASE} && helm del --purge ${RELEASE}
    bash 4_create_pvc_master.sh -d
    bash 3_create_pvc_data.sh -d
    helm $CMD stable/elasticsearch $OPTIONS
    ;;
  "template")
    helm $CMD ../charts/stable/elasticsearch $OPTIONS
    ;;
  *) echo "no clue - $CMD"; ;;
esac;
