## Rudder User Documentation Makefile

SOURCES = rudder-doc.txt
TARGETS = html/rudder-doc.html html/rudder-doc.pdf html/README.html

## Asciidoc with general options
ASCIIDOC = $(CURDIR)/bin/asciidoc/asciidoc.py --doctype=book -a docinfo2

## Specific asciidoc options for XHTML output
ASCIIDOCHTMLOPTS = --backend xhtml11 \
		   -a stylesheet=$(CURDIR)/style/html/rudder.css \
		   -a numbered \
		   -a toc-title="Rudder User Documentation" \
		   -a toc2 \
		   -a max-width=50em \
		   -a icons \
		   -a badges

## unused options::
## stylesdir/stylesheet: 
## we use standard asciidoc stylesheets (no specific stylesdir)
## and add specific styling for Rudder afterwards (stylesheet option)
#		   -a stylesdir=$(CURDIR)/style/html \
## the search path for 'theme' option cannot be set accurately -> unused
#		   -a theme=rudder \
## embed css into the html file, this option is not used:
#		   -a linkcss

## Generate PDF from docbook
DOCBOOK2PDF = dblatex -tpdf

SEE = see

all: $(TARGETS)

html/rudder-doc.pdf : rudder-doc.txt
	mkdir -p html	
	$(ASCIIDOC) --backend docbook $?
	$(DOCBOOK2PDF) rudder-doc.xml
	rm rudder-doc.xml
	rm -f *.svg
	mv rudder-doc.pdf html/

html/rudder-doc.html : rudder-doc.txt
	mkdir -p html	
	$(ASCIIDOC) $(ASCIIDOCHTMLOPTS) --out-file $@ $?
	cp -R style/html/* images html/

html/README.html : README.asciidoc
	mkdir -p html	
	$(ASCIIDOC) $(ASCIIDOCHTMLOPTS) --out-file $@ $?
	
slides.html : rudder-doc.txt
	$(ASCIIDOC)  -a theme=volnitsky --out-file slides.html --backend slidy $?

## WARNING: at cleanup, delete png files that were produced by output only !

clean : 
	rm -rf rudder-doc.xml *.pdf *.html *.png *.svg temp html

view : all
	$(SEE) $(TARGETS)

