ALL_MDS = $(wildcard src/*.mds)
ALL = $(notdir $(ALL_MDS:mds=html))

LAST_MDS = $(shell ls -tu src/*.mds | head -1)
LAST = $(notdir $(LAST_MDS:mds=html))

SVGS=$(shell grep svg $(LAST_MDS) | cut -f 2 -d' ')

# Default target: last modified .mds file
last-modified: $(LAST)

all: $(ALL)

nomachine-directions.html: src/nomachine-directions.md
	pandoc --css http://matsen.fhcrc.org/webpage.css src/nomachine-directions.md -o nomachine-directions.html

index.html: README.md nomachine-directions.html
	pandoc --css http://matsen.fhcrc.org/webpage.css README.md -o index.html

%.html: src/template-revealjs.html src/header.html src/%.mds insert.py Makefile build.sh
	./build.sh src/$*.mds $@

continuous:
	while :; do inotifywait -e modify $(LAST_MDS); make $(LAST); done

edit:
	gvim $(LAST_MDS)

view:
	chromium-browser $(LAST)

count:
	grep "<section" $(LAST) | wc -l

png: $(SVGS)
	sed -e 's/\.svg/.svg.png/' $(LAST) > png_$(LAST)
	for i in $(SVGS); do inkscape --without-gui --export-png=$$i.png --export-dpi 200 $$i; done


