-- Query 1: Detect IAM access key creation events
-- Purpose: identify when new access keys are created, which can indicate credential misuse or provisioning mistakes.
SELECT
    eventTime,
    userIdentity.arn AS principalArn,
    requestParameters.accessKeyId
FROM cloudtrail_logs
WHERE eventName = 'CreateAccessKey'
ORDER BY eventTime DESC;

-- Query 2: Detect AssumeRole operations from external IP addresses
-- Purpose: find role assumptions originating from IP ranges outside the corporate network (non‑RFC1918), which may signal lateral movement.
SELECT
    eventTime,
    userIdentity.arn AS principalArn,
    sourceIPAddress,
    eventName
FROM cloudtrail_logs
WHERE eventName = 'AssumeRole'
  AND (
        sourceIPAddress NOT LIKE '10.%'
        AND sourceIPAddress NOT LIKE '172.16.%'
        AND sourceIPAddress NOT LIKE '192.168.%'
      )
ORDER BY eventTime DESC;

-- Query 3: Detect EC2 instance launches with GPU instance types
-- Purpose: surface launches of compute‑intensive instance types often abused for cryptomining (e.g., g4dn, p2, p3).
SELECT
    eventTime,
    eventName,
    requestParameters.instanceType,
    userIdentity.arn AS principalArn
FROM cloudtrail_logs
WHERE eventName = 'RunInstances'
  AND (
        requestParameters.instanceType LIKE '%g%'
        OR requestParameters.instanceType LIKE '%p%'
      )
ORDER BY eventTime DESC;

-- Query 4: Detect privilege escalation attempts via policy changes
-- Purpose: monitor for attachment of managed policies or inline policies that could elevate privileges.
SELECT
    eventTime,
    userIdentity.arn AS principalArn,
    eventName,
    requestParameters.policyArn,
    requestParameters.userName
FROM cloudtrail_logs
WHERE eventName IN ('AttachUserPolicy', 'PutUserPolicy')
ORDER BY eventTime DESC;

-- Query 5: Detect high‑frequency API calls per principal over the last 24 hours
-- Purpose: identify accounts or roles making an unusually large number of API calls, which may indicate automation, brute forcing or credential misuse.
SELECT
    userIdentity.arn AS principalArn,
    COUNT(*) AS apiCallCount
FROM cloudtrail_logs
WHERE eventTime >= date_add('day', -1, current_timestamp)
GROUP BY userIdentity.arn
HAVING COUNT(*) > 500
ORDER BY apiCallCount DESC;
