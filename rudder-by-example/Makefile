NAME = rudder-by-example

all: depends html pdf epub

depends:
	gitbook install

serve:
	gitbook serve

html: target/$(NAME)

target/$(NAME):
	gitbook build . target/$(NAME)

pdf: target/$(NAME).pdf

target/$(NAME).pdf:
	gitbook pdf . target/$(NAME).pdf

epub: target/$(NAME).epub

target/$(NAME).epub:
	gitbook epub . target/$(NAME).epub

clean:
	rm -rf target/
