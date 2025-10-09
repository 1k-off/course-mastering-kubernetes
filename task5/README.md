# Install kyverno
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo update
helm install kyverno kyverno/kyverno --set features.policyExceptions.enabled=true -n kyverno --create-namespace 
helm install policy-reporter policy-reporter/policy-reporter --create-namespace -n policy-reporter --set ui.enabled=true --set kyverno-plugin.enabled=true
kubectl port-forward service/policy-reporter-ui 8080:8080 -n policy-reporter
kubectl apply -f kyverno.d/service_type.yaml
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=NodePort --port=80 # error
kubectl label deployment nginx service-type-policy-bypass=true
kubectl expose deployment nginx --type=NodePort --port=80 # success
```