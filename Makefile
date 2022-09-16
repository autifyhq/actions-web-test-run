.PHONY: lint test

lint:
	shellcheck *.bash test/*.bash test/autify-mock*

test:
	bash ./test/test.bash
