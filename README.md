# Trivy CI demo — Terraform misconfigs + ignorefile placement

This repo is a **pipeline-only** Trivy test (no local Trivy CLI required).

## Layout

```
.
├── .github/workflows/trivy.yml   # PR / push scan
├── .trivyignore.yaml             # MUST live at repo root (see below)
└── terraform/                    # intentional insecure AWS Terraform
```

## Where to put `.trivyignore.yaml`

| Location | Works in this CI? | Why |
|---|---|---|
| **Repo root** `.trivyignore.yaml` | Yes | Matches `scan-ref: .` and `TRIVY_IGNOREFILE: .trivyignore.yaml` |
| `terraform/.trivyignore.yaml` | No (with current workflow) | Workflow looks at root; missing file → **FATAL** exit |
| `.github/.trivyignore.yaml` | Only if you change `TRIVY_IGNOREFILE` | Path must match exactly what CI sets |
| Using action input `trivyignores: .trivyignore.yaml` | Broken | Action copies YAML into a plaintext temp ignore file |

**Rule:** put the YAML ignore file at the path your workflow sets in `TRIVY_IGNOREFILE`, and commit that file. YAML ignores are experimental and are **not** auto-loaded.

## What the PR check does

1. Checks out the PR
2. Runs `trivy config` on `.` (finds Terraform misconfigs)
3. Applies suppressions from `.trivyignore.yaml`
4. Fails the job if remaining CRITICAL/HIGH/MEDIUM findings exist (`exit-code: 1`)

## Terraform

Resources under `terraform/` are deliberately insecure (public S3, open SG, unencrypted RDS/EBS, weak IAM password policy, etc.) so Trivy reports **10+** misconfiguration IDs.
