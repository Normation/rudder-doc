## Rudder User Documentation Makefile

.PHONY: all clean view ncf-doc links

BASENAME = rudder-doc
SOURCES = $(BASENAME).txt
TARGETS = epub html pdf readme webhelp webhelp-localsearch
DOCBOOK_DIST = xsl/xsl-ns-stylesheets

RUDDER_VERSION = 2.11
NCF_VERSION = v0.x

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

## Generate PDF from docbook
DOCBOOK2PDF = dblatex -tpdf

SEE = see

all: test $(TARGETS)
epub: epub/$(BASENAME).epub
webhelp: webhelp/index.html
webhelp-localsearch: webhelp-localsearch/index.html index
html: html/$(BASENAME).html
pdf: html/$(BASENAME).pdf
readme: html/README.html
ncf-doc: generic-methods.asciidoc
links: xsl/links.xsl

epub/$(BASENAME).epub: ncf-doc $(SOURCES)
	mkdir -p html
	$(ASCIIDOCTOEPUB) $(SOURCES)
	mv $(BASENAME).epub html/

html/$(BASENAME).pdf: ncf-doc $(SOURCES)
	mkdir -p html
	$(ASCIIDOCTODOCBOOK) --backend docbook $(SOURCES)
	$(DOCBOOK2PDF) $(BASENAME).xml
	rm $(BASENAME).xml
	rm -f *.svg
	mv $(BASENAME).pdf html/

ncf:
	git clone https://github.com/Normation/ncf.git

generic-methods.asciidoc: ncf
	cd ncf && git pull && git checkout $(NCF_VERSION)
	cp tools/ncf_doc_rudder.py ncf/tools/
	./ncf/tools/ncf_doc_rudder.py
	pandoc -t asciidoc -f markdown generic_methods.md > generic_methods.asciidoc

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

xsl/links.xsl:
	./tools/generate_dynamic_content.py $(RUDDER_VERSION) xsl

webhelp/index.html: links ncf-doc $(SOURCES)
	mkdir -p webhelp
	$(ASCIIDOC) --doctype=book --backend docbook $(SOURCES)
	xsltproc  --xinclude --output xincluded-profiled.xml  \
        	$(DOCBOOK_DIST)/profiling/profile.xsl $(BASENAME).xml
	xsltproc --stringparam webhelp.base.dir "webhelp" \
	         --stringparam webhelp.include.search.tab "0" \
	         --stringparam webhelp.embedded "0" \
	         --stringparam rudder.version $(RUDDER_VERSION) \
	         xsl/webhelp.xsl xincluded-profiled.xml
	cp -r style/html/favicon.ico images template/common *.png webhelp/
	# Awful hack to replace home content
	sed -ri 's/(<div class="titlepage">).*/\1<\/div>/' webhelp/index.html
	sed -i '/<div class="titlepage">/ r xsl/index.html' webhelp/index.html

webhelp-localsearch/index.html: links ncf-doc $(SOURCES)
	mkdir -p webhelp-localsearch
	$(ASCIIDOC) --doctype=book --backend docbook $(SOURCES)
	xsltproc  --xinclude --output xincluded-profiled.xml \
        	 $(DOCBOOK_DIST)/profiling/profile.xsl $(BASENAME).xml
	xsltproc --stringparam webhelp.base.dir "webhelp-localsearch" \
	         --stringparam webhelp.include.search.tab "1" \
	         --stringparam webhelp.embedded "1" \
	         --stringparam rudder.version $(RUDDER_VERSION) \
	         xsl/webhelp.xsl xincluded-profiled.xml
	cp -r style/html/favicon.ico images template/common *.png webhelp-localsearch/
	# Awful hack to replace home content
	sed -ri 's/(<div class="titlepage">).*/\1<\/div>/' webhelp-localsearch/index.html
	sed -i '/<div class="titlepage">/ r xsl/index.html' webhelp-localsearch/index.html

index: webhelp-localsearch/index.html jars
	mkdir -p webhelp-localsearch/search
	java \
	                	-DhtmlDir=webhelp-localsearch \
		                -DindexerLanguage=en \
		                -DhtmlExtension=html \
		                -DdoStem=true \
		                -Dorg.xml.sax.driver=org.ccil.cowan.tagsoup.Parser \
		                -Djavax.xml.parsers.SAXParserFactory=org.ccil.cowan.tagsoup.jaxp.SAXFactoryImpl \
		                -classpath $(classpath) \
		                com.nexwave.nquindexer.IndexerMain
	cp -r template/search/* webhelp-localsearch/search

html/$(BASENAME).html: ncf-doc $(SOURCES)
	mkdir -p html
	$(ASCIIDOCTOHTML) --out-file $@ $(SOURCES)
	cp -R style/html/* images html/

html/README.html: README.asciidoc
	mkdir -p html
	$(ASCIIDOCTOHTML) --out-file $@ $?

slides.html: $(SOURCES)
	$(ASCIIDOC)  -a theme=volnitsky --out-file slides.html --backend slidy $(SOURCES)

test:
	./tests/check_title_syntax.sh

## WARNING: at cleanup, delete png files that were produced by output only !

clean:
	rm -rf rudder-doc.xml *.pdf *.html *.png *.svg temp html epub webhelp webhelp-localsearch xincluded-profiled.xml $(BASENAME).xml extensions ncf generic_methods.{asciidoc,md} xsl/links.xsl xsl/index.html

view: all
	$(SEE) $(TARGETS)
