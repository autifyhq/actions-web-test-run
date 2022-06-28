#!/usr/bin/env bash

function t() {
  local expected=$1
  local result=$(./script.bash)

  if [ "$result" == "$expected" ]; then
    echo "Passed: $expected"
  else
    echo "Failed"
    echo "  Expected: $expected"
    echo "  Result  : $result"
    exit 1
  fi
}

{
  export INPUT_AUTIFY_PATH="echo autify"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  t "autify web test run a"
}

{
  export INPUT_AUTIFY_PATH="echo autify"
  export INPUT_ACCESS_TOKEN=token
  export INPUT_AUTIFY_TEST_URL=a
  export INPUT_WAIT=true
  export INPUT_TIMEOUT=300
  export INPUT_URL_REPLACEMENTS=a,b
  export INPUT_TEST_EXECUTION_NAME=a
  export INPUT_BROWSER=a
  export INPUT_DEVICE=a
  export INPUT_DEVICE_TYPE=a
  export INPUT_OS=a
  export INPUT_OS_VERSION=a
  t "autify web test run a --wait -t=300 -r=a -r=b --name=a --browser=a --device=a --device-type=a --os=a --os-version=a"
}
