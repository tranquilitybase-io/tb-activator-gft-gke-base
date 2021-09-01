pipeline
{
    agent {
        kubernetes {
          label 'kubepod'
          defaultContainer 'gcloud'
        }
    }
    environment {
        def DockerHome = tool name: 'docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'
        def DockerCMD = "${DockerHome}/bin/docker"
        def activator_params = "${activator_params}"
        def environment_params = "${environment_params}"
        def terraform_output = ""
    }
    stages {
        stage('Activate GCP Service Account and Set Project') {
            steps {
                container('gcloud'){
                sh '''
                    cd /var/secrets/google/
                    ls
                    cat ./ec-service-account-config.json
                    cd ../../..
                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                    gcloud config set project $projectid
                '''
                }
            }
        }
        stage('Enable Required Google APIs') {
            steps {
                container('gcloud'){
                    script {
                           echo "skip - no activator metadata"
//                         def activator_metadata = readYaml file: ".tb/activator_metadata.yml"
//                         echo "activator_metadata map ${activator_metadata}"
//                         def gcpApisRequired = activator_metadata.get('gcpApisRequired')
//                         if (gcpApisRequired) {
//                             gcpApisRequired.each {
//                                 echo "Enabling $it"
//                                 sh "gcloud services enable $it"
//                             }
//                         }
                    }
                }
            }
        }
        stage('Setup Terraform') {
            steps {
                container('gcloud'){
                    sh "apt-get update && apt-get upgrade -y && apt-get install -y python3 wget unzip jq"
                    sh "wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip"
                    sh "unzip ./terraform_0.12.24_linux_amd64.zip"
                    sh "mv terraform /usr/bin/ && rm -f terraform_0.12.24_linux_amd64.zip"
                    sh "mkdir deployment_code"
                    sh "cp deployment/*.tf deployment_code/"
                    sh "echo \$activator_params | jq '.' > deployment_code/activator_params.json"
                    sh "cat deployment_code/activator_params.json"
                    sh "echo \$environment_params | jq '.' > deployment_code/environment_params.json"
                    sh "cat deployment_code/environment_params.json"
                }
            }
        }
        stage('Activator Terraform init validate plan') {
            steps {
                container('gcloud'){
//                     sh "cd /var/secrets/google/"
//                     sh "ls"
//                     sh "cat ./ec-service-account-config.json"
                    sh "cat /var/secrets/google/ec-service-account-config.json && gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS && terraform init deployment"
//                     sh "cd ../../.."
//                     sh "ls -ltr"
//                     sh "terraform init deployment"
//                     sh "terraform validate deployment/"
//                     sh "terraform plan -out activator-plan -var='host_project_id=$projectid' -var-file=deployment_code/activator_params.json -var-file=deployment_code/environment_params.json deployment_code/"
                }
            }
        }
        stage('Activator Infra Deploy') {
            steps {
                sh "terraform apply  --auto-approve activator-plan"
                sh "terraform output -json > activator_outputs.json"
                script {
                    terraform_output = sh (returnStdout: true, script: 'cat activator_outputs.json').trim()
                    echo "Terraform output : ${terraform_output}"
                    archiveArtifacts artifacts: 'activator_outputs.json'
                }
            }
        }
    }
}
