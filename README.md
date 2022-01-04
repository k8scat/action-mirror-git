# action-mirror-git

Synchronize git repositories like a mirror.

## Support

- [x] Multi platforms like GitHub, GitLab, BitBucket, etc.
- [x] Protocol under HTTPS and SSH
- [x] Sync branches, tags and commits
- [x] Ignore specific repositories
- [x] Specify repositories without pushing tags
- [x] Auto create repository on the dest git server with custom script
- [x] Notify with Slack, DingTalk or Lark

## Example

[workflows/example.yml](./.github/workflows/example.yml)

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
  gigrator/mirror-git:0.0.17
```

## LICENSE

[MIT](./LICENSE)
