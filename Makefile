# Minimize on Close Add-on for Thunderbird

.PHONY: xpi xpi-unsupported clean clobber

xpi: dist/minimizeonclose.xpi
xpi-unsupported: dist/minimizeonclose-unsupported.xpi

clean:
	rm -Rf build

clobber: clean
	rm -Rf dist

SRCFILES := $(shell find src -type f \
	-not -path 'src/manifest.json' \
	-not -name '.*' \
	)

# The add-on version is read from the VERSION file at the repository root,
# in semantic versioning format: MAJOR.MINOR.PATCH (no pre-release suffix).
VERSION := $(strip $(shell cat VERSION 2>/dev/null))
ifeq ($(shell echo '$(VERSION)' | grep -Ex '(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)'),)
$(error VERSION must be MAJOR.MINOR.PATCH, got "$(VERSION)")
endif

build/manifest.json: src/manifest.json VERSION
	mkdir -p "$(@D)"
	sed -e "s/__BUILD_version__/$(VERSION)/g" "$<" > "$@"

dist/minimizeonclose.xpi: $(SRCFILES) build/manifest.json LICENSE
	mkdir -p "$(@D)"
	rm -f "$@"
	cd src ; zip -9X "../$@" $(SRCFILES:src/%=%)
	cd build ; zip -9X "../$@" manifest.json
	zip -9X "$@" LICENSE

build/unsupported/manifest.json: src/manifest.json VERSION
	mkdir -p "$(@D)"
	sed -e "s/__BUILD_version__/$(VERSION)-unsupported/g" \
	    -e 's/"strict_max_version": "[^"]*"/"strict_max_version": "*"/g' \
	    "$<" > "$@"

dist/minimizeonclose-unsupported.xpi: $(SRCFILES) build/unsupported/manifest.json LICENSE
	mkdir -p "$(@D)"
	rm -f "$@"
	cd src ; zip -9X "../$@" $(SRCFILES:src/%=%)
	cd build/unsupported ; zip -9X "../../$@" manifest.json
	zip -9X "$@" LICENSE
