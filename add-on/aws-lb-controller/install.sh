#!/bin/bash

read -p "What is your AWS_ACCOUNT? " AWS_ACCOUNT 
read -p "What is your EKS CLUSTER_NAME? " CLUSTER_NAME 

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole_$CLUSTER_NAME \
    --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller 

kubectl get deployment -n kube-system aws-load-balancer-controller


## Uninstall
# helm uninstall aws-load-balancer-controller -n kube-system
# eksctl delete iamserviceaccount --cluster $CLUSTER_NAME --name aws-load-balancer-controller
