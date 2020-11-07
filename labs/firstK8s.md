# Use Terragrunt to create your first kubernetes cluster

In the cloudshell the bootstrap has installed `terragrunt` binary and also setup the environment variable so you are ready to run terragrunt. If you have lost your initial connection to the cloudshell (and your environment variables)

```
cd ...
source 
````

More information about terragrunt can be found at https://terragrunt.io.

## Create the first kubernetes cluster

This repo contains a description (or mapping table) of all resources on gce, it's prepared for you so you only have to run some commands to get a cluster up.

```
cd gce/europe-north1/dev/common/kubernetes
terragrunt apply 
```

The terragrunt apply command will show you what it intend to do, check the output and answer "yes" if it feels ok. After around 3-4 minutes you will have a kubernetes cluster up and running. 

You can now check it out in the Cloud console by going to https://console.cloud.google.com/kubernetes/list

Select the cluster and click connect to connect to the cluster, copy the command and run it in your cloudshell and check that you can connect to the cluster.

```
$ gcloud container clusters get-credentials gkeeurope-north1prodcommonkubernetes --region europe-north1 --project prepedu-mikael-tf-pr1
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gkeeurope-north1prodcommonkubernetes.
$ kubectl get nodes
NAME                                                  STATUS   ROLES    AGE     VERSION
gke-gkeeurope-north1prod-default-pool-00743fed-4djf   Ready    <none>   3h20m   v1.16.13-gke.401
gke-gkeeurope-north1prod-default-pool-b203d9c7-6tf1   Ready    <none>   3h20m   v1.16.13-gke.401
gke-gkeeurope-north1prod-default-pool-ea3ebcd2-w122   Ready    <none>   3h20m   v1.16.13-gke.401
$
```