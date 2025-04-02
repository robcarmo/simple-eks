#!/bin/bash
set -e

# Configure kubelet
/etc/eks/bootstrap.sh ${cluster_name}
