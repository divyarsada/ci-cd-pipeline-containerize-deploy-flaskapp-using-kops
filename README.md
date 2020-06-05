## ci-cd-pipeline-containerize-python-flaskapp

[![<ORG_NAME>](https://circleci.com/gh/divyarsada/ci-cd-pipeline-containerize-python-flaskapp.svg?style=shield)](https://app.circleci.com/pipelines/github/divyarsada/ci-cd-pipeline-containerize-python-flaskapp)

### Scope of the Project


In this project a sample helloworld flask application is containerized using docker and deployed to Kops cluster created on AWS. This is achieved by creating a kops cluster and building CI/CD pipeline which conists of mutiple stages for build,test,dockerize the application,pushing to dockerhub registry and finally deploy to the kcluster. The deployment strategy used here is Rolling Update.

### Environment Setup

* GitHub repository for storing all the project code
* Docker hub repository as centralized image repository to manage images built in the project.After a clean build, images are   pushed to the repository
* Server Setup with awscli,kubectl,kops,pip,docker installed
* Start the jenkins service and install the Plugins mentioned (BlueOcean,Docker,Docker build step,Kubernetes client API,Kubernetes Credentials Plugin,Kubernetes Continuous Deploy Plugin,KubernetesPipelineDevOpsSteps,Kubernetes CLI)

### Steps to build the project

Automate the kops cluster creation using a script and execute 
Create the docker hub login and kops cluster(kubeconfig) credentails in Jenkins   Global credentials store
Create a JenkinsFile to define the pipeline for the project

###### Note

Any arguments that you pass to kops_cluster.sh will be forwarded to the  Kops cluster create commands within the script. Thus, it is possible to specify an explicit region fo the cluster as follows:
./kops_cluster.sh --region eu-west-1
 
#### This repository contains the following files:

* .gitignore: Tells Git to Ignore Specific Files/Folders for Python
* app.py: Flask Application that renders a webpage template, passing in a message to be displayed
* Jenkinsfile: Stages defined for the pipeline
* Dockerfile: Steps to build the docker image for the application
* Makefile:  A series of directives for Build Automation of the Dockerfile Image
* requirements.txt: List of Libraries to build the application 
* Kubernetes.yml: Specification on Kubernetes object you want to create, set values for the following fields like
apiVersion,kind,metadata,spec..etc..,
 nfrastructure_setup.yml: a CloudFormation template that defines an Route53 Hosted Zones,S3 required for Kops cluster 
* kops_cluster.sh: a Bash script that applies the CloudFormation template to your AWS account and finalises the Kops cluster creation
* Screenshots: Folder with screenshots of a successful deployment, failing deployment and rolling deployment
* README.md: Description about the project
