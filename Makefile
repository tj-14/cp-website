.PHONY: all site pdf validate check serve clean

PORT ?= 8080
PDF := book/comp_book.pdf

all: site pdf validate

site:
	python3 scripts/build_docs.py
	python3 scripts/normalize_site.py

pdf:
	typst compile book/comp_book.typ $(PDF)

validate:
	python3 scripts/validate_site.py

check: all

serve: site validate
	python3 -m http.server $(PORT) --directory docs

clean:
	rm -f $(PDF)
