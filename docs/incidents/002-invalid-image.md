# Failed release: invalid image tag

## Scenario
Updated the Deployment to nginx:homelab-invalid-version,
an intentionally nonexistent image tag.

## Observed behavior
The replacement Pod entered ImagePullBackOff.
The two existing healthy Pods remained running.

## Diagnosis
Inspected the failing Pod using kubectl describe pod.
Events reported that the image tag was not found.

## Recovery
Reapplied apps/hello-web/deployment.yaml, which specified
nginx:1.30.7.

## Verification
The failed Pod was removed.
Two healthy Pods remained, with zero restarts.

## Prevention
Verify that an image exists before deploying it.
Use CI to build and publish images before updating deployment
configuration, then verify rollout completion.
