# IS 3033 Lab 06: Containers and DevSecOps

![Build, scan, and test](https://github.com/OWNER/REPO/actions/workflows/scan.yml/badge.svg)

A tiny status service, a container to run it in, and a pipeline that refuses to stay green until the container is built safely.

**Replace `OWNER/REPO` in the badge line above with your own GitHub username and repository name.** The badge turns red or green with your latest push.

## What is in this repository

| File | What it is |
|---|---|
| `app.py` | A small web service written with the Python standard library. It reports what the process serving the page looks like: which user it runs as, which OS userland and kernel it sees, whether it is inside a container, and whether a secret is in its environment. |
| `Dockerfile` | The recipe that builds the container image. The starter version is deliberately wrong in three ways. Your job is to fix it. |
| `.github/workflows/scan.yml` | The pipeline. It runs on every push: lint the Dockerfile, scan it for misconfigurations, scan the repository for secrets, build the image, smoke-test it, and count vulnerabilities in the image. |
| `.dockerignore` | Files that must never be copied into the image. |

## Run it

```bash
docker build -t lab06 .
docker run -d --rm --name lab06 -p 8080:8080 lab06
curl http://localhost:8080/
docker stop lab06
```

## What I changed and why

Fill in this table as you harden the Dockerfile in Step 4 of the lab. One row per change. Name the tool that reported the problem (hadolint or Trivy) and the rule ID it printed.

| Change | Reported by (tool and rule) | Why it matters |
|---|---|---|
| | | |
| | | |
| | | |

## Vulnerability count

Record the CRITICAL and HIGH counts from step 5 of the pipeline (the report-only step).

| Image | CRITICAL | HIGH | Image size |
|---|---|---|---|
| Before (starter Dockerfile) | | | |
| After (your hardened Dockerfile) | | | |

## Run-time hardening

List the `docker run` options you added in Step 4 and what each one takes away from the container.

---

Course material for IS 3033 Operating Systems Security (University of Texas at San Antonio), by Rita Mitra, licensed [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
