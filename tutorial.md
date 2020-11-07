# Devops Lab Tutorial

## Let's get started

Sample project inspired from 
* https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d https://github.com/gruntwork-io/terragrunt-infrastructure-live-example 
* https://medium.com/@kief/https-medium-com-kief-using-pipelines-to-manage-environments-with-infrastructure-as-code-b37285a1cbf5

and used in devops education labs.

Instructions are in the MD files in labs, intended to be run from a "Google Cloudshell".

## Signup for Google Cloud

### Create a Google Account
First, register a new account at google with your own email https://accounts.google.com/SignUpWithoutGmail

### Create a Google Cloud  account
Go to: https://cloud.google.com/compute/docs/signup and click on "Try it free" to create a new GCE account, this will require your credit card information although you will not be billed anything.

In sweden you may need to add a "MOMS/VAT" number to be able to try it for free. You first need to find your company ORG number (10 digits), for example at allabolag.se. The vat number is SE${ORGNR}01

## DevOps labs

### Introduction to Google Cloud

During the laboration we need somewhere to store our artifacts and run our payload (and tests). This example is using Google Cloud infrastructure for it. 

You need to have a Google Cloud account to run this labs, if you haven't created one, please follow the instructions in [Signup](signup.md) first.

### Let's get started with Google Cloud

To have the possiblity to access Google cloud I need to setup an environment. To help me I have a sample shell script that I need to run. 

Try running a command now:
```bash
  cd bootstrap
  ./bootstrap.sh prefix suffix
```

**Tip**: Click the copy button on the side of the code box and paste the command in the Cloud Shell terminal to run it.

**Replace prefix and digit with to make the project unique.**

When the script runs it will bootstrap the project on google cloud we are going to use during the education. 
It has enabled some functionality on the project and will output some variables that we will use in the next step.


### Let's use a Container registry to store our artefacts

In the pipeline we want to have somewhere to store the container images we have built so we need a container registry. The bootstrap script in the previous step  enabled a container registry. If you want to do it manually in the future you can follow the instruction on https://cloud.google.com/container-registry/docs/pushing-and-pulling?_ga=2.224367576.-2118620794.1590522151.

We now need to improve the CircleCI pipeline so it can push the images to Google Cloud. To be able to do that we first need to add the credentials to a google cloud in CircleCI. 


### Add environment in CircleCI

We need to add 3 environment variables to CircleCI, in the last line from the bootstrap script you should have got something like this:

```
Environment variables that need to be added to CircleCI
Organization Settings->Context->Create Context->devopsedu-global
GOOGLE_PROJECT_ID = prefix-username-suffix
GOOGLE_COMPUTE_ZONE = europe-west1-b
GOOGLE_AUTH =  ewogICJ0eXBl...0LmNvbSIKfQo=
```

Add the variables in Organization Settings->Context->Create Context->devopsedu-global. 

The reason to create a context is to make the variables reusable ower multiple pipelines in CircleCI. In a an organisation it's often the "Ops" that is responsible for creating this "context".


### How to use the Context in CircleCI

In Circle we need to change the workflow to have the possibility to use the "Context".

```
version: 2.1
workflows:
  build-and-push:
    jobs:
      - build:
          context: devopsedu-global
jobs:
  build:
    machine: true
    steps:
      - checkout
      - run: 
          name: Checking environment
          command: env
      - run: docker build -t company/app:$CIRCLE_BRANCH .
```

Run the pipeline and verify that you can see that the environment variables have been set.


### Authorize to gCloud and push the image

We now need to update the build configurations so we have the possiblity to push the image.

Change the pipeline to:
```
version: 2.1
workflows:
  build-and-push:
    jobs:
      - build:
          context: devopsedu-global

jobs:
  build:
    machine: true
    steps:
      - checkout
      - run: 
          name: Checking environment
          command: env
      - run: echo ${GOOGLE_AUTH} | base64 -i --decode > ${HOME}/gcp-key.json
      - run: gcloud auth activate-service-account --key-file ${HOME}/gcp-key.json
      - run: gcloud --quiet config set project ${GOOGLE_PROJECT_ID}
      - run: gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}
      - run: docker build --rm=false -t eu.gcr.io/${GOOGLE_PROJECT_ID}/${CIRCLE_PROJECT_REPONAME}:$CIRCLE_SHA1 .
      - run: gcloud docker -- push eu.gcr.io/${GOOGLE_PROJECT_ID}/${CIRCLE_PROJECT_REPONAME}:$CIRCLE_SHA1 
```

After you have run the pipeline in Circle CI, you can now verify that the container is uploaded to the "Container registry" service. Make note of the Container url, you will need it later. 

If you have the possiblity, you can try to start the image on your computer.

## Use Terragrunt to create your first kubernetes cluster

In the cloudshell the bootstrap has installed `terragrunt` binary and also setup the environment variable so you are ready to run terragrunt. If you have lost your initial connection to the cloudshell (and your environment variables)

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce
source sourceme.sh
````

More information about terragrunt can be found at https://terragrunt.io.

### Create the first kubernetes cluster

This repo contains a description (or mapping table) of all resources on gce, it's prepared for you so you only have to run some commands to get a cluster up.

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce/europe-north1/dev/common/kubernetes
terragrunt apply 
```

The terragrunt apply command will show you what it intend to do, check the output and answer "yes" if it feels ok. After around 3-4 minutes you will have a kubernetes cluster up and running. 

You can now check it out in the Cloud console by going to https://console.cloud.google.com/kubernetes/list

Select the cluster and click connect to connect to the cluster, copy the command and run it in your cloudshell and check that you can connect to the cluster.

```bash
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


## Start a sample backend service and connect to it

We now have a kubernetes cluster that we can start a `pod` running the image we have created earlier with CircleCI.

We first need to change the file `~/cloudshell_open/devops-live-infrastructure/files/firstBackend/pod.yaml` with the full url to image. 
Then we can create the pod by running (change to full path of the file)

```
$ kubectl apply -f ~/cloudshell_open/devops-live-infrastructure/files/firstBackend/pod.yaml
TODO add sample output
$ kubectl get pods # To check that it is started
$ kubectl describe pod "podname" # to debug
```

We now want to connect to the pod running in the cluster, for debug/demo purposes. First we need to connect to the pod from the cloudshell by running:

```
kubectl port-forward pod/pod-name --address 0.0.0.0 8080:5000
```

That command is connecting the port 5000 on the pod to port 8080 on the cloudshell, after that we can start "Webpreview" in the cloudshell and your browser open a port simular to:

https://8080-cs-1042207630036-default.europe-west4.cloudshell.dev/?auth#TODO

Replace the last part to "/swagger/", example:

https://8080-cs-1042207630036-default.europe-west4.cloudshell.dev/swagger/ and you get into the pod. Now you can use the "swagger" interface to try out the application.
