## Rudder Changelog Makefile

.PHONY: clean nav

## Dynamic content

changelogs:
	mkdir -p modules/ROOT/pages/
	cd dependencies && make $@
	cp -r dependencies/$@/* modules/ROOT/pages/
	[ -d dependencies/$@/images ] && mkdir -p modules/ROOT/assets/images/ && cp -r dependencies/$@/images modules/ROOT/assets/images/
	[ -f modules/ROOT/pages/index.adoc ] && echo "* xref:index.adoc[Release notes]" > modules/ROOT/nav.adoc || true
	[ -f modules/ROOT/pages/index.adoc ] && echo "* xref:main.adoc[Main changelogs]" >> modules/ROOT/nav.adoc || true
	[ -f modules/ROOT/pages/index.adoc ] || echo "* xref:index.adoc[Main changelogs]" > modules/ROOT/nav.adoc
	[ -f modules/ROOT/pages/index.adoc ] || mv modules/ROOT/pages/main.adoc modules/ROOT/pages/index.adoc
	echo "* Plugins" >> modules/ROOT/nav.adoc
	find modules/ROOT/pages/plugins -type f | sed 's/.*\///' | sed "s/\.adoc//" | sed -r 's@(.*)@** xref:plugins/\1.adoc[\1]@' | sort >> modules/ROOT/nav.adoc

## Clean

clean:
	cd dependencies && make clean
	rm -rf modules/*/nav.adoc
	rm -rf modules/*/pages/*
