# Incident Response with CloudTrail and Athena

## 🧭 Overview

This lab demonstrates the full lifecycle of an IAM credential compromise leading to EC2 cryptomining. The scenario simulates an attacker obtaining access keys for an IAM user and launching GPU‑intensive EC2 instances for cryptojacking. Using native AWS services — CloudTrail, Athena, GuardDuty, Security Hub and IAM — we detect, analyze, contain and remediate the breach. The objective is to reinforce the incident response phases: Preparation, Detection & Analysis, Containment & Eradication, Recovery and Post‑Incident Activity【815268223646209†L0-L10】.

Key goals:

- Identify vulnerabilities and exploit techniques.
- Understand attacker’s intent and attribution.
- Assess business and environmental impact.
- Recover systems to their hardened baseline.

## 👩🏽‍💻 Common IAM Roles Used

| Role | Purpose |
| --- | --- |
| `SecurityAnalystRole` | Run Athena queries and investigate CloudTrail logs【815268223646209†L11-L17】 |
| `SecurityDeployRole` | Redeploy secured resources via CloudFormation or infrastructure‑as‑code pipelines【815268223646209†L17-L21】 |
| `SecurityBreakGlassRole` | Emergency actions to contain and eradicate threats without requiring root privileges【815268223646209†L17-L22】 |

## ⚙️ Environment Setup

- CloudTrail enabled across all regions with logs stored in S3【815268223646209†L24-L27】.
- Athena configured with a database and table pointing at the CloudTrail log bucket【815268223646209†L26-L28】.
- A simulated compromised IAM user and EC2 instance deployed to recreate the attack chain【815268223646209†L28-L30】.
- GuardDuty and Security Hub enabled for automated threat detection and alert correlation【815268223646209†L30-L31】.

## 🧩 Incident Response Steps

*Validation*:

- Respond to GuardDuty findings that flag anomalous EC2 behaviour and IAM key misuse【815268223646209†L33-L36】.
- Use Athena to verify the alert by querying for suspicious `CreateAccessKey` and `AssumeRole` events【815268223646209†L37-L39】.
- Identify access from non‑approved IP ranges and detect high‑volume API calls【815268223646209†L41-L41】.

*Scope*:

- Query CloudTrail logs for the last three days of activity related to the compromised user【815268223646209†L42-L46】.
- Detect EC2 launches using GPU‑class instance types (a hallmark of cryptomining)【815268223646209†L47-L48】.
- Trace lateral movement through additional `AssumeRole` and `PutUserPolicy` events【815268223646209†L48-L50】.

*Impact*:

- Correlate CPU usage spikes on affected EC2 instances to confirm cryptomining workloads【815268223646209†L52-L54】.
- Estimate cost impacts and confirm that no sensitive data was exfiltrated【815268223646209†L53-L56】.

Throughout the analysis, iterate between these stages to refine the incident scope and update your response plan.

## 🔍 Detection Queries (Athena)

The `queries.sql` file contains sample Athena SQL statements used during the investigation. They detect anomalous IAM key creation, role assumptions from external IP ranges, cryptomining instance launches, privilege‑escalation events and high‑frequency API calls. Each query is commented to explain its detection purpose. See [queries.sql](./queries.sql) for details.

## 💥 Key Findings & Analysis

- Unauthorized `CreateAccessKey` events originated from unknown IP addresses, indicating credential leakage.
- Multiple `AssumeRole` operations were executed from external networks, suggesting lateral movement across accounts.
- GPU‑class EC2 instances (e.g. p2.xlarge, g4dn.xlarge) were launched and quickly consumed high CPU resources, consistent with cryptomining【815268223646209†L52-L54】.
- Additional IAM policies were attached using `PutUserPolicy`, demonstrating privilege escalation attempts.
- GuardDuty findings correlated with CPU spikes and unusual API call patterns, confirming active cryptojacking.

These observations informed the containment and eradication plan.

## 🧱 Containment & Eradication

- Created an isolation security group with no ingress or egress to quarantine affected instances【815268223646209†L75-L79】.
- Applied the isolation group to compromised EC2 instances to halt outbound mining traffic【815268223646209†L79-L81】.
- Disabled compromised access keys and deleted attacker‑created IAM users【815268223646209†L81-L81】.
- Eradicated persistence mechanisms, including unauthorized policies, roles and backdoors.
- Coordinated with infrastructure teams to identify and destroy rogue instances and volumes.

## ♻️ Recovery & Post‑Incident Activity

- Rebuilt affected EC2 instances from known‑good Amazon Machine Images (AMIs)【815268223646209†L83-L85】.
- Rotated all IAM credentials and enforced multi‑factor authentication across the organization【815268223646209†L86-L87】.
- Updated EventBridge rules to notify the incident response team on future `CreateAccessKey` events【815268223646209†L88-L90】.
- Added custom Security Hub and GuardDuty detection rules for IAM anomalies【815268223646209†L90-L91】.
- Performed a post‑mortem to improve detection rules, response playbooks and automation.

## 🧠 Lessons Learned

- Automate IAM credential hygiene; enforce key rotation and use roles rather than long‑lived access keys【815268223646209†L93-L97】.
- CloudTrail combined with Athena provides scalable detection and forensic capabilities【815268223646209†L93-L99】.
- GuardDuty findings should trigger automatic containment workflows to reduce dwell time【815268223646209†L98-L99】.
- Invest in automation (e.g. Lambda functions, EventBridge rules) to shorten response times【815268223646209†L99-L100】.
- Regularly validate backups and disaster recovery plans to minimize downtime.

## 📚 References

- CYBR course – *Incident Response with CloudTrail Lake & Athena*【815268223646209†L103-L106】.
- AWS Security Incident Response playbooks【815268223646209†L103-L106】.
- NIST SP 800‑61r2 – *Computer Security Incident Handling Guide*【815268223646209†L106-L108】.
- [Incident Response Playbook: EC2 Cryptojacking infographic](/screenshots/ir-playbook-ec2_cryptojacking-v2-858x1024.jpeg) (visual summary).

## 💬 Mentor Reflection

As your mentor, I’m impressed by how you navigated the incident response lifecycle. You not only detected the compromise using Athena queries and GuardDuty findings, but also contained the attack without causing additional downtime. Going forward, focus on automating repetitive tasks (key rotation, isolation) and enriching your alerts with context. Incorporate the insights from this lab into your broader detection engineering work — for example, building Athena notebooks to track anomalies and integrating them into your CI/CD pipeline. Continued practice with realistic scenarios like this will strengthen your skills as a cloud security engineer and entrepreneur.

## 🗂️ Repository Structure

```text
/cloudtrail-athena/
└── cybr-lab-incident-response/
    ├── README.md              – this report
    ├── queries.sql            – Athena detection queries
    ├── incident_timeline.md   – investigation timeline and lessons learned
    └── screenshots/
        ├── cloudtrail-athena-query-results.png
        ├── guardduty-alert.png
        ├── isolation-sg-applied.png
```

## 🏷️ Tags

`AWS`, `CloudTrail`, `Athena`, `IAM`, `GuardDuty`, `Security Hub`, `Incident Response`, `Cryptomining`, `Detection Engineering`
