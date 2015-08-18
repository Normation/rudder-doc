## Rudder User Documentation Makefile

.PHONY: all clean view

BASENAME = rudder-doc
SOURCES = $(BASENAME).txt
TARGETS = epub html pdf readme
DOCBOOK_DIST = xsl/xsl-ns-stylesheets

ASCIIDOC = $(CURDIR)/bin/asciidoc/asciidoc.py
A2X = $(CURDIR)/bin/asciidoc/a2x.py

## Asciidoc with general options
ASCIIDOCTODOCBOOK = $(ASCIIDOC) --doctype=book -a docinfo1

## Specific asciidoc options for EPUB output
ASCIIDOCTOEPUB = $(A2X) -f epub \
  --doctype=book -a docinfo1 \
  --dblatex-opts "-P latex.output.revhistory=0"

## Specific asciidoc options for XHTML output
ASCIIDOCTOHTML = $(ASCIIDOC) --doctype=book \
  --backend xhtml11 -a badges -a icons -a numbered -a toc2 \
  -a stylesheet=$(CURDIR)/style/html/rudder.css \
  -a toc-title="Rudder User Documentation" \

## unused options::
## stylesdir/stylesheet:
## we use standard asciidoc stylesheets (no specific stylesdir)
## and add specific styling for Rudder afterwards (stylesheet option)
# -a stylesdir=$(CURDIR)/style/html \
## the search path for 'theme' option cannot be set accurately -> unused
# -a theme=rudder \
## embed css into the html file, this option is not used:
# -a linkcss

## Generate PDF from docbook
DOCBOOK2PDF = dblatex -tpdf

SEE = see

all: $(TARGETS)
epub: epub/$(BASENAME).epub
webhelp: docs/index.html
html: html/$(BASENAME).html
pdf: html/$(BASENAME).pdf
readme: html/README.html

epub/$(BASENAME).epub: $(SOURCES)
	mkdir -p html
	$(ASCIIDOCTOEPUB) $?
	mv $(BASENAME).epub html/

html/$(BASENAME).pdf: $(SOURCES)
	mkdir -p html
	$(ASCIIDOCTODOCBOOK) --backend docbook $?
	$(DOCBOOK2PDF) $(BASENAME).xml
	rm $(BASENAME).xml
	rm -f *.svg
	mv $(BASENAME).pdf html/

docs/index.html: $(SOURCES)
	mkdir -p docs
	$(ASCIIDOC) --doctype=book --backend docbook $?
	xsltproc  --xinclude --output xincluded-profiled.xml  \
        	$(DOCBOOK_DIST)/profiling/profile.xsl $(BASENAME).xml
	xsltproc xsl/webhelp.xsl xincluded-profiled.xml
	cp -r style/html/* images common *.png docs/
	cp -r style/html/images/icons docs/common/images/admon-icons

html/$(BASENAME).html: $(SOURCES)
	mkdir -p html
	$(ASCIIDOCTOHTML) --out-file $@ $?
	cp -R style/html/* images html/

html/README.html: README.asciidoc
	mkdir -p html
	$(ASCIIDOCTOHTML) --out-file $@ $?

slides.html: $(SOURCES)
	$(ASCIIDOC)  -a theme=volnitsky --out-file slides.html --backend slidy $?

## WARNING: at cleanup, delete png files that were produced by output only !

clean:
	rm -rf rudder-doc.xml *.pdf *.html *.png *.svg temp html epub docs xincluded-profiled.xml $(BASENAME).xml

view: all
	$(SEE) $(TARGETS)
