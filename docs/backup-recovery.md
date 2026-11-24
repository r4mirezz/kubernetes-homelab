# PostgreSQL backup and recovery

## Configuration

- Database: support_desk
- Namespace: training
- PostgreSQL StatefulSet: postgres
- CronJob: postgres-backup
- Schedule: daily at 02:00 UTC
- S3 bucket: ramy-homelab-backups-20261124-1047
- Object prefix: support-desk/
- Backup format: PostgreSQL custom archive
- S3 retention: seven days
- Incomplete multipart uploads: removed after one day

The backup Job uses the application database user for pg_dump.
The uploader uses the control-plane EC2 IAM role.

Backups contain database objects and data, but not PostgreSQL
role passwords, Kubernetes Secrets, or cluster configuration.

## Check backup execution

```bash
kubectl get cronjob postgres-backup -n training
kubectl get jobs -n training --sort-by=.metadata.creationTimestamp
```

For a selected Job, inspect both stages:

```bash
kubectl logs job/JOB_NAME -n training -c dump
kubectl logs job/JOB_NAME -n training -c upload
```

Confirm a recent .dump object also exists in S3.
A successful upload alone does not prove the backup can be restored.

## Run an additional backup

```bash
kubectl create job "postgres-backup-manual-$(date -u +%Y%m%d%H%M%S)" \
  --from=cronjob/postgres-backup -n training
```

## Restore test

1. Download a selected .dump file using the S3 console.
2. Copy it to ~/homelab-backups/ on the control-plane.
3. Ensure the required PostgreSQL roles exist.
4. Restore into a NEW test database, never directly over the live database.

```bash
kubectl exec postgres-0 -n training -- \
  createdb -U postgres support_desk_restore_check

kubectl exec -i postgres-0 -n training -- \
  pg_restore -U postgres -d support_desk_restore_check \
  --exit-on-error < ~/homelab-backups/SELECTED_BACKUP.dump

kubectl exec postgres-0 -n training -- \
  psql -U postgres -d support_desk_restore_check \
  -c "SELECT id, title, status FROM public.tickets ORDER BY id;"
```

Replace SELECTED_BACKUP.dump with the downloaded filename.
After verification, remove only the test database:

```bash
kubectl exec postgres-0 -n training -- \
  dropdb -U postgres support_desk_restore_check
```

## Limitations

- One database instance; no high availability.
- Successful daily backups can leave roughly 24 hours of changes at risk.
- Backups cannot run while the required cluster components are unavailable.
- S3 expires old backups even if new backups stop.
- No automatic failure or missing-backup alerts are configured yet.
- Preserve credentials separately; never commit them to Git.

## Tests completed

- Tickets survived replacement of postgres-0.
- A local dump restored successfully into a separate database.
- A backup uploaded to S3 was downloaded and restored successfully.
- A backup copied to the Windows PC had a matching SHA-256 checksum.
