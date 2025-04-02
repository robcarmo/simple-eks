#!/bin/bash
/etc/eks/bootstrap.sh ${cluster_name} --kubelet-extra-args "--node-labels=node-type=worker"
