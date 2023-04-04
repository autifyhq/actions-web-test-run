#!/usr/bin/env bash

ARGS=()

function add_args() {
  ARGS+=("$1")
}

function exit_script() {
  local code=$1
  echo exit-code="$code" >> "$GITHUB_OUTPUT"
  exit "$code"
}

AUTIFY=${INPUT_AUTIFY_PATH}

if [ -z "${INPUT_ACCESS_TOKEN}" ]; then
  echo "Missing access-token."
  exit_script 1
fi

if [ -n "${INPUT_AUTIFY_TEST_URL}" ]; then
  add_args "${INPUT_AUTIFY_TEST_URL}"
else
  echo "Missing autify-test-url."
  exit_script 1
fi

if [ "${INPUT_WAIT}" = "true" ]; then 
  add_args "--wait"
fi

if [ -n "${INPUT_TIMEOUT}" ]; then
  add_args "-t=${INPUT_TIMEOUT}"
fi

if [ -n "${INPUT_URL_REPLACEMENTS}" ]; then
  IFS=',' read -ra URL_REPLACEMENTS <<< "${INPUT_URL_REPLACEMENTS}"
  for url_replacement in "${URL_REPLACEMENTS[@]}"; do
    add_args "-r=\"${url_replacement}\""
  done
fi

if [ -n "${INPUT_MAX_RETRY_COUNT}" ]; then
  add_args "--max-retry-count=${INPUT_MAX_RETRY_COUNT}"
fi

if [ -n "${INPUT_TEST_EXECUTION_NAME}" ]; then
  add_args "--name=${INPUT_TEST_EXECUTION_NAME}"
fi

if [ -n "${INPUT_BROWSER}" ]; then
  add_args "--browser=${INPUT_BROWSER}"
fi

if [ -n "${INPUT_DEVICE}" ]; then
  add_args "--device=${INPUT_DEVICE}"
fi

if [ -n "${INPUT_DEVICE_TYPE}" ]; then
  add_args "--device-type=${INPUT_DEVICE_TYPE}"
fi

if [ -n "${INPUT_OS}" ]; then
  add_args "--os=${INPUT_OS}"
fi

if [ -n "${INPUT_OS_VERSION}" ]; then
  add_args "--os-version=${INPUT_OS_VERSION}"
fi

if [ -n "${INPUT_AUTIFY_CONNECT}" ]; then
  add_args "--autify-connect=${INPUT_AUTIFY_CONNECT}"
fi

if [ "${INPUT_AUTIFY_CONNECT_CLIENT}" = "true" ]; then
  add_args "--autify-connect-client"
fi

if [ -n "${INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS}" ]; then
  add_args "--autify-connect-client-extra-arguments=${INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS}"
fi

export AUTIFY_CLI_USER_AGENT_SUFFIX="${AUTIFY_CLI_USER_AGENT_SUFFIX:=github-actions-web-test-run}"

OUTPUT=$(mktemp)
AUTIFY_WEB_ACCESS_TOKEN=${INPUT_ACCESS_TOKEN} ${AUTIFY} web test run "${ARGS[@]}" 2>&1 | tee "$OUTPUT"
exit_code=${PIPESTATUS[0]}

# Output multiline strings
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
output=$(cat "$OUTPUT")
delimiter="$(openssl rand -hex 8)"
{
  echo "log<<${delimiter}"
  echo "${output}"
  echo "${delimiter}"
} >> "${GITHUB_OUTPUT}"

result=$(grep "Successfully started" "$OUTPUT" | grep -Eo 'https://[^ ]+' | head -1)
echo result-url="$result" >> "$GITHUB_OUTPUT"

exit_script "$exit_code"
