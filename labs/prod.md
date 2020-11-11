# Create a prod environment.

If you have lost your initial connection to the cloudshell (and your environment variables)

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce
source sourceme.sh
````

## Create the prod kubernetes cluster

### Prepare the live-infrastructure

First we need to update the live-infrastructure so it has an prod environment, either you can merge the "addProd" branch in live-infrastructure repo or copy the "dev" environment. We run the prod environment in another GKE zone so we doesn't get out of quota. 
The following is a sample on how you can copy it, but you also need to have registrerd an SSH key on github to have the possiblity to push it there.

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce/
cp -a europe-north1 europe-west1
cd europe-west1/
mv dev prod
ls
cd prod/
ls
cd realworld-backend/
ls
mv fast prod
cd prod
# Open terragrunt.hcl in editor and remove pod_scale and ext_database
cd ../../../..
ls
add europe-west1
git commit -m"Prod in west1"
git push
```

If you have done the merge in github you need to update your local filetree with something like this.
```bash
cd ~/cloudshell_open/devops-live-infrastructure/
git fetch
git rebase
```


### Create the prod kubernetes cluster

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce/europe-west1/prod/common/kubernetes
terragrunt apply 
```

The terragrunt apply command will show you what it intend to do, check the output and answer "yes" if it feels ok. After around 3-4 minutes you will have a kubernetes cluster up and running. 

You can now check it out in the Cloud console by going to https://console.cloud.google.com/kubernetes/list

## The pipelines

We now need to update part of the pipeline to add the production steps, the files/prod/ contains a full sample

In the pipeline we need to first change the workflow for adding the prod stage:


```
version: 2.1
workflows:
  build-and-push:
    jobs:
      - build:
          context: devopsedu-global
      - fast_test:
          context: devopsedu-global
          requires:
            - build
      - prod:
          context: devopsedu-global
          requires:
            - fast_test
```

Then make a copy of the fast_test steps and name it prod, change every occurence of: "devops-live-infrastructure/gce/europe-north1/dev/realworld-backend/fast" to "devops-live-infrastructure/gce/europe-west1/prod/realworld-backend/prod".

Run the change and see if you get it deployed to production, the production environment takes longer time beacuse it also use an external database. In a line in the end it outputs what public IP you get, and you can use that for reaching the service.

For example if you get 'external_ip = 104.199.3.29' you can reach the swagger interface at: "http://104.199.3.29/swagger"