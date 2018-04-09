# Rudder by Example

## Doc

* Syntax reference for AsciiDoc: https://asciidoctor.org/docs/asciidoc-syntax-quick-reference
* GitBook doc: https://toolchain.gitbook.com/

## Install dependencies

Install gitbook:

```bash
$ npm install gitbook-cli -g
```

Install dependencies:

```bash
make depends
```

Epub build requires calibre installed.

## Build the doc

Preview and serve your book using:

```bash
make serve
```

Or build the static website using:

```bash
make html
```
