# action-mirror-git

Synchronize git repositories like a mirror.

## Support

- [x] Any git server like GitHub, GitLab, BitBucket, Gitee etc.
- [x] Protocol under HTTPS and SSH
- [x] Sync branches, tags, commits, even Git LFS objects
- [x] Ignore specific repositories
- [x] Specify repositories without pushing tags
- [x] Auto create repository on the dest git server with custom script
- [x] Notify with Slack, DingTalk or Lark
- [x] Force push if failed

### Any git server

```yaml
# GitHub
source_host: github.com

# Self-hosted
source_host: git.example.com
source_port: 8443
```

### Protocol under HTTPS and SSH

```yaml
# HTTPS will use personal access token to authenticate, the token username is required on some git servers like Gitee
source_protocol: https
source_token: github-token-created-under-k8scat-account

# Gitee
# The source_username will be used as the token username if source_token_username is not specified
source_protocol: https
source_username: huayin-opensource
source_token: gitee-token-created-under-k8scat-account
source_token_username: k8scat

# SSH requires the private key to authenticate
dest_protocol: ssh
dest_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
  ...
  OOWdOkxLqLsiMAAAAEdGVzdAECAwQFBgc=
  -----END OPENSSH PRIVATE KEY-----
```

### Sync branches, tags, commits, even Git LFS objects

```yaml
# Branch and commits will be synced by default

# Sync tags
push_tags: "true"

# Sync Git LFS objects
enable_git_lfs: "true"
```

Refer to [Duplicating a repository](https://docs.github.com/cn/repositories/creating-and-managing-repositories/duplicating-a-repository).

### Ignore specific repositories

```yaml
# repo5 and repo6 will not be synced
ignored_repos: "repo5,repo6"
```

### Specify repositories without pushing tags

```yaml
# repo3 and repo4 will only sync branches and commits
skip_tags_repos: "repo3,repo4"
```

### Auto create repository

```yaml
# Custom script to create repository
dest_create_repo_script: |
  if ! gh auth status; then
    echo "${INPUT_DEST_TOKEN}" | gh auth login --with-token
    gh auth status
  fi
  repo="${INPUT_DEST_USERNAME}/${REPO_NAME}"
  found=$(gh repo list ${INPUT_DEST_USERNAME} -L 1000 --json name -t "{{range .}}{{if (eq .name \"${REPO_NAME}\")}}{{.name}}{{end}}{{end}}")
  if [[ -n "${found}" ]]; then
    echo "repo ${REPO_NAME} already exists"
    exit 0
  fi
  gh repo create "${INPUT_DEST_USERNAME}/${REPO_NAME}" --private

# Specify the script url to create repository
dest_create_repo_script: https://example.com/create_repo.sh
```

### Notify

```yaml
# Slack
slack_webhook: ${{ secrets.SLACK_WEBHOOK }}

# DingTalk
dingtalk_webhook: ${{ secrets.DINGTALK_WEBHOOK }}

# Lark
lark_webhook: ${{ secrets.LARK_WEBHOOK }}
```

### Force push

**Force push will delete the existed repository on the dest git server when push failed, then push again.**

```yaml
force_push: "true"
dest_delete_repo_script: |
  if ! gh auth status; then
    echo "${INPUT_DEST_TOKEN}" | gh auth login --with-token
    gh auth status
  fi
  gh repo delete "${INPUT_DEST_USERNAME}/${REPO_NAME}" --confirm
```

## Examples

- [GitHub Org to Gitee Org](./.github/workflows/github-org-to-gitee-org.yml)
- [GitHub to Gitee](./.github/workflows/github-to-gitee.yml)
- [GitHub to GitHub](./.github/workflows/github-to-github.yml)
- [GitHub to GitLab](./.github/workflows/github-to-gitlab.yml)
- [GitHub to BitBucket](./.github/workflows/github-to-bitbucket.yml)

## Run

```bash
docker run \
  --rm \
  -e INPUT_SOURCE_PROTOCOL="https" \
  -e INPUT_SOURCE_HOST="github.com" \
  -e INPUT_SOURCE_USERNAME="source_user" \
  -e INPUT_SOURCE_TOKEN="xxx" \
  -e INPUT_DEST_PROTOCOL="ssh" \
  -e INPUT_DEST_HOST="github.com" \
  -e INPUT_DEST_USERNAME="dest_user" \
  -e INPUT_DEST_PRIVATE_KEY="xxx" \
  -e INPUT_PUSH_TAGS="true" \
  -e INPUT_MIRROR_REPOS="repo1,repo2,repo3" \
  -e INPUT_IGNORED_REPOS="repo1" \
  -e INPUT_SKIP_TAGS_REPOS="repo2" \
  -e INPUT_DEST_CREATE_REPO_SCRIPT="xxx" \
  -e INPUT_SOURCE_PORT \
  -e INPUT_SOURCE_PRIVATE_KEY \
  -e INPUT_DEST_PORT \
  -e INPUT_DEST_TOKEN \
  -e INPUT_SLACK_WEBHOOK \
  -e INPUT_DINGTALK_WEBHOOK \
  -e INPUT_LARK_WEBHOOK="xxx" \
  -e INPUT_FORCE_PUSH="false" \
  -e INPUT_NOTIFY_PREFIX="Mirror Git" \
  -e INPUT_NOTIFY_SUFFIX="Powered by https://github.com/k8scat/action-mirror-git" \
  gigrator/mirror-git:0.0.27
```

## LICENSE

[MIT](./LICENSE)
