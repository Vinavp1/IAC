pipeline {
    agent any

    parameters {
        booleanParam(defaultValue: true,description: 'Delete existing Lambda function before deploying?',name: 'DELETE_EXISTING_LAMBDA')
        choice(name: 'DEPLOY_STAGE', choices: ['staging', 'production'], description: 'Select the deployment stage')
        string(name: 'ARTIFACTS_BUCKET', defaultValue: 'cradlewise-artifacts-buck', description: 'Enter the S3 bucket for artifacts')
        string(name: 'ARTIFACTS_PREFIX', defaultValue: 'cradlewise-prefix', description: 'Enter the S3 prefix for artifacts')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        STACK_NAME         = "cradlewise-sam-app-${params.DEPLOY_STAGE}"
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        LAMBDA_FUNCTION_NAME = "Credlewise-Lambda-Function-SAM-New"
    }

    stages {
        stage('Unit Test') {
            steps {
                script {
                    dir ('aws-sam/python') {
                        bat 'python -m unittest hellopy_sam_unittest.py'
                    }
                }
            }
        }
        
        stage('Package Application') {
            steps {
                script {
                        bat "sam build"
                        bat "sam package --s3-bucket ${params.ARTIFACTS_BUCKET} --s3-prefix ${params.ARTIFACTS_PREFIX} --output-template-file template-out.yaml"
                }
            }
        }

        stage('Delete existing Lambda function') {
            when {
                expression { params.DELETE_EXISTING_LAMBDA }
            }
            steps {
                script {
                    def lambdaExists = bat(script: "aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME --region $AWS_DEFAULT_REGION", returnStatus: true) == 0
                    // Delete existing Lambda function if it exists
                    if (lambdaExists) {
                        bat "aws lambda delete-function --function-name $LAMBDA_FUNCTION_NAME --region $AWS_DEFAULT_REGION || true"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                        bat "sam deploy --template-file template-out.yaml --stack-name $STACK_NAME --parameter-overrides ParameterKey=Stage,ParameterValue=${params.DEPLOY_STAGE} --capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset --region $AWS_DEFAULT_REGION"
                }
            }
        }
    }
}