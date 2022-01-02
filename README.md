# action-mirror-git

Synchronize git repositories like a mirror.

## Demo

```yml
- name: action-git-mirror   
  uses: k8scat/action-git-mirror@v0.0.1
  with: 
    source_protocol: https
    source_host: github.com
    source_username: k8scat
    source_token: xxx
    dest_protocol: https
    dest_host: github.com
    dest_username: another_user
    dest_token: xxx
    enable_git_lfs: "true"
    push_tags: "true"
    dest_create_repo_script: |
      # create repo via github cli
      echo "${dest_token}" > ~/.github_token
      gh auth login --with-token < ~/.github_token
      gh repo create "${DEST_USERNAME}/${REPO_NAME}" --private -y
```

## Base Image

[gigrator/base:0.0.2](https://hub.docker.com/repository/docker/gigrator/base)

## LICENSE

[MIT](./LICENSE)
