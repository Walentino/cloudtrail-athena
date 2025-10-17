| Phase | Timestamp (UTC) | Action | Description | Tool Used |
| --- | --- | --- | --- | --- |
| Validation | 2025‑10‑14 10:00 | GuardDuty alert | Alert triggered on anomalous EC2 activity | GuardDuty |
| Validation | 2025‑10‑14 10:05 | Verify via Athena | Ran `CreateAccessKey` and `AssumeRole` queries | Athena |
| Scope | 2025‑10‑14 10:30 | Expand search | Queried 3‑day CloudTrail window for compromised user | CloudTrail + Athena |
| Scope | 2025‑10‑14 10:45 | Detect cryptomining | Identified GPU instance launches and unusual IP addresses | Athena |
| Impact | 2025‑10‑14 11:00 | Confirm workload | Correlated CPU spikes with cryptomining activity | CloudWatch |
| Containment | 2025‑10‑14 11:30 | Isolate instances | Created `IsolationSG` and attached to affected EC2s | AWS CLI |
| Containment | 2025‑10‑14 11:45 | Disable keys | Revoked compromised IAM access keys and blocked attacker IPs | IAM |
| Eradication | 2025‑10‑14 12:00 | Remove resources | Terminated rogue EC2 instances and deleted backdoor policies | AWS Console |
| Recovery | 2025‑10‑14 13:00 | Restore services | Rebuilt hosts from AMIs and rotated all IAM credentials | CloudFormation |
| Post‑Incident | 2025‑10‑15 09:00 | Review & automate | Held lessons‑learned meeting and added EventBridge alerts | Team review |

### Lessons Learned

- **Proactive monitoring matters:** enabling GuardDuty and Security Hub allowed early detection of cryptomining indicators.
- **Network segmentation is essential:** quickly isolating affected instances via a dedicated security group prevented further damage.
- **Credential hygiene must be automated:** regular key rotation and MFA enforcement would have reduced exposure.
- **Automation accelerates response:** EventBridge rules and Lambda functions can orchestrate containment and notifications.
- **Post‑mortem drives improvement:** documenting findings ensures playbooks evolve and training addresses new threat patterns.
