# Pending Pod caused by scheduling restrictions

## Scenario
Cordoned the only worker, then created a temporary test Pod.

## Observed behavior
Existing Nginx Pods continued running.
The new test Pod remained Pending.

## Diagnosis
Pod Events reported:
- One node had an untolerated taint: the control plane.
- One node was unschedulable: the cordoned worker.

## Recovery
Uncordoned the worker.
The test Pod was scheduled and became Ready.
Deleted the test Pod afterward.

## Lesson
Cordon blocks new scheduling without evicting existing Pods.
A second application replica on the same worker does not
protect against worker failure or maintenance downtime.
