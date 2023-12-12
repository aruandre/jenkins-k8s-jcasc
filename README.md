Jenkins on k8s (minikube) with Jenkins set up as code using the JCasC plugin, infra built with Terraform and Helm.  

Jenkins uses a custom built image which has required plugins pre-installed. The image is built using Github Actions and pushed to Dockerhub.

Some TODOs:
* authentication
* SSL and https
* shared library