# This is the step by step process i took in deploying my app to my cluster. 

## Deploying a simple go sample app on eks cluster 

### Step1: Containerize the app  
- Fork the app repo from https://github.com/ybkuroki/go-webapp-sample. 

- ssh into your forked version with `git clone git@github.com:<your github username>/go-webapp-sample.git` 

- Create a docker file for the app 
![](images/create%20docker%20file.png) 

- Build your image from the docker file by right clicking on the docker file and selecting "build image". 
![](images/docker%20image%20built.png)  

- Create a container from the image by running the command `docker run <image>` i used `docker run -p 8080:8080 shecode` to map my port. 
![](images/running%20container.png)  

- The app is available on localhost:8080 
![](images/working%20page.png)  


### Step2: Push the image to a repository 

For this task i used docker hub.

- Create a repository on docker hub 
![](images/create%20dockerhub%20repo.png)   

- Push the image to the created repository using `docker push <repo name>/<image name>:<tag>` 
![](images/pushed%20image.png)  

---

### Step3: Create an EKS cluster on AWS 

#### Prerequisites 

- An existing VPC and subnets that meet amazon EKS requirements
- AWS CLI 
- Kubectl 
- eksctl 

1. Create an EC2 Instance running Ubuntu 22.04 

2. Following the instructions on the official [AWS EKS guide](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) create a cloud formation stack with the VPC and subnets that meet EKS requirements, Install aws cli, kubectl and ekscli. 

3. Using eksctl, create your cluster by running the command below. 

```
eksctl create cluster --name my-cluster --region region-code --version 1.25 --vpc-private-subnets subnet-ExampleID1,subnet-ExampleID2 --without-nodegroup
```
substitute the necessary values. 
- Replace "my-cluster" with the name you want to give your cluster. 
- region-code should be replaced with the region your resources would be deployed in. 
- Replace subnets with 2 subnet ids of your choosing. 
![](images/create%20cluster.png)  

- Confirm communication with your cluster by running `kubectl get svc` 
![](images/working%20kubectl.png)  

- Go to your management console to view your newly created cluster. 
![](images/eks%20mc.png)  
![](images/created%20kluster.png)  

---

### Step4: Create a managed node group 

1. Create a keypair for authentication when you want to ssh into your nodes 

```
aws ec2 create-key-pair \
    --key-name my-key-pair \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > my-key-pair.pem
```
![](images/created%20node.png)  

- Substitute the necessary information. Replace "my-key-pair" with the name you want to give to your keypair. 
- Replace pem with the authentication method of your choosing(pem or ppk)
- Set permission of your private key so that only you can read it. `chmod 400 key-pair-name.pem`

2. Create a node iam role following the instructions on the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html) 

3. Create your node using CLI or from the management console, following the instructions in the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html) 

4 Monitor the status of your created nodes with `kubectl get nodes --watch`
![](images/watch%20node%20creation.png)   

---

### Step5: Create a manifest and service file to allow deployment of your app 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: webapp
  name: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  strategy: {}
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: shecode
        image: jaykaneki/shecode:latest
        imagePullPolicy: Always
        resources: {}
        ports:
          - containerPort: 8080
status: {}

---

apiVersion: v1
kind: Service
metadata:
  name: webapp
spec:
  type: LoadBalancer
  selector:
    app: webapp
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
```

>**Note** I created both in one file(manifest.yml), and my service configuration includes a load balancer, to expose my services externally and get an IP to access my app. 

![](images/yml%20file.png)  

- Deploy your app by running the command `kubectl create -f manifest.yml` or `kubectl apply -f manifest.yml`(to reload an existing file), `kubectl get pods` to see the status of your pods. And `kubectl get svc` to get the endpoint of your running container.  
![](images/working%2C%20running%20container.png)  

- Visit the endpoint to confirm the creation of your app. 
![](images/working%20app.png) 

![](images/api-books%20section.png)  

---

# The End!!! 

We have successfully containerized and deployed our sample go app. You can access the app at http://afbc9b80030f342138e5447ab5a32642-776669735.us-east-1.elb.amazonaws.com:8080/#/home for a while, before i take it down. The username and password is **"test"** 


![final closure](https://github.com/StrangeJay/go-webapp-sample/assets/105195327/b914f512-b1b6-425e-b743-70a334193f8a)

