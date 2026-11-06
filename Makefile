.PHONY: build clean deploy

DD = build/dd
APP = $(DD)/Build/Products/Debug/BLEUnlock.app

build:
	xcodebuild build -project BLEUnlock.xcodeproj -scheme BLEUnlock \
		-derivedDataPath $(DD)
	@# Remove the .app so Launchpad doesn't index a duplicate alongside /Applications.
	@rm -rf "$(APP)"
	@echo "Built OK. .app removed from $(DD) to avoid Launchpad duplicates."

deploy: build
	@pkill -f "BLEUnlock.app/Contents/MacOS/BLEUnlock" 2>/dev/null || true
	@sleep 1
	@rm -rf /Applications/BLEUnlock.app
	@# Rebuild just enough to get the .app back (xcodebuild is incremental, so this is fast).
	xcodebuild build -project BLEUnlock.xcodeproj -scheme BLEUnlock \
		-derivedDataPath $(DD)
	@ditto "$(APP)" /Applications/BLEUnlock.app
	@rm -rf "$(APP)"
	@open /Applications/BLEUnlock.app
	@echo "Deployed to /Applications/BLEUnlock.app"

clean:
	rm -rf $(DD)
