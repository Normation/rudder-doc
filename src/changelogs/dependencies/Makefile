## Builds dynamic dependencies from other repos

RUDDER_VERSION = 5.0

.PHONY: clean changelogs
all: changelogs

## Repos

rudder-tools-repo:
	git clone https://github.com/Normation/rudder-tools.git rudder-tools-repo

## Dynamic content

changelogs: rudder-tools-repo
	cd rudder-tools-repo && git checkout master
	cd rudder-tools-repo && git pull
	mkdir -p changelogs
	cp -r rudder-tools-repo/release-data/changelogs/$(RUDDER_VERSION)/* changelogs/

## Clean

clean:
	rm -rf changelogs

veryclean: clean
	rm -rf changelogs rudder-tools-repo
