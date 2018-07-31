SITES = site site-dev site-local doc-5.0 doc-5.1

.PHONY: prepare rudder-theme/build/ui-bundle.zip optipng doc-build $(SITES)
.DEFAULT_GOAL := local

all: $(SITES) test
online: site site-dev doc-5.0 doc-5.1 test
local: site-local test

rudder-theme/build/ui-bundle.zip:
	cd rudder-theme && yarn install
	cd rudder-theme && gulp pack

# Ugly workaround until we can use custom generators in antora
doc-build:
	[ -d $@ ] || git clone https://github.com/Normation/rudder-doc.git $@
	cd $@ && git checkout branches/rudder/5.0 && git pull
	cd $@/src/reference && make
	cd $@ && git add -f src/reference && git commit --allow-empty -m "Build 5.0"
	cd $@ && git clean -fd
	cd $@ && git checkout master && git pull
	cd $@/src/reference && make
	cd $@ && git add -f src/reference && git commit --allow-empty -m "Build master"

prepare: doc-build
	cd src/reference && make

$(SITES): prepare rudder-theme/build/ui-bundle.zip
	antora --ui-bundle-url ./rudder-theme/build/ui-bundle.zip $@.yml

test:
	./tests/check_broken_links.sh

optipng:
	find src -name "*.png" -exec optipng {} \;

clean:
	cd src/reference && make clean
	rm -rf build rudder-theme/build
	rm -rf doc-build
