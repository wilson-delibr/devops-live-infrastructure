# The fast test environment

The live-infrastructure repo is already prepared with the configuration for a test environment (gce/europe-north1/dev/realworld-backend/fast)

## The pipelines

We now need to update part of the pipeline to add the deployment to this environment, Copy the following file to the .circleci

```yaml
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
      - persist_to_workspace:
          root: .
          paths:
            - scripts

  fast_test:
    docker:
      - image: eu.gcr.io/prepedu-mikael-tf-pr1/google-cloud-sdk-terraform:latest

    steps:
      - attach_workspace:
          at: .

      - run: echo ${GOOGLE_AUTH} | base64 -i --decode > ${HOME}/gcp-key.json
      - run: gcloud auth activate-service-account --key-file ${HOME}/gcp-key.json
      - run: gcloud --quiet config set project ${GOOGLE_PROJECT_ID}
      - run: gcloud --quiet config set compute/zone ${GOOGLE_COMPUTE_ZONE}
      - run:
         name: Checking environment
         command: env
      - run:
         name: Checking dirs
         command: ls -l . scripts
      - run:
          name: Clone and update Terraform infrastructure repo
          command: bash -x scripts/clone-and-update-infrastructure.sh ${CIRCLE_SHA1} devops-live-infrastructure/gce/europe-north1/dev/realworld-backend/fast
      - run:
          name: Deploy application and test pods
          command: |
            cd devops-live-infrastructure/gce/europe-north1/dev/realworld-backend/fast
            export GOOGLE_CREDENTIALS=${HOME}/gcp-key.json
            export GOOGLE_PROJECT=${GOOGLE_PROJECT_ID}
            terragrunt apply -auto-approve
            ext_ip=$(terragrunt output external_ip)
            echo "Try to reach the endpoint"
            curl -f http://${ext_ip}/articles

```

Run the change and see if you get it deployed to a test environment.

In a line in the end it outputs what public IP you get, and you can use that for reaching the service.

For example if you get 'external_ip = 104.199.3.29' you can reach the swagger interface at: "http://104.199.3.29/swagger
