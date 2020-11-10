# Start a sample backend service and connect to it

We now have a kubernetes cluster that we can start a `pod` running the image we have created earlier with CircleCI.

We first need to change the file `~/cloudshell_open/devops-live-infrastructure/files/firstBackend/pod.yaml` with the full url to image. 
Then we can create the pod by running (change to full path of the file)

```
$ kubectl apply -f ~/cloudshell_open/devops-live-infrastructure/files/firstBackend/pod.yaml
pod/backend created
$ kubectl get pods
NAME      READY   STATUS              RESTARTS   AGE
backend   0/1     ContainerCreating   0          5s
$ kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
backend   1/1     Running   0          9s
$ kubectl describe pod backend # to debug
```

We now want to connect to the pod running in the cluster, for debug/demo purposes. First we need to connect to the pod from the cloudshell by running:

```
kubectl port-forward pod/backend --address 0.0.0.0 8080:5000
```

That command is connecting the port 5000 on the pod to port 8080 on the cloudshell, after that we can start "Webpreview" in the cloudshell and your browser open a port simular to:

https://8080-cs-1042207630036-default.europe-west4.cloudshell.dev/?auth#TODO

Replace the last part to "/swagger/", example:

https://8080-cs-1042207630036-default.europe-west4.cloudshell.dev/swagger/ and you get into the pod. Now you can use the "swagger" interface to try out the application.

