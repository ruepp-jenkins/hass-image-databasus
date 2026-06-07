# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Wraps `databasus/databasus` (from Docker Hub) to make it compatible with the HomeAssistant add-on structure. The output image is published to `ruepp/hassio-image-databasus` on Docker Hub.

## Build pipeline

The pipeline is Jenkins-driven (`Jenkinsfile`). It runs on a cron schedule (`H/30 * * * *`) — never on git push. The full build flow:

```
start.sh
  → docker_initialize.sh     # docker login (Docker Hub), buildx setup
  → get_upstream_version.sh  # fetch latest vX.Y.Z tag from Docker Hub
  → [skip if not newer than latest_version.txt]
  → docker_build.sh          # docker buildx build --push
  → commit_version.sh        # write latest_version.txt, git commit + push
  → docker_cleanup.sh        # buildx prune
```

## Version tracking

- **Upstream version source**: Docker Hub tags on `databasus/databasus`, filtered for `v\d+\.\d+\.\d+`, sorted by semver. The `v` prefix is stripped so `VERSION=3.42.0`.
- **Base image**: `databasus/databasus:v${VERSION}` (Docker Hub, `v`-prefixed).
- **Output tags**: `ruepp/hassio-image-databasus:latest`, `:${VERSION}`, `:${VERSION}-${DATESTAMP}` (e.g. `3.42.0-20260607`). Non-main branches get `-test:${BRANCH_NAME}` instead of `latest`.
- **Skip logic**: `latest_version.txt` (committed in repo) holds the last successfully built version. Build is skipped if the upstream version is not strictly newer.

## Jenkins credentials required

| Credential ID | Type | Used for |
|---|---|---|
| `DOCKER_API_PASSWORD` | Secret text | Docker Hub push login |
| `github.com-ssh` | SSH private key | Git checkout + push back of `latest_version.txt` |

The SSH key is surfaced to shell scripts via `withCredentials([sshUserPrivateKey(...)])` + `withEnv(["GIT_SSH_COMMAND=ssh -i ..."])` in the Build stage — this is what allows `git push` inside `commit_version.sh` to authenticate without any credential handling in the scripts themselves.

## Key env vars (set by Jenkins / start.sh)

- `IMAGE_FULLNAME` — `ruepp/hassio-image-databasus`
- `BRANCH_NAME` — injected by Jenkins
- `VERSION`, `DATESTAMP`, `BASE_IMAGE` — exported by `start.sh` before calling sub-scripts
- `DOCKER_USERNAME` — expected on the Jenkins agent (node-level env var)
