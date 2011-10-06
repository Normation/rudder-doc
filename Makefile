## Rudder User Documentation Makefile

SOURCES = rudder-doc.txt
TARGETS = html/rudder-doc.html html/rudder-doc.pdf html/README.html

## Asciidoc with general options
ASCIIDOC = asciidoc --doctype=book -a docinfo2

## Specific asciidoc options for XHTML output
ASCIIDOCHTMLOPTS = --backend xhtml11 \
		   -a stylesdir=$(CURDIR)/style/html \
		   -a theme=rudder \
		   -a numbered \
		   -a toc2 \
		   -a icons \
		   -a badges \
		   -a max-width=50em \
		   -a toc-title="Rudder User Documentation" 

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

html/README.html : README
	mkdir -p html	
	$(ASCIIDOC) $(ASCIIDOCHTMLOPTS) --out-file $@ $?
	
slides.html : rudder-doc.txt
	$(ASCIIDOC)  -a theme=volnitsky --out-file slides.html --backend slidy $?

## WARNING: at cleanup, delete png files that were produced by output only !

clean : 
	rm -rf rudder-doc.xml *.pdf *.html *.png *.svg temp html

view : all
	$(SEE) $(TARGETS)

