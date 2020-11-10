# Use Terragrunt to create your first kubernetes cluster

In the cloudshell the bootstrap has installed `terragrunt` binary and also setup the environment variable so you are ready to run terragrunt. If you have lost your initial connection to the cloudshell (and your environment variables)

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce
source sourceme.sh
````

More information about terragrunt can be found at https://terragrunt.io.

## Create the first kubernetes cluster

This repo contains a description (or mapping table) of all resources on gce, it's prepared for you so you only have to run some commands to get a cluster up.

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce/europe-north1/dev/common/kubernetes
terragrunt apply 
```

The terragrunt apply command will show you what it intend to do, check the output and answer "yes" if it feels ok. After around 3-4 minutes you will have a kubernetes cluster up and running. 

You can now check it out in the Cloud console by going to https://console.cloud.google.com/kubernetes/list

Select the cluster and click connect to connect to the cluster, copy the command and run it in your cloudshell and check that you can connect to the cluster.

```bash
miklab4711@cloudshell:~/cloudshell_open/devops-live-infrastructure/gce/europe-north1/dev/common/kubernetes$ gcloud container clusters get-credentials gkeeurope-north1devcommonkubernetes --region europe-north1 --project pref1-miklab4711-tf-prsuf2
Fetching cluster endpoint and auth data.
kubeconfig entry generated for gkeeurope-north1devcommonkubernetes.
miklab4711@cloudshell:~/cloudshell_open/devops-live-infrastructure/gce/europe-north1/dev/common/kubernetes$ kubectl get nodes
NAME                                                  STATUS   ROLES    AGE   VERSION
gke-gkeeurope-north1devc-default-pool-4ef9e2aa-h1v6   Ready    <none>   64s   v1.16.13-gke.401
gke-gkeeurope-north1devc-default-pool-91a85f2f-4h0h   Ready    <none>   64s   v1.16.13-gke.401
gke-gkeeurope-north1devc-default-pool-a161d316-dkcq   Ready    <none>   64s   v1.16.13-gke.401
```