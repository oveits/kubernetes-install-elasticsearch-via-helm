

CMD=$1
[ "$CMD" == "" ] && CMD=install

if [ "$CMD" != "install" ] \
  && [ "$CMD" != "template" ] \
  && [ "$CMD" != "delete" ] \
  && [ "$CMD" != "del" ] \
  && [ "$CMD" != "upgrade" ] \
  && [ "$CMD" != "rollback" ] \
  && [ "$CMD" != "history" ] 
then
  echo "usage: bash $0 [install|template|delete|upgrade|rollback|history]"
  exit 1
fi 

source 0_source_config.sh

OPTIONS="--set client.replicas=${MIN_REPLICAS} \
      --set master.replicas=${REPLICAS} \
      --set master.persistence.storageClass=${STORAGE_CLASS} \
      --set data.replicas=${MIN_REPLICAS} \
      --set master.podDisruptionBudget.minAvailable=${MIN_REPLICAS} \
      --set cluster.env.MINIMUM_MASTER_NODES=${MIN_REPLICAS} \
      --set cluster.env.RECOVER_AFTER_MASTER_NODES=${MIN_REPLICAS} \
      --set cluster.env.EXPECTED_MASTER_NODES=${MIN_REPLICAS} \
      --set client.ingress.enabled=true \
      --set client.ingress.hosts[0]=${FQDN} \
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
    helm $CMD stable/elasticsearch --name ${RELEASE} $OPTIONS
    ;;
  "upgrade")
    helm $CMD ${RELEASE} stable/elasticsearch $OPTIONS
    ;;
  "history")
    helm $CMD ${RELEASE}
    ;;
  "rollback")
    helm $CMD ${RELEASE}
    ;;
  "template")
    helm $CMD ../charts/stable/elasticsearch $OPTIONS
    ;;
  *) echo "no clue - $CMD"; ;;
esac;
