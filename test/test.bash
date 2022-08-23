#!/usr/bin/env bash

log_file=$(dirname "$0")/log

function before() {
  unset INPUT_AUTIFY_PATH
  unset INPUT_ACCESS_TOKEN
  unset INPUT_AUTIFY_TEST_URL
  unset INPUT_WAIT
  unset INPUT_TIMEOUT
  unset INPUT_URL_REPLACEMENTS
  unset INPUT_TEST_EXECUTION_NAME
  unset INPUT_BROWSER
  unset INPUT_DEVICE
  unset INPUT_DEVICE_TYPE
  unset INPUT_OS
  unset INPUT_OS_VERSION
  unset INPUT_AUTIFY_CONNECT
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
  ./script.bash | tail -n+2 | grep -E -v ^::set-output > "$result"

  if (git diff --no-index --quiet -- "$log_file" "$result"); then
    echo "Passed log:"
  else
    echo "Failed log:"
    git --no-pager diff --no-index -- "$log_file" "$result"
    exit 1
  fi
}

function test_output() {
  local name=$1
  local expected
  expected=$(mktemp)
  echo -e "$2" > "$expected"
  local output
  output=$(./script.bash | grep -E ^::set-output | grep name="${name}":: | awk -F'::' '{print $3}')
  output="${output//'%25'/%}"
  output="${output//'%0A'/$'\n'}"
  output="${output//'%0D'/$'\r'}"
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
  test_output log "autify web test run a\n$(cat "$log_file")"
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
  export INPUT_TEST_EXECUTION_NAME=c
  export INPUT_BROWSER=d
  export INPUT_DEVICE=e
  export INPUT_DEVICE_TYPE=f
  export INPUT_OS=g
  export INPUT_OS_VERSION=h
  export INPUT_AUTIFY_CONNECT=i
  test_command "autify web test run a --wait -t=300 -r=b1 -r=b2 --name=c --browser=d --device=e --device-type=f --os=g --os-version=h --autify-connect=i"
  test_code 0
  test_log
  test_output exit-code "0"
  test_output log "autify web test run a --wait -t=300 -r=b1 -r=b2 --name=c --browser=d --device=e --device-type=f --os=g --os-version=h --autify-connect=i\n$(cat "$log_file")"
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
  test_output log "autify-fail web test run a\n$(cat "$log_file")"
  test_output result-url "https://result"
}
