BUILDDIR = build
HTML     = $(BUILDDIR)/jq.html
ORG      = $(BUILDDIR)/jq.org
SECTIONS = sections.json
DOCS     = jq.org

all: $(DOCS)

install:
	pip install -r requirements.txt

$(BUILDDIR):
	@mkdir -p "$@"

$(HTML): $(BUILDDIR)
	@./scripts/jq-docs.py "$(HTML)" "$(SECTIONS)"

$(ORG): $(HTML)
	@pandoc --shift-heading-level=-1         \
		--indented-code-classes=jq       \
		--columns=80                     \
		-f html-native_divs-native_spans \
		-t org                           \
		-o $@                            \
		$(HTML)

$(DOCS): $(ORG)
	@emacs --batch -Q -l org --eval \
		"(with-temp-buffer \
			(insert-file-contents \"$^\") \
			(org-mode) \
			(org-table-map-tables #'org-table-align) \
			(write-file \"$@\" nil))"

clean:
	$(RM) -r *~

distclean: clean
	$(RM) -rf $(BUILDDIR)
