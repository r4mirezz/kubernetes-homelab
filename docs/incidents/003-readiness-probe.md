# Failed rollout: readiness check returned 404

## Scenario
Changed the readiness probe path from / to /not-found.

## Observed behavior
The new container started, but its Pod remained 0/1 Ready.
The existing two ready Pods remained available.

## Diagnosis
kubectl describe pod showed:
Readiness probe failed: HTTP probe failed with statuscode: 404

Nginx was running, but the configured check URL did not exist.
Readiness failure did not restart the container.

## Recovery
Reapplied apps/hello-web/deployment.yaml to restore the path /.

## Verification
The faulty Pod was removed.
Two Pods showed 1/1 Running with zero restarts.

## Prevention
Validate health-check paths before release.
Verify rollout completion and test requests through the Service.
