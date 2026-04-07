pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE_NAME = 'sriramsuryaa/trend-store-dev'
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG_CREDENTIALS = credentials('kubeconfig')
    }

    stages {
        stage('Git Checkout') {
            steps {
                echo 'Checking out source code from Git repository...'
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .
                    docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest
                """
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing Docker image to DockerHub...'
                sh """
                    echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                    docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    docker push ${DOCKER_IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo 'Deploying to EKS cluster...'
                sh """
                    # Set up kubeconfig
                    mkdir -p ~/.kube
                    echo \$KUBECONFIG_CREDENTIALS > ~/.kube/config
                    chmod 600 ~/.kube/config

                    # Update deployment with new image
                    sed -i 's|image:.*|image: ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}|g' k8s/deployment.yaml

                    # Apply Kubernetes manifests
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    # Wait for rollout to complete
                    kubectl rollout status deployment/trend-store --timeout=300s

                    # Run health check
                    echo 'Running health checks...'
                    chmod +x deploy-monitoring.sh
                    ./deploy-monitoring.sh

                    # Show deployment status
                    kubectl get pods -l app=trend-store
                    kubectl get svc trend-store
                """
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker images...'
            sh """
                docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} || true
                docker rmi ${DOCKER_IMAGE_NAME}:latest || true
                docker system prune -f
            """
        }

        success {
            echo 'Pipeline completed successfully! 🎉'
            echo "Application deployed to: http://\$(kubectl get svc trend-store -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
        }

        failure {
            echo 'Pipeline failed! ❌'
            sh """
                kubectl get pods -l app=trend-store || true
                kubectl describe deployment trend-store || true
            """
        }
    }
}