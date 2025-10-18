pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '779846799257'
        REPO_NAME = 'react-app-repo'
        // IMAGE_TAG will be dynamically set in the script section
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
                    // Use Jenkins build number as image tag
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                    echo "Using IMAGE_TAG: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${REPO_NAME}:${IMAGE_TAG}"
                    sh "docker build -t $REPO_NAME:$IMAGE_TAG ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    echo "Logging in to Amazon ECR: $AWS_ACCOUNT_ID in region $AWS_REGION"
                    sh """
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin \
                        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    """
                }
            }
        }

        stage('Tag & Push Image') {
    steps {
        script {
            def versionedImage = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"
            def latestImage = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest"

            // Push versioned image
            echo "Tagging and pushing versioned image: $versionedImage"
            sh """
                docker tag $REPO_NAME:$IMAGE_TAG $versionedImage
                docker push $versionedImage
            """

            // Push latest tag
            echo "Tagging and pushing latest image: $latestImage"
            sh """
                docker tag $REPO_NAME:$IMAGE_TAG $latestImage
                docker push $latestImage
            """
        }
    }
}

    }

    post {
        always {
            echo '✅ Pipeline execution completed!'
        }
    }
}
