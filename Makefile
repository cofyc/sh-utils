
all: test check
	
test:
	prove *_test.sh

verify:
	./hack/verify-all.sh
