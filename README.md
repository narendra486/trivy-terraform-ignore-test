# Trivy CI demo — Terraform misconfigs + ignorefile placement

This repo is a **pipeline-only** Trivy test (no local Trivy CLI required).

## Layout

```
.
├── .github/workflows/trivy.yml            # PR / push scan
├── .github/workflows/.trivyignore.yaml    # ignorefile (path must match TRIVY_IGNOREFILE)
└── terraform/                             # intentional insecure AWS Terraform
```

## Where to put `.trivyignore.yaml`

| Location | Works? | Notes |
|---|---|---|
| `.github/workflows/.trivyignore.yaml` | **Yes (current)** | Matches `TRIVY_IGNOREFILE: .github/workflows/.trivyignore.yaml` |
| Repo root `.trivyignore.yaml` | Yes, if you change env to match | Path must equal what CI sets |
| Wrong/missing path while env is set | **No** | Trivy exits **FATAL** |

**Rule:** put the YAML ignore file at the exact path in `TRIVY_IGNOREFILE`. YAML ignores are experimental and are **not** auto-loaded. Finding `paths:` inside the file stay relative to `scan-ref` (repo root), not the ignore file folder.

## What the PR check does

1. Checks out the PR
2. Runs `trivy config` on `.` (finds Terraform misconfigs)
3. Applies suppressions from `.github/workflows/.trivyignore.yaml`
4. Fails the job if remaining CRITICAL/HIGH/MEDIUM findings exist (`exit-code: 1`)

## Terraform

Resources under `terraform/` are deliberately insecure (public S3, open SG, unencrypted RDS/EBS, weak IAM password policy, etc.) so Trivy reports **10+** misconfiguration IDs.
