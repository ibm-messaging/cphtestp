# Running the cphtestp performance tests inside Red Hat OpenShift Container Platform (OCP)
The following instructions describe how to run the IBM MQ CPH performance harness inside an
OpenShift Container Platform (OCP) cluster. 

Firstly, perform a Docker build of the performance harness as normal:
```
docker build --tag chptestp .
```

## Creating the project/namespace and pushing images to the image registry
The first step to deploying an MQ client is to create the project/namespace. Use the same project/namespace that you used for the MQ deployment, or create as follows if MQ QM is yet to be deployed (and reuse when deploying MQ QM).
```
oc new-project mqns
```
If your test image is in your local repository, you will need to first log into the default image registry in OCP before you can upload your test image.
``` 
docker login -u <username> -p $(oc whoami -t) https://default-route-openshift-image-registry.apps.<hostname>
docker tag cphtestp default-route-openshift-image-registry.apps.<hostname>/mqns/cphtestp
docker push default-route-openshift-image-registry.apps.<hostname>/mqns/cphtestp
```
If you encounter some errors with pushing your image, check the process described on the [jmstestp](https://github.com/ibm-messaging/jmstestp/blob/master/openshift.md) instructions for further help.
You can check that the images are loaded within the correct project/namespace, by going to OpenShift UI -> Build -> Images

You can use OpenShift to create default resources directly from the supplied image, but for this demonstration we are going to look 
at using some pre-existing yaml to assist with deploying the cphtestp client application.

## Grant SCC permissions
If you tried running an instance of your application, it would likely fail as the client attempts to write to some temporary storage associated 
with the lifetime of the pod. Since this pod is only used for testing purposes the easiest way to resolve this issue is to grant the
OpenShift permission for the pod to run with its preferred user as follows:
```
oc adm policy add-scc-to-user anyuid -z default
```

## Configure the environment properties
We can use a single yaml file to configure and deploy an instance of our MQ application to execute as a Kubernetes Job

Review the [cphtestp-job.yaml](./cphtestp-job.yaml) and define at least the MQ_QMGR_HOSTNAME, MQ_QMGR_NAME and MQ_QMGR_PORT values as well as the location from where to pull the image. Remove any reference to additional networks and node selection if not required.

Optionally you may also wish to set any other properties as described in the [README](README.md#setting-configuration-options)
such as `MQ_RESPONDER_THREADS` (to restrict the number of threads used), `MQ_QMGR_CHANNEL` to set the channel name,
or `MQ_USERID` and `MQ_PASSWORD` if you need to authenticate the client connections.

To run the job:
```
oc create -f cphtestp-job.yaml
```
You can then check that the client pod has been created and the job is running:
```
oc get pods
oc get jobs
```
If you want to view the status of the client whilst its running, you can use either `kubectl exec` or `oc exec` to attach a terminal to the running pod:
```
oc exec -ti cphtestp-kwkvv bash
cat output | more
cat results.csv
```
When the job is finished, you can obtain the results by viewing the pod logs `oc logs <cphtestp pod>`. Deleting the job will also delete the associated pod and its results.

## Congratulations!
You have successfully configured the IBM CPH performance test harness to run in a Red Hat
OpenShift cluster!
