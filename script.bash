#!/usr/bin/env bash

function add_args() {
  ARGS="${ARGS} $1"
}

AUTIFY=${INPUT_AUTIFY_PATH}

ARGS=${INPUT_AUTIFY_TEST_URL}

if [ -z "${INPUT_ACCESS_TOKEN}" ]; then
  echo "Missing access-token."
  exit 1
fi

if [ "${INPUT_WAIT}" = "true" ]; then 
  add_args "--wait"
fi

if ! [ -z "${INPUT_TIMEOUT}" ]; then
  add_args "-t=${INPUT_TIMEOUT}"
fi

if ! [ -z "${INPUT_URL_REPLACEMENTS}" ]; then
  IFS=',' read -ra URL_REPLACEMENTS <<< "${INPUT_URL_REPLACEMENTS}"
  for url_replacement in "${URL_REPLACEMENTS[@]}"; do
    add_args "-r=${url_replacement}"
  done
fi

if ! [ -z "${INPUT_TEST_EXECUTION_NAME}" ]; then
  add_args "--name=${INPUT_TEST_EXECUTION_NAME}"
fi

if ! [ -z "${INPUT_BROWSER}" ]; then
  add_args "--browser=${INPUT_BROWSER}"
fi

if ! [ -z "${INPUT_DEVICE}" ]; then
  add_args "--device=${INPUT_DEVICE}"
fi

if ! [ -z "${INPUT_DEVICE_TYPE}" ]; then
  add_args "--device-type=${INPUT_DEVICE_TYPE}"
fi

if ! [ -z "${INPUT_OS}" ]; then
  add_args "--os=${INPUT_OS}"
fi

if ! [ -z "${INPUT_OS_VERSION}" ]; then
  add_args "--os-version=${INPUT_OS_VERSION}"
fi

OUTPUT=$(mktemp)

AUTIFY_WEB_ACCESS_TOKEN=${INPUT_ACCESS_TOKEN} ${AUTIFY} web test run ${ARGS} 2>&1 | tee $OUTPUT
exit_code=${PIPESTATUS[0]}
echo ::set-output name=exit-code::$exit_code

# Workaround to return multiline string as outputs
# https://trstringer.com/github-actions-multiline-strings/
output=$(cat $OUTPUT)
output="${output//'%'/%25}"
output="${output//$'\n'/%0A}"
output="${output//$'\r'/%0D}"
echo ::set-output name=log::$output

# https://stackoverflow.com/a/16502803/2052892
result=$(grep "Successfully started" $OUTPUT | grep -Eo 'https://[^ >]+' | head -1)
echo ::set-output name=result-url::$result

exit $exit_code
