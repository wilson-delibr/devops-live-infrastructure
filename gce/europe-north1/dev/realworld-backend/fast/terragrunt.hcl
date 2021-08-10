# include is a block, so make sure NOT to include an equals sign
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git@github.com:mikab4711/devops-realworld-example-backend.git//terraform/backend?ref=7c0b5860d700b02e317c4a4cd8524a7768354b12"
}


dependency "kubernetes" {
  config_path = "../../common/kubernetes"
}

inputs = {
  kubernetes_host                   = dependency.kubernetes.outputs.endpoint
  kubernetes_client_key             = dependency.kubernetes.outputs.client_key
  kubernetes_client_certificate     = dependency.kubernetes.outputs.client_certificate
  kubernetes_cluster_ca_certificate = dependency.kubernetes.outputs.cluster_ca_certificate
  pod_scale                         = 1
  ext_database                      = false
}
