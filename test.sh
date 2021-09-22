

def activator_metadata = readYaml file: ".tb/activator_metadata.yml"
echo "activator_metadata map ${activator_metadata}"
def gcpApisRequired = activator_metadata.get('gcpApisRequired')
if (gcpApisRequired) {
    gcpApisRequired.each {
        echo "Enabling $it"
        sh "gcloud services enable $it"
    }
}