# DevOps labs

## Introduction to Google Cloud

During the laboration we need somewhere to store our artifacts and run our payload (and tests). This example is using Google Cloud infrastructure for it.

You need to have a Google Cloud account to run this labs, if you haven't created one, please follow the instructions in [Signup](signup.md) first.

## Let's get started with Google Cloud

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
This command takes some minutes to run.

## Let's use a Container registry to store our artefacts

In the pipeline we want to have somewhere to store the container images we have built so we need a container registry. The bootstrap script in the previous step  enabled a container registry. If you want to do it manually in the future you can follow the instruction on [Pushing and Pulling](https://cloud.google.com/container-registry/docs/pushing-and-pulling?_ga=2.224367576.-2118620794.1590522151).

We now need to improve the CircleCI pipeline so it can push the images to Google Cloud. To be able to do that we first need to add the credentials to a google cloud in CircleCI.

### Add environment in CircleCI

We need to add 3 environment variables to CircleCI, in the last line from the bootstrap script you should have got something like this:

```bash
Environment variables that need to be added to CircleCI
Organization Settings->Context->Create Context->devopsedu-global
GOOGLE_PROJECT_ID = prefix-username-suffix
GOOGLE_COMPUTE_ZONE = europe-west1-b
GOOGLE_AUTH =  ewogICJ0eXBl...0LmNvbSIKfQo=
```

Add the variables in Organization Settings->Context->Create Context->devopsedu-global. Be careful when you copy the GOOGLE_AUTH line so you get the full line, it's easy to miss some of the line in the output.

The reason to create a context is to make the variables reusable ower multiple pipelines in CircleCI. In a an organisation it's often the "Ops" that is responsible for creating this "context".

### How to use the Context in CircleCI

In Circle we need to change the workflow to have the possibility to use the "Context". Go to Github.com, find your fork of the devops-realworld-example-backend repo, go to .circleci and edit the config.yml change change the content to the snippet below:

```yaml
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

The pipeline will now run with the new configuration. Verify that you can see that the environment variables have been set in the "Checking environment" step.

### Authorize to gCloud and push the image

We now need to update the build configurations so we have the possiblity to push the image.

Change the pipeline to:

```yaml
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

After you have run the pipeline in Circle CI, you can now verify that the container is uploaded to the "Container registry" service at [Console](https://console.cloud.google.com/) and search for "Container Registry", you may need to select the newly created project with "prefix-tf-suffix".

If you have the possiblity, you can try to start the image on your computer.

```bash
gcloud auth login
gcloud auth configure-docker
docker run -p 5000:5000 eu.gcr.io/pref1-miklab4711-tf-prsuf2/devops-realworld-example-backend@sha256:8017f19c69dce481feca2c81c988b852959b1aa0ff981e863faf7c93c2dae58e
```

Open your webbrowser to:

http://localhost:5000/swagger
