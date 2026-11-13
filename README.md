# IS 3033 Lab 06: Containers and DevSecOps

A tiny status service, a container to run it in, and a gate script that refuses to pass until the container is built safely.

## What is in this repository

| File | What it is |
|---|---|
| `app.py` | A small web service written with the Python standard library. It reports what the process serving the page looks like: which user it runs as, which OS userland and kernel it sees, whether it is inside a container, and whether a secret is in its environment. |
| `Dockerfile` | The recipe that builds the container image. The starter version is deliberately wrong in three ways. Your job is to fix it. |
| `check.sh` | The gate. It runs the Dockerfile linter (hadolint), a misconfiguration scan (Trivy), builds the image, sends it one HTTP request, and counts vulnerabilities in the image. It exits red until all gates pass. `./check.sh --fast` runs only the two scans, in seconds; the lab installs that as a git pre-commit hook. |
| `.github/workflows/scan.yml` | The same gates written for GitHub Actions, for anyone who wants to run them in the cloud. Not required for the lab. |
| `.dockerignore` | Files that must never be copied into the image. |

## Run it

```bash
docker build -t lab06 .
docker run -d --rm --name lab06 -p 8080:8080 lab06
curl http://localhost:8080/
docker stop lab06
```

## Check it

```bash
./check.sh          # full run
./check.sh --fast   # scans only
```

## What I changed and why

Fill in this table as you harden the Dockerfile in Step 4 of the lab. One row per change. Name the tool that reported the problem (hadolint or Trivy) and the rule ID it printed.

| Change | Reported by (tool and rule) | Why it matters |
|---|---|---|
| | | |
| | | |
| | | |

## Vulnerability count

Record the CRITICAL and HIGH counts and the image size from step 5 of `check.sh`.

| Image | CRITICAL | HIGH | Image size |
|---|---|---|---|
| Before (starter Dockerfile) | | | |
| After (your hardened Dockerfile) | | | |

## Run-time hardening

List the `docker run` options you added in Step 4 and what each one takes away from the container.

---

Course material for IS 3033 Operating Systems Security (University of Texas at San Antonio), by Rita Mitra, licensed [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
