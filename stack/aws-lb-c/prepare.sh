#!/bin/bash

read -p "enter your aws account id: " aws_account_id
read -p "enter your eks cluster name: " eks_cluster_name

oidc_id=$(aws eks describe-cluster --name $eks_cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo "odic_id: $oidc_id"

eksctl utils associate-iam-oidc-provider --cluster $eks_cluster_name --approve

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=$eks_cluster_name \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$aws_account_id:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve