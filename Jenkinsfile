pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '779846799257'
        REPO_NAME = 'react-app-repo'
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
        CONTAINER_NAME = 'react-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    // Get first 7 characters of commit hash (like CodeBuild does)
                    COMMIT_HASH = sh(script: "git rev-parse --short=7 HEAD", returnStdout: true).trim()
                    IMAGE_TAG = COMMIT_HASH
                    echo "Using IMAGE_TAG=${IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${ECR_URL}:${IMAGE_TAG} .
                        docker tag ${ECR_URL}:${IMAGE_TAG} ${ECR_URL}:latest
                    """
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

        stage('Push Docker Image') {
            steps {
                script {
                    sh """
                        docker push ${ECR_URL}:${IMAGE_TAG}
                        docker push ${ECR_URL}:latest
                    """
                }
            }
        }

        stage('Generate imagedefinitions.json') {
            steps {
                script {
                    sh """
                        echo Writing imagedefinitions.json...
                        printf '[{"name":"%s","imageUri":"%s"}]' ${CONTAINER_NAME} ${ECR_URL}:${IMAGE_TAG} > imagedefinitions.json
                        cat imagedefinitions.json
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Successfully pushed ${ECR_URL}:${IMAGE_TAG} and ${ECR_URL}:latest"
            archiveArtifacts artifacts: 'imagedefinitions.json', onlyIfSuccessful: true
        }
        failure {
            echo "❌ Build failed!"
        }
    }
}
