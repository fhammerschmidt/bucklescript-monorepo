ifeq ($(OS), Windows_NT) 
	detected_OS := Windows
else
	detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

ifeq ($(detected_OS), Windows)
	BSB := ./node_modules/bs-platform/win32/bsb.exe
	# TODO: Windows support
	BSDIRS = $(shell find -L $$(jq -r 'include "./dirs"; dirs' ./lib/bs/.sourcedirs.json) -maxdepth 1 -type f -iregex ".*\.\(re\|ml\)i?")
endif
ifeq ($(detected_OS), Linux)
	BSB := ./node_modules/bs-platform/linux/bsb.exe
	# Purposely not `:=` (strict) because we want it to be executed everytime
	BSDIRS = $(shell find -L $$(jq -r 'include "./dirs"; dirs' ./lib/bs/.sourcedirs.json) -maxdepth 1 -type f -iregex ".*\.\(re\|ml\)i?")
endif
ifeq ($(detected_OS), Darwin)
	BSB := ./node_modules/bs-platform/darwin/bsb.exe
	# macOS find is slightly different from Linux (-E flag for extended regex)
	BSDIRS = $(shell find -EL $$(jq -r 'include "./dirs"; dirs' ./lib/bs/.sourcedirs.json) -maxdepth 1 -type f -iregex ".*\.(re|ml)i?")
endif

BSB_ARGS:= -make-world

all: serve

serve:
	trap 'kill %1' SIGINT
	# BuckleScript doesn't like being run first.
	yarn serve & $(MAKE) watch

bs:
	$(BSB) $(BSB_ARGS)

watch: 
	yarn redemon $(foreach dir, $(BSDIRS),--path '$(dir)') bs

print-%: ; @echo $*=$($*)

clean:
	$(BSB) -clean-world

.PHONY: bs bsdirs all clean
