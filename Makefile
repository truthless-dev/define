prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build --disable-sandbox -c release

test:
	swift test -Xswiftc -warnings-as-errors

install: build
	install ".build/release/define" "$(bindir)"

uninstall:
	rm -f "$(bindir)/define"

clean:
	rm -rf .build

.PHONY: build test install uninstall clean
