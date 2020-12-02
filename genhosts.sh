#!/usr/bin/bash -e

pushd terraform/vtt
HOST=$(terraform output foundry_ip)
SPACE=$(terraform output space_name)
REGION=$(terraform output space_region)
DOMAIN=$(terraform output domain)
popd

FILE=$(find . -name foundryvtt-*.zip -printf '%f')

echo "[foundry]"                      > hosts
echo $HOST                           >> hosts
echo ""                              >> hosts
echo "[foundry:vars]"                >> hosts
echo "domain=$DOMAIN"                >> hosts
echo "foundry_file=$FILE"            >> hosts
echo "foundry_backup_space=$SPACE"   >> hosts
echo "foundry_backup_region=$REGION" >> hosts
echo "foundry_backup_url=${REGION}.digitaloceanspaces.com" >> hosts
