
source 0_source_config.sh

helm ls --all elasticsearch && helm del --purge elasticsearch

helm install stable/elasticsearch \
  --name ${RELEASE} \
  --set client.replicas=${MIN_REPLICAS} \
  --set master.replicas=${REPLICAS} \
  --set master.persistence.storageClass=my-local-storage-class \
  --set data.replicas=${MIN_REPLICAS} \
  --set data.persistence.storageClass=my-local-storage-class \
  --set master.podDisruptionBudget.minAvailable=${MIN_REPLICAS} \
  --set cluster.env.MINIMUM_MASTER_NODES=${MIN_REPLICAS} \
  --set cluster.env.RECOVER_AFTER_MASTER_NODES=${MIN_REPLICAS} \
  --set cluster.env.EXPECTED_MASTER_NODES=${MIN_REPLICAS} \
  --namespace elasticsearch 
