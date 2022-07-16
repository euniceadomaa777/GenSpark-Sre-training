output "endpoint" {
  value = aws_eks_cluster.sre_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.sre_cluster.certificate_authority[0].data
}
