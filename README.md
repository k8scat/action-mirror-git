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
  -e INPUT_SOURCE_PROTOCOL \
  -e INPUT_SOURCE_HOST \
  -e INPUT_SOURCE_USERNAME \
  -e INPUT_SOURCE_TOKEN \
  -e INPUT_DEST_PROTOCOL \
  -e INPUT_DEST_HOST \
  -e INPUT_DEST_USERNAME \
  -e INPUT_DEST_TOKEN \
  -e INPUT_PUSH_TAGS \
  -e INPUT_MIRROR_REPOS \
  -e INPUT_IGNORED_REPOS \
  -e INPUT_SKIP_TAGS_REPOS \
  -e INPUT_DEST_CREATE_REPO_SCRIPT \
  -e INPUT_SOURCE_PORT \
  -e INPUT_SOURCE_PRIVATE_KEY \
  -e INPUT_DEST_PORT \
  -e INPUT_DEST_PRIVATE_KEY \
  -e INPUT_SLACK_WEBHOOK \
  -e INPUT_DINGTALK_WEBHOOK \
  -e INPUT_LARK_WEBHOOK \
  gigrator/mirror-git:0.0.12
```

## LICENSE

[MIT](./LICENSE)
