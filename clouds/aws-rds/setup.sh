#!/usr/bin/env bash

PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
CERTS_DIR=$PWD/certs

mkdir -p ${CERTS_DIR}

vpc=""
region=""
db_pw=""

echo "vpc: $vpc"
echo "region: $region"

# Download db public ca
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.CertificatesAllRegions
curl -o ${CERTS_DIR}/ca.pem "https://truststore.pki.rds.amazonaws.com/${region}/${region}-bundle.pem"

# Allow db connection in the default security group
sg=$(aws ec2 get-security-groups-for-vpc --vpc-id ${vpc} --region ${region} --query "SecurityGroupForVpcs[?GroupName=='default'].GroupId" | jq -r '.[0]')
result=$(aws ec2 authorize-security-group-ingress --group-id ${sg} --protocol tcp --port 5432 --cidr 0.0.0.0/0 | jq -r '.Return')
echo "Add inbound rule for postgrep db in ${sg} (${result})"

# Prepare db subnet group
# aws rds delete-db-subnet-group --db-subnet-group-name maestrosubnetgroup
all_subnets=""
for subnet in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc}" | jq -r '.Subnets[].SubnetId'); do
    all_subnets="$all_subnets,\"$subnet\""
done

db_subnet_group=$(aws rds create-db-subnet-group \
    --db-subnet-group-name maestrosubnetgroup \
    --db-subnet-group-description "Maestro DB subnet group" \
    --subnet-ids "[${all_subnets:1}]" | jq -r '.DBSubnetGroup.DBSubnetGroupName')
echo "DB subnet group ${db_subnet_group} is created"

# Create db
db_id=$(aws rds create-db-instance \
    --engine postgres \
    --engine-version 14.10 \
    --allocated-storage 20 \
    --db-instance-class db.t4g.large \
    --db-subnet-group-name ${db_subnet_group} \
    --db-instance-identifier maestro \
    --db-name maestro \
    --master-username maestro \
    --master-user-password "${db_pw}" | jq -r '.DBInstance.DBInstanceIdentifier')

i=1
while [ $i -le 20 ]
do
    db_status=$(aws rds describe-db-instances --db-instance-identifier ${db_id} | jq -r '.DBInstances[0].DBInstanceStatus')
    echo "DB status: ${db_status}"
    if [[ "$db_status" == "available" ]]; then
        break
    fi
    i=$((i + 1))
    sleep 30
done

db_host=$(aws rds describe-db-instances --db-instance-identifier ${db_id} | jq -r '.DBInstances[0].Endpoint.Address')
echo "DB ${db_id} (${db_host}) is created"

# Prepare db configurations
kubectl -n maestro delete secret maestro-db --ignore-not-found
kubectl -n maestro create secret generic maestro-db \
    --from-literal=db.name=maestro \
    --from-literal=db.host=${db_host} \
    --from-literal=db.port=5432 \
    --from-literal=db.user=maestro \
    --from-literal=db.password="${db_pw}" \
    --from-file=db.ca_cert="${CERTS_DIR}/ca.pem"
