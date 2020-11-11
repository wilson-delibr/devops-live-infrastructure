# Create a prod environment.

If you have lost your initial connection to the cloudshell (and your environment variables)

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce
source sourceme.sh
````

## Prepare the live-infrastructure

First we need to update the live-infrastructure so it has an uat environment, either you can merge the "addUat branch in live-infrastructure repo or copy part of the the "dev" environment. We are going to reuse the dev k8s cluster. 

The following is a sample on how you can copy it, but you also need to have registrerd an SSH key on github to have the possiblity to push it there.

```bash
cd ~/cloudshell_open/devops-live-infrastructure/gce/europe-north1/dev/realworld-backend
cp -a fast uat
git add uat/terragrunt.hcl
git commit -m"Uat env"
git push
```

## The pipelines

We now need to update part of the pipeline to add an uat steps and also and aproval step:  the files/uat/ contains a full sample

In the pipeline we need to first change the workflow for adding the stages:


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