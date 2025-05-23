ALL_VERSIONS = 2.3 2.4 2.5 2.6 2.7 2.8 2.9 2.10 2.11 3.0 3.1 3.2 4.0 4.1 4.2 4.3 5.0 6.0 6.1 6.2 7.0 7.1 7.2 7.3 8.0 8.1 8.2 8.3
VERSIONS = 8.1 8.2 8.3
VERSION_DOCS = $(addprefix doc-, $(VERSIONS))
VERSION_ARCHIVES = $(addsuffix .archive, $(VERSIONS))

GENERIC_DOCS = site site-dev site-local

SITES = $(GENERIC_DOCS) $(VERSIONS)

LATEST_MAJOR=$(shell curl https://www.rudder-project.org/release-info/rudder/versions/latest)

.PHONY: prepare rudder-theme/build/ui-bundle.zip optipng doc-build changelogs-build build/sites/site/.htaccess build/files $(SITES)
.DEFAULT_GOAL := local

all: $(GENERIC_DOCS) build/history/8.3/.htaccess build/history/8.2/.htaccess build/history/8.1/.htaccess build/sites/site/.htaccess $(VERSION_ARCHIVES) build/files test
online: site site-dev build/sites/site/.htaccess build/history/8.3/.htaccess build/history/8.2/.htaccess build/history/8.1/.htaccess $(VERSION_ARCHIVES) build/files
local: site-local test

rudder-theme/build/ui-bundle.zip:
	cd rudder-theme && yarn install
	cd rudder-theme && gulp pack

# Ugly workaround until we can use custom generators in antora
doc-build:
	[ -d $@ ] || git clone https://github.com/Normation/rudder-doc.git $@
	cd $@ && git checkout branches/rudder/8.3 && git pull
	cd $@/src/reference && make
	cd $@ && git add -f src/reference && git commit --allow-empty -m "Build 8.3"
	cd $@ && git clean -fd
	cd $@ && git checkout branches/rudder/8.2 && git pull
	cd $@/src/reference && make
	cd $@ && git add -f src/reference && git commit --allow-empty -m "Build 8.2"
	cd $@ && git clean -fd
	cd $@ && git checkout branches/rudder/8.1 && git pull
	cd $@/src/reference && make
	cd $@ && git add -f src/reference && git commit --allow-empty -m "Build 8.1"
	cd $@ && git clean -fd

changelogs-build:
	[ -d $@ ] || git clone https://github.com/Normation/rudder-doc.git $@
	cd $@ && git checkout master && git pull
	for version in $(ALL_VERSIONS); do \
	  cd $@ && git checkout master && git branch -df "branches/rudder/$$version" ; git checkout -b "branches/rudder/$$version" ; \
	  sed -i "s@version: \"8.3\"@version: \"$$version\"@" src/changelogs/antora.yml ; \
	  sed -i "s@RUDDER_VERSION = 8.3@RUDDER_VERSION = $$version@" src/changelogs/dependencies/Makefile ; \
	  cd src/changelogs && make ; \
	  cd ../.. && git add -f src/changelogs && git commit --allow-empty -m "Build" ; cd .. ; \
	done

# Prepare everything, even if not needed
prepare: doc-build changelogs-build
	cd src/reference && make

$(SITES): prepare rudder-theme/build/ui-bundle.zip
	antora --ui-bundle-url ./rudder-theme/build/ui-bundle.zip $@.yml

%.archive: %
	mkdir -p build/archives
	cd build/history && cp -r $< doc-$< && tar -cvzf doc-$<.tar.gz doc-$< && rm -r doc-$<
	mv build/history/doc-$<.tar.gz build/archives/

# Generate apache conf for current redirection to latest release
build/sites/site/.htaccess:
	mkdir -p build/sites/site
	echo 'Redirect /reference/current/ /reference/$(LATEST_MAJOR)/' > $@
	echo 'Redirect /changelogs/current/ /changelogs/$(LATEST_MAJOR)/' >> $@

build/history/8.3/.htaccess:
	mkdir -p build/history/8.3/
	echo 'Redirect /rudder-doc/reference/current/ /rudder-doc/reference/8.3/' > $@

build/history/8.2/.htaccess:
	mkdir -p build/history/8.2/
	echo 'Redirect /rudder-doc/reference/current/ /rudder-doc/reference/8.2/' > $@

build/history/8.1/.htaccess:
	mkdir -p build/history/8.1/
	echo 'Redirect /rudder-doc/reference/current/ /rudder-doc/reference/8.1/' > $@

# Download documentation files
build/files:
	mkdir -p build/files
	curl -o build/files/rudder-cheatsheet-advanced.pdf "https://raw.githubusercontent.com/Normation/rudder-tools/master/documents/cheatsheet-advanced/rudder-cheatsheet-advanced.pdf"

test:
	./tests/check_broken_links.sh

optipng:
	find src -name "*.png" -exec optipng {} \;

clean:
	cd src/reference && make clean
	rm -rf build rudder-theme/build
	rm -rf doc-build changelogs-build
