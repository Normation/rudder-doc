all: html pdf epub

depends:
	gitbook install

serve:
	gitbook serve

html: depends target/$(NAME)

target/$(NAME):
	gitbook build . target/$(NAME)
	cp src/favicon.ico target/$(NAME)/gitbook/images/favicon.ico

pdf: depends target/$(NAME).pdf

target/$(NAME).pdf:
	gitbook pdf . target/$(NAME).pdf

epub: depends target/$(NAME).epub

target/$(NAME).epub:
	gitbook epub . target/$(NAME).epub

clean:
	rm -rf target/
