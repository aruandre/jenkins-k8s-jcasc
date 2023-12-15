Jenkins on k8s (minikube) with Jenkins set up as code using the JCasC plugin, infra built with Terraform and Helm provider.  

Jenkins uses a custom built image which has required plugins pre-installed. The image is built using Github Actions and pushed to Dockerhub. After building the image, it is also scanned for vulnerabilities using Trivy and the scan results are published to the same repository.

For monitoring purposes Prometheus and Grafana are deployed onto a separate "monitoring" namespace. Grafana sets up two dashboards for Kubernetes cluster and Jenkins respectivelly.

Some TODOs:
* password management
  * authentication & authorization
* SSL and https
* logging
* shared library