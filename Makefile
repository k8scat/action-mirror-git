os = $(shell uname -s)

version = 0.0.14
image = mirror-git:$(version)

cr_user = gigrator
cr_token =
cr_image = $(cr_user)/$(image)

ghcr = ghcr.io
ghcr_user = k8scat
ghcr_token =
ghcr_image = $(ghcr)/$(ghcr_user)/$(image)

.PHONY: build
build:
	docker build -t $(cr_image) .
	docker tag $(cr_image) $(ghcr_image)

.PHONY: login-cr
login-cr:
	docker login -u $(cr_user) -p $(cr_token)

.PHONY: push-cr
push-cr: login-cr
	docker push $(cr_image)

.PHONY: login-ghcr
login-ghcr:
	docker login -u $(ghcr_user) -p $(ghcr_token) $(ghcr)

.PHONY: push-ghcr
push-ghcr: login-ghcr
	docker push $(ghcr_image)

new_version =
.PHONY: upgrade
upgrade:
ifeq ($(new_version),)
	@echo "Usage: make upgrade new_version=<new version>"
	@exit 1
endif

ifeq ($(os),Darwin)
	sed -i "" 's/$(version)/$(new_version)/g' Makefile
	sed -i "" 's/$(version)/$(new_version)/g' action.yml
	sed -i "" 's/$(version)/$(new_version)/g' .github/workflows/example.yml
	sed -i "" 's/$(version)/$(new_version)/g' README.md
else
	sed -i 's/$(version)/$(new_version)/g' Makefile
	sed -i 's/$(version)/$(new_version)/g' action.yml
	sed -i 's/$(version)/$(new_version)/g' .github/workflows/example.yml
	sed -i 's/$(version)/$(new_version)/g' README.md
endif