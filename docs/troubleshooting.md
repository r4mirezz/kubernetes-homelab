# Troubleshooting checklist

## 1. Check application Pods
kubectl get pods -n training -o wide

Running does not necessarily mean Ready.

## 2. Inspect a failing Pod
kubectl describe pod POD_NAME -n training

Read Events for image, scheduling, and health-check failures.

## 3. Check Service routing
kubectl describe service hello-web -n training

Compare its selector with Pod labels.
Check that backend endpoints exist.

## 4. Read recent application logs
kubectl logs -n training -l app=hello-web \
  --prefix=true --since=10m --tail=-1

Use the Pod prefix to identify which replica handled a request.

## 5. Interpret the evidence
- ImagePullBackOff: inspect image download errors.
- Running but not Ready: inspect readiness checks.
- No ready Service endpoints: inspect selectors and Pod readiness.
- HTTP 404 recorded by the application: inspect routes or files.

## 6. Recover and verify
Restore the intended configuration from version-controlled manifests.
Check rollout completion and make a request through the Service.
