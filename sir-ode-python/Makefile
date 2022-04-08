.PHONY: all
all: release

.PHONY: clean
clean:
	rm -rf input output

.PHONY: release
release:
	docker build .

.PHONY: run-local
run-local:
	mkdir -p input output
	cp test/input.json input/input.json
	./bin/run-model ./input/input.json ./output/data.json ./schema/input.json ./schema/output.json

