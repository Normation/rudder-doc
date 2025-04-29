## Rudder User Documentation Makefile

.PHONY: clean $(ADOC_DYN_FILES) nav

ADOC_SRC_FILES = $(shell find modules/ROOT/pages -type f -name '*.adoc')
ADOC_DYN_FILES = hooks.adoc rudder.adoc rudder-relayd.1.adoc versions.adoc
GRAPHVIZ_FILES = $(shell find modules/reference/assets/graphviz -type f -name '*.dot')
GRAPHVIZ_IMAGES = $(addprefix modules/reference/assets/images/graphviz/, $(notdir $(GRAPHVIZ_FILES:dot=png)))

MODULES = ROOT installation usage administration plugins reference

content: $(GRAPHVIZ_IMAGES) $(ADOC_DYN_FILES) plugins nav

## Dynamic content

versions.adoc:
	cd dependencies && make $@
	mkdir -p modules/installation/pages/_partials/dyn/
	cp dependencies/$@ modules/installation/pages/_partials/dyn/$@

rudder.adoc:
	cd dependencies && make $@
	mkdir -p modules/reference/pages/_partials/dyn/
	cp dependencies/$@ modules/reference/pages/_partials/dyn/$@

rudder-relayd.1.adoc:
	cd dependencies && make $@
	mkdir -p modules/reference/pages/_partials/dyn/
	cp dependencies/$@ modules/reference/pages/_partials/dyn/$@

hooks.adoc:
	cd dependencies && make $@
	mkdir -p modules/usage/pages/_partials/dyn/
	cp dependencies/$@ modules/usage/pages/_partials/dyn/$@

plugins:
	cd dependencies && make $@
	cp -r dependencies/$@/* modules/plugins/
	echo "index.adoc" > modules/plugins/nav.list
	find modules/plugins/pages ! -name 'index.adoc' -type f | sed 's/.*\///' | sort >> modules/plugins/nav.list

nav: $(ADOC_SRC_FILES) plugins
	./tools/generate-nav.py ROOT "Introduction" > modules/ROOT/nav.adoc
	# installation has a custom nav
	cp modules/installation/nav.adoc.src modules/installation/nav.adoc
	./tools/generate-nav.py usage "Usage" > modules/usage/nav.adoc
	./tools/generate-nav.py administration "Administration" > modules/administration/nav.adoc
	./tools/generate-nav.py plugins "Plugins" > modules/plugins/nav.adoc
	./tools/generate-nav.py reference "Reference" > modules/reference/nav.adoc

modules/reference/assets/images/graphviz/%.png: modules/reference/assets/graphviz/%.dot
	mkdir -p modules/reference/assets/images/graphviz
	dot $< -Tpng -o $@

## Clean

clean:
	cd dependencies && make clean
	rm -rf modules/*/nav.adoc
	rm -f modules/*/pages/_partials/dyn/*
	rm -rf modules/*/assets/images/graphviz
	rm -rf modules/plugins/assets
	find modules/plugins/pages ! -name 'index.adoc' -type f -exec rm -f {} +
