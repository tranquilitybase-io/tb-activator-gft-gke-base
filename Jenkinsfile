pipeline
{
    agent {
        kubernetes {
          label 'kubepod'
          defaultContainer 'gcloud'
        }
    }
    environment {
        def activator_params = ""
        def environment_params = ""
        def terraform_output = ""
    }
    stages {
        stage('Activate GCP Service Account and Set Project') {
            steps {
                withCredentials([string(credentialsId: 'Release-Project-ID', variable: 'PROJECT_ID')]) {
                    container('gcloud'){
                        sh '''
                            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                            gcloud config set project ${PROJECT_ID}

                            gsutil ls -b gs://${PROJECT_ID}_state || gsutil mb -l europe-west1 gs://${PROJECT_ID}_state
                        '''
                    }
                }
            }
        }
        stage('Enable Required Google APIs') {
            steps {
                container('gcloud'){
                    script {
                        def activator_metadata = readYaml file: ".tb/activator_metadata.yml"
                        echo "activator_metadata map ${activator_metadata}"
                        def gcpApisRequired = activator_metadata.get('gcpApisRequired')
                        if (gcpApisRequired) {
                            gcpApisRequired.each {
                                echo "Enabling $it"
                                sh "gcloud services enable $it"
                            }
                        }
                    }
                }
            }
        }
        stage('Setup Terraform') {
            steps {
                container('gcloud'){
                    sh "apt-get update && apt-get upgrade -y && apt-get install -y python3 wget unzip jq"
                    sh "wget https://releases.hashicorp.com/terraform/0.14.11/terraform_0.14.11_linux_amd64.zip"
                    sh "unzip ./terraform_0.14.11_linux_amd64.zip"
                    sh "mv terraform /usr/bin/ && rm -f terraform_0.14.11_linux_amd64.zip"
                    sh "mkdir deployment_code"
                    sh "cp deployment/*.* deployment_code/"
                }
            }
        }
        stage('Activator Terraform init validate plan') {
            steps {
                withCredentials([string(credentialsId: 'Release-Project-ID', variable: 'PROJECT_ID')]) {
                    container('gcloud'){
                        sh '''
                            echo "$PROJECT_ID"
                            terraform init deployment_code
                            terraform validate deployment_code/
                            '''
                        sh "terraform plan -out activator-plan -var='project_id=$PROJECT_ID' -var-file=deployment_code/environment_params.json deployment_code/"
                        sh "terraform apply --auto-approve activator-plan"
                    }
                }
            }
        }
    }
}
