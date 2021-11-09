
## Config Commands
# Show Merged kubeconfig settings.
kubectl config view

# use multiple kubeconfig files at the same time and view merged config
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2 

kubectl config view

# get the password for the e2e user
kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

# display the first user
kubectl config view -o jsonpath='{.users[].name}'

# get a list of users
kubectl config view -o jsonpath='{.users[*].name}'

# display list of contexts 
kubectl config get-contexts  

# display the current-context
kubectl config current-context              

# set the default context to my-cluster-name
kubectl config use-context my-cluster-name           

# add a new user to your kubeconf that supports basic auth
kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

## Get Commands
# -o wide - Show more information.
# -o yaml - Show more information in yaml format
# --watch or -w - watch for changes.
kubectl get all
kubectl get namespaces
kubectl get configmaps
kubectl get nodes
kubectl get pods
kubectl get rs
kubectl get svc kuard
kubectl get endpoints kuard
kubectl get secret mysecret

# Get pods by label
kubectl get pods -l environment=production,tier!=frontend
kubectl get pods -l 'environment in (production,test),tier notin (frontend,backend)'

# Get pod information
kubectl get pod mypod -o yaml

# Get last pod status
kubectl get pod/mypod-o go-template="{{range .status.containerStatuses}}{{.lastState}}{{end}}"

## Create or Apply Commands
# create resource(s)
kubectl apply -f ./my-manifest.yaml           

# create from multiple files 
kubectl apply -f ./my1.yaml -f ./my2.yaml     

# create resource(s) in all manifest files in dir
kubectl apply -f ./dir                         

# create resource(s) from url
kubectl apply -f https://git.io/vPieo          

# start a single instance of nginx
kubectl create deployment nginx --image=nginx  

# get the documentation for pod manifests
kubectl explain pods      

## Describe Commands
kubectl describe nodes [id]
kubectl describe pods [id]
kubectl describe rs [id]
kubectl describe svc kuard [id]
kubectl describe endpoints kuard [id]

## Delete Commands
kubectl delete nodes [id]
kubectl delete pods [id]
kubectl delete rs [id]
kubectl delete svc kuard [id]
kubectl delete endpoints kuard [id]
# Delete a pod using the type and name specified in pod.json
kubectl delete -f ./pod.json                              

# Delete pods and services with same names "baz" and "foo"
kubectl delete pod,service baz foo                

# Delete pods and services with label name=myLabel
kubectl delete pods,services -l name=myLabel      

# Delete all pods and services in namespace my-ns
kubectl -n my-ns delete pod,svc --all            

# Delete all pods matching the awk pattern1 or pattern2
kubectl get pods  -n mynamespace --no-headers=true | awk '/pattern1|pattern2/{print $1}' | xargs  kubectl delete -n mynamespace pod

# Force a deletion of a pod without waiting for it to gracefully shut down
kubectl delete pod-name --grace-period=0 --force

## Patching Commands
# Partially update a node
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'

# Update a container's image; spec.containers[*].name is required because it's a merge key
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'

# Update a container's image using a json patch with positional arrays
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'

# Disable a deployment livenessProbe using a json patch with positional arrays
kubectl patch deployment valid-deployment  --type json   -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'

# Add a new element to a positional array
kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/secrets/1", "value": {"name": "whatever" } }]'

## Update Commands
# Rolling update "www" containers of "frontend" deployment, updating the image
kubectl set image deployment/frontend www=image:v2              

# Check the history of deployments including the revision 
kubectl rollout history deployment/frontend                      

# Rollback to the previous deployment
kubectl rollout undo deployment/frontend                         

# Rollback to a specific revision
kubectl rollout undo deployment/frontend --to-revision=2         

# Watch rolling update status of "frontend" deployment until completion
kubectl rollout status -w deployment/frontend                    

# Rolling restart of the "frontend" deployment
kubectl rollout restart deployment/frontend                      

# Pause/resume a rollout
kubectl rollout pause deployment/nginx-deployment
kubectl rollout resume deploy/nginx-deployment

# Force replace, delete and then re-create the resource. Will cause a service outage.
kubectl replace --force -f ./pod.json

# Create a service for a replicated nginx, which serves on port 80 and connects to the containers on port 8000
kubectl expose rc nginx --port=80 --target-port=8000

# Update a single-container pod's image version (tag) to v4
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -

kubectl label pods my-pod new-label=awesome                      # Add a Label
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq       # Add an annotation
kubectl autoscale deployment foo --min=2 --max=10                # Auto scale a deployment "foo"

## Cluster Commands
# Mark my-node as unschedulable
kubectl cordon my-node                                                

# Drain my-node in preparation for maintenance
kubectl drain my-node                                                 

# Mark my-node as schedulable
kubectl uncordon my-node       

# Show metrics for a given node
kubectl top node my-node                                              

# Display addresses of the master and services
kubectl cluster-info                                                  

# Dump current cluster state to stdout
kubectl cluster-info dump                                             

# Dump current cluster state to /path/to/cluster-state
kubectl cluster-info dump --output-directory=/path/to/cluster-state   

## Edit Commands
# Edit the service named docker-registry
kubectl edit svc/docker-registry

# Use an alternative editor
KUBE_EDITOR="nano" kubectl edit svc/docker-registry   

# Edit deployment settings
kubectl edit deployment/[pod]


## Namespaces
kubectl config set-context $(kubectl config current-context) --namespace=my-namespace

## Labels
kubectl get pods --show-labels

## Scaling resources
# Scale a replicaset named 'foo' to 3
kubectl scale --replicas=3 rs/foo           

# Scale deployment by name
kubectl scale deployment nginx-deployment --replicas=10

# Scale a resource specified in "foo.yaml" to 3
kubectl scale --replicas=3 -f foo.yaml                            

# If the deployment named mysql's current size is 2, scale mysql to 3
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql  

# Scale multiple replication controllers
kubectl scale --replicas=5 rc/foo rc/bar rc/baz                   

# Set autoscaling config
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80

## Logs Commands
# dump pod logs (stdout)
kubectl logs my-pod                                 

# dump pod logs, with label name=myLabel (stdout)
kubectl logs -l name=myLabel                        

# dump pod logs (stdout) for a previous instantiation of a container
kubectl logs my-pod --previous                      

# dump pod container logs (stdout, multi-container case)
kubectl logs my-pod -c my-container                 

# dump pod logs, with label name=myLabel (stdout)
kubectl logs -l name=myLabel -c my-container        

# dump pod container logs (stdout, multi-container case) for a previous instantiation of a container
kubectl logs my-pod -c my-container --previous      

# stream pod logs (stdout)
kubectl logs -f my-pod                              

# stream pod container logs (stdout, multi-container case)
kubectl logs -f my-pod -c my-container              

# stream all pods logs with label name=myLabel (stdout)
kubectl logs -f -l name=myLabel --all-containers    


## Run Commands
# Run pod as interactive shell
kubectl run -i --tty busybox --image=busybox -- sh  

# Run pod nginx in a specific namespace
kubectl run nginx --image=nginx --restart=Never -n 
mynamespace                                         

# Run pod nginx and write its spec into a file called pod.yaml
kubectl run nginx --image=nginx --restart=Never     
--dry-run -o yaml > pod.yaml

# Run command in existing pod (1 container case)
kubectl exec my-pod -- ls /                         

# Run command in existing pod (multi-container case)
kubectl exec my-pod -c my-container -- ls /         

# Run bash inside a pod
kubectl exec --stdin --tty [pod] -- /bin/bash

# Attach to Running Container
kubectl attach my-pod -i                            

# Listen on port 5000 on the local machine and forward to port 6000 on my-pod
kubectl port-forward my-pod 5000:6000               

# Port forwarding of a service
kubectl port-forward deployment/kuard 8080:8080

# Show metrics for a given pod and its containers
kubectl top pod POD_NAME --containers            

# Copy files from a pod
kubectl cp POD_NAME:/var/log /local/path

# Get namespace quotas usage
kubectl describe quota -n <namespace>

# Get kubectl api resources
kubectl api-resources

# HELM COMMANDS
# Read versions deployed with helm
helm history my-cool-service

# Identify if the revision has a difference with the current state of the cluster
helm get manifest my-cool-service --revision 2 | kubectl diff -n my-cool -f -

# Rolback helm revision
helm rollback my-cool-service 3
