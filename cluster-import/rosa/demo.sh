#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

ocm_api_token="$(cat ${DEMO_DIR}/ocmapi.token)"
rosa_cluster_name="$1"

if [ -z "${ocm_api_token}" ]; then
    echo "OCM API token is required"
    exit 1
fi

comment "ROSA clusters"
pe "rosa list clusters"

rosa_cluster_id=""
rosa_cluster_name=""

cat <<EOF > ${rosa_cluster_name}_rosa_cluster.yaml
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: ${rosa_cluster_name}
spec:
  hubAcceptsClient: true
EOF

comment "Create a managed cluster for ROSA cluster ${rosa_cluster_name}"
pe "oc apply -f ${rosa_cluster_name}_rosa_cluster.yaml"
pe "oc get managedclusters"

comment "Create an auto-import-secret in the managed cluster ${rosa_cluster_name} namespace"
comment "Go to https://console.redhat.com/openshift/token/rosa geting the token to access the https://api.openshift.com"
pe "oc create secret generic auto-import-secret -n ${rosa_cluster_name} --type='auto-import/rosa' --from-literal=cluster_id=${rosa_cluster_id} --from-file=api_token=ocmapi.token"

comment "Once the auto-import-secret is created, the import-controller will create a temporary cluster"
comment "admin user with htPasswdIDProvider for rosa cluster"
pe "rosa list idps -c ${rosa_cluster_id}"
pe "rosa list users -c ${rosa_cluster_id}"

comment "Wait a few minutes, the managed cluster ${rosa_cluster_name} will be imported automatically"
pe "oc get managedcluster ${rosa_cluster_name} -ojsonpath='{.status.conditions}'"
echo ""
pe "oc get managedcluster ${rosa_cluster_name} -w"

comment "After the managed cluster ${rosa_cluster_name} is imported, the temporary import user will be removed"
pe "rosa list idps -c ${rosa_cluster_id}"
pe "rosa list users -c ${rosa_cluster_id}"

