.PHONY: all site pdf validate check serve clean

PORT ?= 8080
PDF := book/comp_book.pdf

all: site pdf validate

site:
	@command -v pandoc >/dev/null 2>&1 || { echo "error: pandoc is required (brew install pandoc)"; exit 1; }
	python3 scripts/build_docs.py

pdf:
	@command -v typst >/dev/null 2>&1 || { echo "error: typst is required (brew install typst)"; exit 1; }
	typst compile book/comp_book.typ $(PDF)

validate:
	python3 scripts/validate_site.py

check: all

serve: site validate
	python3 -m http.server $(PORT) --directory docs

clean:
	rm -f $(PDF)
