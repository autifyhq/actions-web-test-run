<p align="center">
  <a href="https://github.com/autifyhq/actions-web-test-run"><img alt="actions-web-test-run status" src="https://github.com/autifyhq/actions-web-test-run/workflows/test/badge.svg"></a>
</p>

# Run test on Autify for Web
Run a test scenario or test plan on Autify for Web.

See also https://github.com/autifyhq/autify-cli#autify-web-test-run-scenario-or-test-plan-url

## Usage

### Run a test scenario or test plan
```yaml
- uses: autifyhq/actions-web-test-run@v1
  with:
    access-token: ${{ secrets.AUTIFY_WEB_ACCESS_TOKEN }}
    autify-test-url: https://app.autify.com/projects/<ID>/(scenarios|test_plans)/<ID>
```

This will succeed immediately once the test is started but won't wait the finish of the test.

### Run and wait a test scenario or test plan
```yaml
- uses: autifyhq/actions-web-test-run@v1
  with:
    access-token: ${{ secrets.AUTIFY_WEB_ACCESS_TOKEN }}
    autify-test-url: https://app.autify.com/projects/<ID>/(scenarios|test_plans)/<ID>
    wait: true
    timeout: 300
```

This will keep running the action until the test finishes or times out.

**Note: This will consume your GitHub Actions hosted runner's minutes. Be careful when extending the timeout value.**

## Options
```yaml
  access-token:
    required: true
    description: 'Access token of Autify for Web.'
  autify-test-url:
    required: true
    description: 'URL of a test scenario or test plan e.g. https://app.autify.com/projects/<ID>/(scenarios|test_plans)/<ID>'
  wait:
    required: false
    default: 'false'
    description: 'When true, the action waits until the test finishes.'
  timeout:
    required: false
    description: 'Timeout seconds when waiting.'
  url-replacements:
    required: false
    description: 'URL replacements e.g. http://example.com=http://example.net,http://example.org=http://example.net'
  test-execution-name:
    required: false
    description: 'Name of the test execution (not supported by test plan executions)'
  browser:
    required: false
    description: 'Browser for running the test scenario (not supported by test plan executions)'
  device:
    required: false
    description: 'Device for running the test scenario (not supported by test plan executions)'
  device-type:
    required: false
    description: 'Device type for running the test scenario (not supported by test plan executions)'
  os:
    required: false
    description: 'OS for running the test scenario (not supported by test plan executions)'
  os-version:
    required: false
    description: 'OS version for running the test scenario (not supported by test plan executions)'
  autify-connect-key:
    required: false
    description: 'Name of the Autify Connect Key (not supported by test plan executions)'
  autify-path:
    required: false
    default: 'autify'
    description: 'A path to `autify`. If set, this action will not install autify-cli.'
```

## Outputs
```yaml
  exit-code:
    description: 'Exit code of autify-cli. 0 means succeeded.'
  log:
    description: 'Log of stdout and stderr.'
  result-url:
    description: 'Test result URL on Autify for Web'
```
