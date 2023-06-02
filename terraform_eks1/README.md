# EKS_Terraform
Document Created By: Obaidur Rahman 

Provision an EKS Cluster (AWS) using Terraform: 

 

AWS's Elastic Kubernetes Service (EKS) is a managed service that lets you deploy, manage, and scale containerized applications on Kubernetes. 

We will deploy an EKS cluster using Terraform. Then, we will configure kubectl using Terraform output and verify that our cluster is ready to use. 

Why deploy with Terraform? 

While you could use the built-in AWS provisioning processes (UI, CLI, CloudFormation) for EKS clusters, Terraform provides you with several benefits: 

Unified Workflow - If you already use Terraform to deploy AWS infrastructure, you can use the same workflow to deploy both EKS clusters and applications into those clusters. 

Full Lifecycle Management - Terraform creates, updates, and deletes tracked resources without requiring you to inspect an API to identify those resources. 

Graph of Relationships - Terraform determines and observes dependencies between resources. For example, if an AWS Kubernetes cluster needs a specific VPC and subnet configurations, Terraform will not attempt to create the cluster if it fails to provision the VPC and subnet first. 

Prerequisites: 

AWS Account with admin access. 

Install Terraform in local machine Window/Mac/linux. Below is the link. 

https://developer.hashicorp.com/terraform/downloads 

Keep the terraform.exe in a specific folder. And run it from the command prompt to install it. 

Download AWS CLI for windows and install it. 

Once it is installed do the aws configure from command line to set a aws role to a user. 

After configuring the aws cli, you will be able to see the credentials as below. 

 

 
 

 

 

Its better to work in a visual studio coder editor for writing the codes. If it is not there download it. 

Steps for Spinup the EKS Cluster using terraform: 

 

Test the terraform it it is working or not before start coding. 

 

 

Now got visual studio and start implementing the aws infrastructure, before spinning up the eks we have to setup the networking 1st . 

The very 1st thing is to set the provider, we will go ahead and create a file calling provider.tf as below. 

 

And then will create a terraform file for VPC as vpc.tf 

 

 

 

 

 

Once these two file s are ready will do to the command line and run the below commands 

$ terraform fmt		#It will format the terafrom files 

$ terraform init		# to initialize the terraform 

$ terraform plan	# this for Dry run 

$ terraform apply	# Now it will implement the requested resources. 

 

Now similarly we have to create Internet Gateway, Subnets, NAT Gateway, Routing Tables in sequence as per the terraform script. 

 

Internet Gateway 

 

 

 

Subnetting. 

 

NAT Gatway. 

 

Routing tables 

 

Route Table association 

And Finally We have to create 2 file for EKS Cluster spin up one we can call it eks.tf in whichwe have to se some Policy and assume roles to be used for createing the cluster. 

 

And after that we have to create eks-node-group.tf file which is the most imposrtant file in which we have set the 

Additional assume roles as below. 

AmazonEKSWorkerNodePolicy,  

AmazonEKS_CNI_Policy,  

AmazonEC2ContainerRegistryReadOnly. 

And also EcC2 instance resource type size and version of EKS cluster every thing is setop in these two files. 

 

Once this two files ae ready will go to the terraform window and hit the same commands as below. 

 

 

 

$ terraform fmt		#It will format the terafrom files 

$ terraform init		# to initialize the terraform 

$ terraform plan	# this for Dry run 

$ terraform apply	# Now it will implement the requested resources. 

 

After completion of this terraform apply the EKS cluster will be ready. 

 

All the tl File will be shared view Once dirve folder. 

 

 

Once cluster is ready run the below command 

$ aws eks --region us-east-1 update-kubeconfig --name eks --profile terraform 

Output: 

 

Commandsfor kubernetes: 

$ kubectl get svc 

$ kubectl describe svc image_name 

 
