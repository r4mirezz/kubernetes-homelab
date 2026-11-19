# Service could not reach Nginx

## Scenario
Deliberately changed the hello-web Service selector in a lab.

## Impact
The Service had no backend endpoints, although the Nginx Pod
remained running.

## Investigation
Used kubectl describe service and inspected Pod labels.

The Service selected app=hello-web-typo.
The Pod was labelled app=hello-web.
No Pods matched the selector.

## Recovery
Reapplied apps/hello-web/service.yaml to restore the selector.

## Verification
Confirmed the Service endpoint returned.
Requested http://hello-web from a temporary Pod and received
the Nginx welcome page.

## Prevention
Review selector changes against Pod labels and test connectivity
through the Service after deployment.
