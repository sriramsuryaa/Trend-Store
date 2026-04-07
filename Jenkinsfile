pipeline {
    agent any

    environment {
        DIMG_NAME = 'sriramsuryaa/trend-store-prod'
        DIMG_TAG = "${env.BUILD_NUMBER}"       
    }

    stages {
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
                    kubectl rollout restart deployment/trend-store
                    kubectl rollout status deployment/trend-store --timeout=300s

                    # Show deployment status
                    kubectl get pods -l app=trend-store
                    kubectl get svc trend-store
                    '''
                    }
                }
            }
   }
       post {
        always {
            echo 'Cleaning up Docker images...'
            sh """
                docker rmi ${DIMG_NAME}:${DIMG_TAG} || true
                docker rmi ${DIMG_NAME}:latest || true
                docker system prune -f
            """
        }

        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed!'
            sh """
                kubectl get pods -l app=trend-store || true
                kubectl describe deployment trend-store || true
            """
        }
    }
}