pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '779846799257'
        REPO_NAME = 'react-app-repo'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${REPO_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }
        }

        stage('Tag and Push Image') {
            steps {
                script {
                    sh """
                        docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}
                        docker push ${ECR_URL}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Successfully pushed ${ECR_URL}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}
