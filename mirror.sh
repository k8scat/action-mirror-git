#!/bin/bash
# Created by K8sCat <k8scat@gmail.com>
set +e
message_script="/mirror-git/functions/message"
[[ -f "${message_script}" ]] && source "${message_script}" || true

WORKDIR="/tmp/repos"

mkdir -p ${WORKDIR}
cd ${WORKDIR} || exit 1

SSH_DIR="${HOME}/.ssh"
mkdir -p "${SSH_DIR}"
chmod 0700 "${SSH_DIR}"

# message
if [[ -n "${INPUT_SLACK_WEBHOOK}" ]]; then
  export SLACK_WEBHOOK="${INPUT_SLACK_WEBHOOK}"
fi
if [[ -n "${INPUT_DINGTALK_WEBHOOK}" ]]; then
  export DINGTALK_WEBHOOK="${INPUT_DINGTALK_WEBHOOK}"
fi
if [[ -n "${INPUT_LARK_WEBHOOK}" ]]; then
  export LARK_WEBHOOK="${INPUT_LARK_WEBHOOK}"
fi

function write_ssh_config() {
  type=$1
  host=$2
  port=$3
  username=$4
  private_key=$5

  local privkey_file="${SSH_DIR}/id_rsa_${username}"
  echo "${private_key}" > "${privkey_file}"
  chmod 0600 "${privkey_file}"

  new_host="${type}.${username}.${host}"
  cat >> "${SSH_DIR}/config" <<EOF
Host ${new_host}
    HostName ${host}
    User git
    Port ${port:-22}
    IdentityFile ${privkey_file}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
  echo "${new_host}"
}

if [[ "${INPUT_SOURCE_PROTOCOL}" = "ssh" ]]; then
  INPUT_SOURCE_HOST=$(write_ssh_config "source" "${INPUT_SOURCE_HOST}" "${INPUT_SOURCE_PORT}" "${INPUT_SOURCE_USERNAME}" "${INPUT_SOURCE_PRIVATE_KEY}")
  export INPUT_SOURCE_HOST
fi
if [[ "${INPUT_DEST_PROTOCOL}" = "ssh" ]]; then
  INPUT_DEST_HOST=$(write_ssh_config "dest" "${INPUT_DEST_HOST}" "${INPUT_DEST_PORT}" "${INPUT_DEST_USERNAME}" "${INPUT_DEST_PRIVATE_KEY}")
  export INPUT_DEST_HOST
fi

function notify() {
  if [[ -n "${SLACK_WEBHOOK}" ]]; then
    slack_notify "${1}"
  fi
  if [[ -n "${DINGTALK_WEBHOOK}" ]]; then
    dingtalk_notify "${1}"
  fi
  if [[ -n "${LARK_WEBHOOK}" ]]; then
    lark_notify "${1}"
  fi
  return 0
}

function mirror() {
  IFS=","
  for repo_name in ${INPUT_MIRROR_REPOS}; do
    if [[ "${INPUT_IGNORED_REPOS}" =~ "${repo_name}" ]]; then
      continue
    fi

    cd ${WORKDIR} || return 1

    if [[ "${INPUT_SOURCE_PROTOCOL}" = "ssh" ]]; then
      source_addr="git@${INPUT_SOURCE_HOST}:${INPUT_SOURCE_USERNAME}/${repo_name}.git"
    elif [[ "${INPUT_SOURCE_PROTOCOL}" = "https" ]]; then
      source_addr="https://${INPUT_SOURCE_TOKEN}@${INPUT_SOURCE_HOST}"
      if [[ -n "${INPUT_SOURCE_PORT}" ]]; then
        source_addr="${source_addr}:${INPUT_SOURCE_PORT}"
      fi
      source_addr="${source_addr}/${INPUT_SOURCE_USERNAME}/${repo_name}.git"
    else
      echo "Unknown source protocol: ${INPUT_SOURCE_PROTOCOL}"
      return 1
    fi
    echo "source_addr: ${source_addr}"

    if [[ "${INPUT_DEST_PROTOCOL}" = "ssh" ]]; then
      dest_addr="git@${INPUT_DEST_HOST}:${INPUT_DEST_USERNAME}/${repo_name}.git"
    elif [[ "${INPUT_DEST_PROTOCOL}" = "https" ]]; then
      dest_addr="https://${INPUT_DEST_TOKEN}@${INPUT_DEST_HOST}"
      if [[ -n "${INPUT_DEST_PORT}" ]]; then
        dest_addr="${dest_addr}:${INPUT_DEST_PORT}"
      fi
      dest_addr="${dest_addr}/${INPUT_DEST_USERNAME}/${repo_name}.git"
    else
      echo "Unknown source protocol: ${INPUT_DEST_PROTOCOL}"
      return 1
    fi
    echo "dest_addr: ${dest_addr}"

    if ! git clone --bare "${source_addr}" "${repo_name}"; then
      return 1
    fi

    export REPO_NAME=$repo_name
    if [[ -n "${INPUT_DEST_CREATE_REPO_SCRIPT}" ]]; then
      if [[ $(echo "${INPUT_DEST_CREATE_REPO_SCRIPT}" | wc -l) -eq 1 && "${INPUT_DEST_CREATE_REPO_SCRIPT}" =~ http*://* ]]; then
        if ! curl -L "${INPUT_DEST_CREATE_REPO_SCRIPT}" -o /tmp/create_repo; then
          return 1
        fi
      else
        echo "${INPUT_DEST_CREATE_REPO_SCRIPT}" > /tmp/create_repo
      fi
      chmod +x /tmp/create_repo
      /tmp/create_repo
    fi

    repo_dir="${WORKDIR}/${repo_name}"
    cd "${repo_dir}" || exit 1
    if [[ "${INPUT_PUSH_TAGS}" = "false" || "${INPUT_SKIP_TAGS_REPOS}" =~ "${repo_name}" ]]; then
      if ! git push --all -f "${dest_addr}"; then
        notify "Failed to push ${repo_name} to ${dest_addr} with --all flag"
        continue
      fi
    else
      if ! git push --mirror -f "${dest_addr}"; then
        notify "Failed to push ${repo_name} to ${dest_addr} with --mirror flag"
        continue
      fi
    fi
  done
}

function main() {
  notify "Mirror Git starting"
  if mirror; then
    notify "Mirror Git finished"
  else
    notify "Mirror Git failed"
  fi
}

main "$@"
