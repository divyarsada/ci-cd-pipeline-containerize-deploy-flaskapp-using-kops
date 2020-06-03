// Global Variables
def clusterName = 'kops.cluster.kubernetes-aws.io'
def dockerImageID = 'sampletest19/helloworldpipeline'
def registry = "sampletest19/helloworldpipeline"
def deploymentName = "helloworld-deployment-rolling-update"
def podHash = ""
def podName = ""
def serviceAddress = ""
def registryCredential = 'docker_hub_login'
def dockerImage = 'sampletest19/helloworldpipeline'
def rolloutStatus = ""
pipeline {
  agent any
  stages {
	stage('Build') {
        steps {
            sh 'make install'
        }
    }
	stage('Lint Test') {
		steps {
			sh 'make lint'
		}
	}
	stage('Build Docker Image') {
        when {
            branch 'master'
        }
        steps {
            script {
                dockerImage = docker.build registry + ":$BUILD_NUMBER"
            }
        }
    }

	stage('Push Image to Docker hub') {
		when {
            branch 'master'
        }
        steps {
            script {
                docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                     dockerImage.push()
                }    
			}
		}
	}

	stage('Set current kubectl context') {
            steps {
                sh 'export KUBECONFIG=~/.kube/config'
            }
    }
	stage('Deploy Kubernetes Cluster') {
		steps {
			script {
				sh "echo 'Check if app has been deployed'"
				script {
					deploymentStatus = sh(script: "~/bin/kubectl get deployments --output=json | jq -r '.items[0] | select(.metadata.labels.run == \"$deploymentName\").metadata.name'", returnStdout: true).trim()
				}
				if (deploymentStatus.isEmpty()) {
					sh "echo 'No deployments found, deploying now'"
					sh "~/bin/kubectl run `echo $deploymentName` --image=`echo $dockerImageID`:`echo $BUILD_NUMBER` --replicas=2 --port=8000"
					sh "echo Exposing the service on port 8090"
					sh "~/bin/kubectl expose deployment $deploymentName --port=8090 --target-port=8000 --type=LoadBalancer"
					script {
					    sh "echo 'Retrieving New Pod Name and Hash'"
						podName = sh(script: "~/bin/kubectl get pods --output=json | jq '[.items[] | select(.status.phase != \"Terminating\") ] | max_by(.metadata.creationTimestamp).metadata.name'", returnStdout: true).trim()
						podHash = sh(script: "~/bin/kubectl get pods --output=json | jq '[.items[] | select(.status.phase != \"Terminating\") ] | max_by(.metadata.creationTimestamp).metadata.labels.\"pod-template-hash\"'", returnStdout: true).trim()
						serviceAddress = sh(script: "~/bin/kubectl get services --output=json | jq -r '.items[0] | .status.loadBalancer.ingress[0].hostname'", returnStdout: true).trim()
					}
					sh "echo 'Successfully created deployment $deploymentName and exposed as on URL: http://$serviceAddress:8090'"
				} else {
					sh "echo 'Application Already Deployed, updating the deployment applying Rolling update deployment strategy'"
					sh "~/bin/kubectl set image deployment/`echo $deploymentName` `echo $deploymentName`=`echo $dockerImageID`:`echo $BUILD_NUMBER`"
					script {
					    sh "echo 'Fetching the Rollout status........'"
					    rolloutStatus = sh(script: "~/bin/kubectl rollout status deployment/$deploymentName")
						sh "echo 'Retrieving New Pod Name and Hash'"
						podName = sh(script: "~/bin/kubectl get pods --output=json | jq '[.items[] | select(.status.phase != \"Terminating\") ] | max_by(.metadata.creationTimestamp).metadata.name'", returnStdout: true).trim()
						podHash = sh(script: "~/bin/kubectl get pods --output=json | jq '[.items[] | select(.status.phase != \"Terminating\") ] | max_by(.metadata.creationTimestamp).metadata.labels.\"pod-template-hash\"'", returnStdout: true).trim()
						serviceAddress = sh(script: "~/bin/kubectl get services --output=json | jq -r '.items[0] | .status.loadBalancer.ingress[0].hostname'", returnStdout: true).trim()
					}
					sh "echo 'Rollout status: $rolloutStatus'"
					sh "echo 'Currently running pods:$podName,$podHash'"
				}
				sh "echo 'Deployment Complete!'"
				sh "echo 'View  (Please Allow a Minute for Services to Refresh): http://$serviceAddress:8090'"
			}
		}
	}
  }
}