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

DOCBOOK_EXTENSIONS_DIR = extensions
INDEXER_JAR   := $(DOCBOOK_EXTENSIONS_DIR)/docbook-xsl-webhelpindexer-1.0.1-pre.jar
TAGSOUP_JAR   := $(DOCBOOK_EXTENSIONS_DIR)/tagsoup-1.2.1.jar
LUCENE_ANALYZER_JAR   := $(DOCBOOK_EXTENSIONS_DIR)/lucene-analyzers-common-5.2.1.jar
LUCENE_CORE_JAR   := $(DOCBOOK_EXTENSIONS_DIR)/lucene-core-5.2.1.jar

classpath := $(INDEXER_JAR):$(TAGSOUP_JAR):$(LUCENE_ANALYZER_JAR):$(LUCENE_CORE_JAR)

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
webhelp: docs/index.html index
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

$(INDEXER_JAR):
	mkdir -p $(DOCBOOK_EXTENSIONS_DIR)
	wget http://central.maven.org/maven2/net/sf/docbook/docbook-xsl-webhelpindexer/1.0.1-pre/docbook-xsl-webhelpindexer-1.0.1-pre.jar -O $(INDEXER_JAR)

$(TAGSOUP_JAR):
	mkdir -p $(DOCBOOK_EXTENSIONS_DIR)
	wget http://central.maven.org/maven2/org/ccil/cowan/tagsoup/tagsoup/1.2.1/tagsoup-1.2.1.jar -O $(TAGSOUP_JAR)

$(LUCENE_CORE_JAR):
	mkdir -p $(DOCBOOK_EXTENSIONS_DIR)
	wget http://central.maven.org/maven2/org/apache/lucene/lucene-core/5.2.1/lucene-core-5.2.1.jar -O $(LUCENE_CORE_JAR)

$(LUCENE_ANALYZER_JAR):
	mkdir -p $(DOCBOOK_EXTENSIONS_DIR)
	wget http://central.maven.org/maven2/org/apache/lucene/lucene-analyzers-common/5.2.1/lucene-analyzers-common-5.2.1.jar -O $(LUCENE_ANALYZER_JAR)

jars: $(INDEXER_JAR) $(TAGSOUP_JAR) $(LUCENE_ANALYZER_JAR) $(LUCENE_CORE_JAR)

docs/index.html: $(SOURCES)
	mkdir -p docs
	$(ASCIIDOC) --doctype=book --backend docbook $?
	xsltproc  --xinclude --output xincluded-profiled.xml  \
        	$(DOCBOOK_DIST)/profiling/profile.xsl $(BASENAME).xml
	xsltproc xsl/webhelp.xsl xincluded-profiled.xml
	cp -r style/html/* images template/common *.png docs/
	cp -r style/html/images/icons docs/common/images/admon-icons

index: docs/index.html jars
	java \
	                	-DhtmlDir=docs \
		                -DindexerLanguage=en \
		                -DhtmlExtension=html \
		                -DdoStem=true \
		                -Dorg.xml.sax.driver=org.ccil.cowan.tagsoup.Parser \
		                -Djavax.xml.parsers.SAXParserFactory=org.ccil.cowan.tagsoup.jaxp.SAXFactoryImpl \
		                -classpath $(classpath) \
		                com.nexwave.nquindexer.IndexerMain
	cp -r template/search/* docs/search

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
	rm -rf rudder-doc.xml *.pdf *.html *.png *.svg temp html epub docs xincluded-profiled.xml $(BASENAME).xml extensions

view: all
	$(SEE) $(TARGETS)
