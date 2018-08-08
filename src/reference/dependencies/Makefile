## Builds dynamic dependencies from other repos

RUDDER_VERSION = 5.1

.PHONY: clean generic_methods.adoc rudder.adoc hooks.adoc
all: generic_methods.adoc hooks.adoc rudder.adoc

## Repos

rudder-repo:
	git clone https://github.com/normation/rudder.git rudder-repo

rudder-agent-repo:
	git clone https://github.com/Normation/rudder-agent.git rudder-agent-repo

ncf-repo:
	git clone https://github.com/Normation/ncf.git ncf-repo

rudder-agent-windows-repo:
	# Allow failing if builder has no access to agent-windows-repo
	git clone git@github.com:Normation/rudder-agent-windows.git rudder-agent-windows-repo || mkdir rudder-agent-windows-repo

## Dynamic content

rudder.adoc: rudder-agent-repo
	cd rudder-agent-repo && git checkout branches/rudder/$(RUDDER_VERSION) 2>/dev/null || git checkout master
	cd rudder-agent-repo && git pull
	cd rudder-agent-repo/man && make rudder.adoc
	cp rudder-agent-repo/man/rudder.adoc rudder.adoc

hooks.adoc: rudder-repo
	cd rudder-repo && git checkout branches/rudder/$(RUDDER_VERSION) 2>/dev/null || git checkout master
	cd rudder-repo && git pull
	cp rudder-repo/rudder-core/src/main/resources/hooks.d/readme.adoc hooks.adoc
	for hook in `ls rudder-repo/rudder-core/src/main/resources/hooks.d/*/readme.adoc`; do \
	  echo "" >> hooks.adoc ; \
	  cat $$hook >> hooks.adoc ; \
	done

generic_methods.adoc: ncf-repo rudder-agent-windows-repo
	cd rudder-agent-windows-repo && git checkout branches/rudder/$(RUDDER_VERSION) 2>/dev/null || git checkout master
	cd rudder-agent-windows-repo && git pull
	cd ncf-repo && git checkout branches/rudder/$(RUDDER_VERSION) 2>/dev/null || git checkout master
	cd ncf-repo && git pull
	cp rudder-agent-windows-repo/plugin/ncf/30_generic_methods/*.cf ncf-repo/tree/30_generic_methods/ || true
	cp tools/ncf_doc_rudder.py ncf-repo/tools/
	./ncf-repo/tools/ncf_doc_rudder.py
	# Remove language setting on code field (#9621)
	sed -i 's/```.*/```/' generic_methods.md
	pandoc -t asciidoc -f markdown generic_methods.md > generic_methods.adoc

## Clean

clean:
	rm -f generic_methods.{adoc,md} hooks.adoc rudder.adoc

veryclean: clean
	rm -rf rudder-agent-repo rudder-repo ncf-repo rudder-agent-windows-repo