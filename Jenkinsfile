pipeline {
    agent any

    environment {
        DIMG_NAME = 'sriramsuryaa/trend-store-prod'
        DIMG_TAG = "${env.BUILD_NUMBER}"       
    }

    stages {
        stage('Git Checkout') {
            steps {
                echo 'Checking out source code from Git repository...'
                git branch: 'main', changelog: false, credentialsId: 'github-pat', poll: false, url: 'https://github.com/sriramsuryaa/Trend-Store.git'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DIMG_NAME}:${DIMG_TAG} .
                    docker tag ${DIMG_NAME}:${DIMG_TAG} ${DIMG_NAME}:latest
                """
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing Docker image to DockerHub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DHUB_PASS', usernameVariable: 'DHUB_USER')]) {
                sh """
                    echo \$DHUB_PASS | docker login -u \$DHUB_USER --password-stdin
                    docker push ${DIMG_NAME}:${DIMG_TAG}
                    docker push ${DIMG_NAME}:latest
                """
                }
            }
        }

        stage('Deploy'){
            steps {
                echo 'Deploying in EKS Cluster'
                withCredentials([file(credentialsId: 'trend-store-cluster', variable: 'KUBECONFIG')]) {
                    sh '''
                    kubectl get pods

                    # Apply Kubernetes manifests
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    # Wait for rollout to complete
                    kubectl rollout status deployment/trend-store --timeout=300s

                    # Show deployment status
                    kubectl get pods -l app=trend-store
                    kubectl get svc trend-store
                    '''
                    }
                }
            }
   }
}