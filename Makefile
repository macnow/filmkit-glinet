# filmkit-glinet — integration build for GL.inet routers
#
# Builds FilmKit frontend + filmkit-daemon and deploys to a GL.inet router.
# Submodules:
#   filmkit/        macnow/filmkit  (web app)
#   filmkit-daemon/ macnow/filmkit-daemon  (HTTP daemon)

ROUTER_IP   ?= 10.0.1.1
ROUTER_USER ?= root

.PHONY: all build build-frontend build-daemon deploy deploy-frontend deploy-daemon clean submodules

## Bootstrap: initialise and update git submodules
submodules:
	git submodule update --init --recursive

## Build everything (frontend + daemon)
all: build

build: build-frontend build-daemon

## Build the FilmKit web app (requires Node.js)
build-frontend:
	cd filmkit && npm install && npm run build
	@echo "Frontend built → filmkit/dist/"

## Build filmkit-daemon for router (arm64, requires cross-compiler + libusb)
build-daemon:
	$(MAKE) -C filmkit-daemon build
	@echo "Daemon built → filmkit-daemon/dist/filmkit-daemon"

## Deploy everything to router (build first, then upload)
deploy: build deploy-daemon deploy-frontend
	ssh $(ROUTER_USER)@$(ROUTER_IP) "/etc/init.d/filmkit restart"
	@echo "Done. Open http://$(ROUTER_IP):8765"

## Deploy only the daemon binary + init script
deploy-daemon:
	$(MAKE) -C filmkit-daemon deploy ROUTER_IP=$(ROUTER_IP) ROUTER_USER=$(ROUTER_USER)

## Deploy only the frontend (fast path for JS/CSS-only changes)
deploy-frontend:
	@echo "Uploading frontend to $(ROUTER_USER)@$(ROUTER_IP):/www/filmkit/..."
	ssh $(ROUTER_USER)@$(ROUTER_IP) "rm -rf /www/filmkit && mkdir -p /www/filmkit"
	@for f in $$(find filmkit/dist -type f); do \
		rel=$${f#filmkit/dist/}; \
		dir=$$(dirname $$rel); \
		[ "$$dir" != "." ] && ssh $(ROUTER_USER)@$(ROUTER_IP) "mkdir -p /www/filmkit/$$dir" 2>/dev/null || true; \
		cat $$f | ssh $(ROUTER_USER)@$(ROUTER_IP) "cat > /www/filmkit/$$rel"; \
		echo "  $$rel"; \
	done
	@echo "Frontend deployed."

## Remove all build artifacts
clean:
	rm -rf filmkit/dist filmkit-daemon/dist
