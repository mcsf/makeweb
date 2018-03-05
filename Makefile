SRC_PAGES = $(shell ls -1 pages/* | sort -r)
DST_PAGES = $(subst pages/,public/,$(subst .md$,.html,$(SRC_PAGES)))

all: public/index.html
	@rm -rf tmpfile

public/index.html: $(DST_PAGES) templates/*
	@echo $@
	@cat templates/header.html templates/index-begin.html > $@
	@for p in $(subst public/,,$(filter-out templates/%,$^)) ; do \
		t=$$(cat public/$$p | grep -m2 '<h1>' | tail -n1 \
			| awk 'match($$0,">[^<]+<"){print substr($$0,RSTART+1,RLENGTH-2)}') ; \
		echo "<li><a href=\"$$p\">$$t</a></li>" >> $@ ; \
	done
	@cat templates/index-end.html templates/footer.html >> $@

.SECONDEXPANSION:
public/%.html: $$(wildcard pages/$$*.html) $$(wildcard pages/$$*.md) templates/header.html templates/footer.html
	@echo $@
	@if [[ '$(findstring .md,$<)' ]]; then \
		python3 -m markdown $< > tmpfile ; \
	else \
		cat $< > tmpfile ; \
	fi
	@cat templates/header.html tmpfile templates/footer.html > $@

clean:
	rm -rf public/*
