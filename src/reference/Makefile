## Rudder User Documentation Makefile

.PHONY: clean $(ADOC_DYN_FILES)

ADOC_SRC_FILES = $(shell find modules/ROOT/ -type f -name '*.adoc')
ADOC_DYN_FILES = generic_methods.adoc hooks.adoc rudder.adoc

content: $(ADOC_DYN_FILES) modules/ROOT/nav.adoc

## Dynamic content

%.adoc:
	cd dependencies && make $@
	mkdir -p modules/ROOT/pages/_partials/dyn/
	cp dependencies/$@ modules/ROOT/pages/_partials/dyn/$@

modules/ROOT/nav.adoc: $(ADOC_SRC_FILES)
	./tools/generate-nav.sh

## Clean

clean:
	cd dependencies && make clean
	rm -rf modules/ROOT/nav.adoc
	rm -f modules/ROOT/pages/_partials/dyn/*
