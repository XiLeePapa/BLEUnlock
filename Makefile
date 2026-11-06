.PHONY: build release dist deploy clean

DD = build/dd
DEBUG_APP = $(DD)/Build/Products/Debug/BLEUnlock.app
RELEASE_APP = $(DD)/Build/Products/Release/BLEUnlock.app
INFO_PLIST = BLEUnlock/Info.plist
RELEASE_REPO = XiLeePapa/BLEUnlock
TAP_REPO = XiLeePapa/homebrew-tap

# The project's Run Script phase increments CFBundleVersion inside the source Info.plist on
# every build. That is right for a release and wrong for local builds, so Debug targets undo it.
build:
	xcodebuild build -project BLEUnlock.xcodeproj -scheme BLEUnlock -derivedDataPath $(DD)
	@git checkout -- $(INFO_PLIST)
	@rm -rf "$(DEBUG_APP)"
	@echo "Built. Build number restored in $(INFO_PLIST); .app removed from $(DD)."

deploy: build
	@pkill -f "BLEUnlock.app/Contents/MacOS/BLEUnlock" 2>/dev/null || true
	@xcodebuild build -project BLEUnlock.xcodeproj -scheme BLEUnlock -derivedDataPath $(DD)
	@git checkout -- $(INFO_PLIST)
	@rm -rf /Applications/BLEUnlock.app
	@ditto "$(DEBUG_APP)" /Applications/BLEUnlock.app
	@rm -rf "$(DEBUG_APP)"
	@open /Applications/BLEUnlock.app
	@echo "Deployed /Applications/BLEUnlock.app (Debug, ad-hoc signed)."

# The upstream Release configuration asks for the author's Developer ID certificate.
# CODE_SIGN_IDENTITY="-" signs ad-hoc instead, which is all a fork can do.
release:
	xcodebuild clean build -project BLEUnlock.xcodeproj -scheme BLEUnlock \
		-derivedDataPath $(DD) -configuration Release \
		CODE_SIGN_IDENTITY="-" CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM=""

# Zip the release build, print its sha256, and tell you the two commands that publish it.
# Keep the Info.plist build number: this is the build that gets released.
dist: release
	@mkdir -p dist
	@plist="$(RELEASE_APP)/Contents/Info.plist"; \
	version=$$(plutil -p $$plist | awk '/CFBundleShortVersionString/ {gsub(/"/, "", $$3); print $$3}'); \
	build=$$(plutil -p $$plist | awk '/"CFBundleVersion"/ {gsub(/"/, "", $$3); print $$3}'); \
	zip="dist/BLEUnlock-$$version.zip"; \
	ditto -c -k --keepParent "$(RELEASE_APP)" "$$zip"; \
	rm -rf "$(RELEASE_APP)"; \
	echo; \
	echo "$$zip (version $$version, build $$build):"; \
	shasum -a 256 "$$zip"; \
	echo; \
	echo "1. Publish the release:"; \
	echo "   gh release create v$$version-build$$build $$zip --repo $(RELEASE_REPO) --title \"BLEUnlock $$version\""; \
	echo; \
	echo "2. Point the cask at it: put that version, build and sha256 into"; \
	echo "   Casks/bleunlock.rb of $(TAP_REPO), commit and push.";

clean:
	rm -rf $(DD) dist
