# Kenny's List — version + archive helpers.
# Run all targets from the ios/ directory.
#
# The pre-build script regenerates the Xcode project from project.yml on every
# build, so version/build numbers MUST live in project.yml — Xcode UI edits get
# overwritten. These targets keep that source of truth tidy.

PROJECT_YML := project.yml
SCHEME      := VegasPokerGuide

.PHONY: help show bump bump-version regen prepare-archive

help:
	@printf "Kenny's List — version helpers\n"
	@printf "\n"
	@printf "  make show              Print current marketing version + build\n"
	@printf "  make bump              Increment CURRENT_PROJECT_VERSION by 1 (TestFlight upload bump)\n"
	@printf "  make bump-version      Increment last segment of MARKETING_VERSION (1.2 -> 1.3, or 1.2.5 -> 1.2.6)\n"
	@printf "  make regen             Regenerate VegasPokerGuide.xcodeproj from project.yml\n"
	@printf "  make prepare-archive   bump build, regen, ready for Xcode Product -> Archive\n"
	@printf "\n"
	@printf "Typical workflow before a new TestFlight upload:\n"
	@printf "  cd ios && make prepare-archive\n"
	@printf "  open VegasPokerGuide.xcodeproj   # then Product -> Archive\n"

show:
	@mv=$$(awk -F'"' '/MARKETING_VERSION:/ {print $$2; exit}' $(PROJECT_YML)); \
	cpv=$$(awk -F'"' '/CURRENT_PROJECT_VERSION:/ {print $$2; exit}' $(PROJECT_YML)); \
	printf "version: %s    build: %s\n" "$$mv" "$$cpv"

bump:
	@old=$$(awk -F'"' '/CURRENT_PROJECT_VERSION:/ {print $$2; exit}' $(PROJECT_YML)); \
	if [ -z "$$old" ]; then echo "error: CURRENT_PROJECT_VERSION not found in $(PROJECT_YML)" >&2; exit 1; fi; \
	new=$$(($$old + 1)); \
	sed -i.bak "s/CURRENT_PROJECT_VERSION: \"$$old\"/CURRENT_PROJECT_VERSION: \"$$new\"/" $(PROJECT_YML); \
	rm -f $(PROJECT_YML).bak; \
	printf "build: %s -> %s\n" "$$old" "$$new"

bump-version:
	@old=$$(awk -F'"' '/MARKETING_VERSION:/ {print $$2; exit}' $(PROJECT_YML)); \
	if [ -z "$$old" ]; then echo "error: MARKETING_VERSION not found in $(PROJECT_YML)" >&2; exit 1; fi; \
	new=$$(echo "$$old" | awk -F. -v OFS=. '{$$NF++; print}'); \
	sed -i.bak "s/MARKETING_VERSION: \"$$old\"/MARKETING_VERSION: \"$$new\"/" $(PROJECT_YML); \
	rm -f $(PROJECT_YML).bak; \
	printf "version: %s -> %s\n" "$$old" "$$new"

regen:
	@xcodegen generate

prepare-archive: bump regen
	@$(MAKE) -s show
	@printf "\nReady to archive. In Xcode: Product -> Archive\n"
