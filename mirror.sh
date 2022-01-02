#!/bin/bash
# Created by K8sCat <k8scat@gmail.com>
set -e

WORKDIR="/tmp/repos"
mkdir -p ${WORKDIR}
cd ${WORKDIR} || exit 1

SSH_DIR="${HOME}/.ssh"
mkdir -p "${SSH_DIR}"
chmod 0700 "${SSH_DIR}"

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
EOF
  echo "${new_host}"
}

if [[ "${SOURCE_PROTOCOL}" = "ssh" ]]; then
  SOURCE_HOST=$(write_ssh_config "source" "${SOURCE_HOST}" "${SOURCE_PORT}" "${SOURCE_USERNAME}" "${SOURCE_PRIVATE_KEY}")
  export SOURCE_HOST
fi
if [[ "${DEST_PROTOCOL}" = "ssh" ]]; then
  DEST_HOST=$(write_ssh_config "dest" "${DEST_HOST}" "${DEST_PORT}" "${DEST_USERNAME}" "${DEST_PRIVATE_KEY}")
  export DEST_HOST
fi

IFS=","
for repo_name in ${MIRROR_REPO_LIST}; do
  cd ${WORKDIR} || exit 1

  if [[ "${SOURCE_PROTOCOL}" = "ssh" ]]; then
    source_addr="git@${SOURCE_HOST}:${SOURCE_USERNAME}/${repo_name}.git"
  elif [[ "${SOURCE_PROTOCOL}" = "https" ]]; then
    source_addr="https://${SOURCE_SECRET}@${SOURCE_HOST}"
    if [[ -n "${SOURCE_PORT}" ]]; then
      source_addr="${source_addr}:${SOURCE_PORT}"
    fi
    source_addr="${source_addr}/${SOURCE_USERNAME}/${repo_name}.git"
  else
    echo "Unknown source protocol: ${SOURCE_PROTOCOL}"
    exit 1
  fi
  echo "source_addr: ${source_addr}"

  if [[ "${DEST_PROTOCOL}" = "ssh" ]]; then
    dest_addr="git@${DEST_HOST}:${DEST_USERNAME}/${repo_name}.git"
  elif [[ "${DEST_PROTOCOL}" = "https" ]]; then
    dest_addr="https://${DEST_TOKEN}@${DEST_HOST}"
    if [[ -n "${DEST_PORT}" ]]; then
      dest_addr="${dest_addr}:${DEST_PORT}"
    fi
    dest_addr="${dest_addr}/${DEST_USERNAME}/${repo_name}.git"
  else
    echo "Unknown source protocol: ${DEST_PROTOCOL}"
    exit 1
  fi
  echo "dest_addr: ${dest_addr}"

  git clone --bare "${source_addr}" "${repo_name}"

  export REPO_NAME=$repo_name
  if [[ -n "${DEST_CREATE_REPO_SCRIPT}" ]]; then
    eval "${DEST_CREATE_REPO_SCRIPT}"
  fi

  repo_dir="${WORKDIR}/${repo_name}"
  cd "${repo_dir}" || exit 1
  if [[ "${PUSH_TAGS}" = "true" ]]; then
    git push --mirror -f "${dest_addr}" || true
  else
    git push --all -f "${dest_addr}" || true
  fi
  if [[ "${ENABLE_GIT_LFS}" = "true" ]]; then
    git lfs push --all "${dest_addr}" || true
  fi
done