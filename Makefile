PREFIX ?= /usr/local
bindir := $(PREFIX)/bin

SWIFT := swift
SWIFTFLAGS :=
TARGET := Define
MIN_ACCESS_LEVEL := public

repo := define
docsdir := ./Docs
package := Define
executable := define


.PHONY: build docs docs-preview lint format test install dist uninstall mostlyclean clean bump

build:
	$(SWIFT) build -c release $(SWIFTFLAGS)

docs:
	$(SWIFT) package --allow-writing-to-directory "$(docsdir)" \
		generate-documentation --target $(TARGET) \
		--disable-indexing \
		--transform-for-static-hosting \
		--hosting-base-path $(repo) \
		--output-path "$(docsdir)"

docs-preview:
	$(SWIFT) package --disable-sandbox \
		preview-documentation --target $(TARGET) \
		--symbol-graph-minimum-access-level $(MIN_ACCESS_LEVEL)

lint:
	$(SWIFT) format lint --strict --recursive .

format:
	$(SWIFT) format --in-place --recursive .

test:
	$(SWIFT) test -Xswiftc -warnings-as-errors

install: build
	install "$$($(SWIFT) build -c release --show-bin-path)/$(executable)" "$(bindir)"

dist: build
	-mkdir .dist
	-mkdir ".dist/$(package)"
	cp "$$($(SWIFT) build -c release --show-bin-path)/$(executable)" ".dist/$(package)/"
	tar -czf ".dist/$(package)_$$(cz version --project)_macOS.tar.gz" -C .dist "$(package)"
	@echo "Done."

uninstall:
	-rm -f "$(bindir)/$(executable)"

mostlyclean:
	-$(SWIFT) package clean
	-rm -rf .dist

clean: mostlyclean
	-rm -rf .build

bump:
	./Scripts/bump.sh "$(VERSION)"
