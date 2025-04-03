#!/bin/bash
echo "Configuring node..."
curl -o /etc/eks/bootstrap.sh https://amazon-eks.s3.us-east-1.amazonaws.com/${CLUSTER_NAME}/bootstrap.sh
chmod +x /etc/eks/bootstrap.sh
/etc/eks/bootstrap.sh ${CLUSTER_NAME} --kubelet-extra-args "--node-labels=node-type=worker"
