#!/usr/bin/env bash

log_file=$(dirname "$0")/log
export GITHUB_OUTPUT

function before() {
  GITHUB_OUTPUT=$(mktemp)
  unset INPUT_AUTIFY_PATH
  unset INPUT_ACCESS_TOKEN
  unset INPUT_AUTIFY_TEST_URL
  unset INPUT_WAIT
  unset INPUT_TIMEOUT
  unset INPUT_INTERVAL
  unset INPUT_URL_REPLACEMENTS
  unset INPUT_MAX_RETRY_COUNT
  unset INPUT_TEST_EXECUTION_NAME
  unset INPUT_BROWSER
  unset INPUT_DEVICE
  unset INPUT_DEVICE_TYPE
  unset INPUT_OS
  unset INPUT_OS_VERSION
  unset INPUT_AUTIFY_CONNECT
  unset INPUT_AUTIFY_CONNECT_CLIENT
  unset INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS
  echo "=== TEST ==="
}

function test_command() {
  local expected=$1
  local result
  result=$(./script.bash | head -1)

  if [ "$result" == "$expected" ]; then
    echo "Passed command: $expected"
  else
    echo "Failed command:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_code() {
  local expected=$1
  ./script.bash > /dev/null
  local result=$?

  if [ "$result" == "$expected" ]; then
    echo "Passed code: $expected"
  else
    echo "Failed code:"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

function test_log() {
  local result
  result=$(mktemp)
  ./script.bash | tail -n+2 > "$result"

  if (git diff --no-index --quiet -- "$log_file" "$result"); then
    echo "Passed log:"
  else
    echo "Failed log:"
    git --no-pager diff --no-index -- "$log_file" "$result"
    exit 1
  fi
}

function test_output() {
  echo > "$GITHUB_OUTPUT"
  local name=$1
  local expected
  expected=$(mktemp)
  echo -e "$2" > "$expected"
  ./script.bash > /dev/null
  local output
  output=$(grep -e "^${name}=" "$GITHUB_OUTPUT" | cut -f2- -d=)
  local result
  result=$(mktemp)
  echo -e "$output" > "$result"

  if (git diff --no-index --quiet -- "$expected" "$result"); then
    echo "Passed output: $name"
  else
    echo "Failed output: $name"
    git --no-pager diff --no-index -- "$expected" "$result"
    exit 1
  fi
}

function test_multiline_output() {
  echo > "$GITHUB_OUTPUT"
  local name=$1
  local expected
  expected=$(mktemp)
  echo -e "$2" > "$expected"
  ./script.bash > /dev/null
  local output
  delimiter=$(grep -e "^${name}<<" "$GITHUB_OUTPUT" | sed -e 's/<</=/g' | cut -f2- -d=)
  output=$(sed -e "s/^${name}<<//g" "$GITHUB_OUTPUT" | sed -ne "/${delimiter}/,/${delimiter}/p" | sed -e "/${delimiter}/d")
  local result
  result=$(mktemp)
  echo -e "$output" > "$result"

  if (git diff --no-index --quiet -- "$expected" "$result"); then
    echo "Passed output: $name"
  else
    echo "Failed output: $name"
    git --no-pager diff --no-index -- "$expected" "$result"
    exit 1
  fi
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  test_command "autify web test run a"
  test_code 0
  test_log
  test_output exit-code "0"
  test_multiline_output log "autify web test run a\n$(cat "$log_file")"
  test_output result-url "https://result"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_WAIT=true
  export INPUT_TIMEOUT=300
  export INPUT_URL_REPLACEMENTS=b1,b2
  export INPUT_MAX_RETRY_COUNT=c
  export INPUT_TEST_EXECUTION_NAME=d
  export INPUT_BROWSER=e
  export INPUT_DEVICE=f
  export INPUT_DEVICE_TYPE=g
  export INPUT_OS=h
  export INPUT_OS_VERSION=i
  export INPUT_AUTIFY_CONNECT=j
  export INPUT_AUTIFY_CONNECT_CLIENT=true
  export INPUT_AUTIFY_CONNECT_CLIENT_EXTRA_ARGUMENTS=k
  test_command "autify web test run a --wait -t=300 -r=b1 -r=b2 --max-retry-count=c --name=d --browser=e --device=f --device-type=g --os=h --os-version=i --autify-connect=j --autify-connect-client --autify-connect-client-extra-arguments=k"
  test_code 0
  test_log
  test_output exit-code "0"
  test_multiline_output log "autify web test run a --wait -t=300 -r=b1 -r=b2 --max-retry-count=c --name=d --browser=e --device=f --device-type=g --os=h --os-version=i --autify-connect=j --autify-connect-client --autify-connect-client-extra-arguments=k\n$(cat "$log_file")"
  test_output result-url "https://result"
}

{
  before
  export INPUT_AUTIFY_PATH="./test/autify-mock-fail"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  test_command "autify-fail web test run a"
  test_code 1
  test_log
  test_output exit-code "1"
  test_multiline_output log "autify-fail web test run a\n$(cat "$log_file")"
  test_output result-url "https://result"
}
