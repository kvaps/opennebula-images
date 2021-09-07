TAG := v0.0.1
REPO := ghcr.io/kvaps/opennebula-images
IMAGES := ubuntu-20.04 centos-7 debian-11 alpine-3.14
METHOD := local
CACHE := local

ifeq (${METHOD}-${CACHE},local-remote)
define docker-build
	docker manifest inspect ${REPO}/${1}:${TAG} >/dev/null 2>&1 || \
	(docker build ./${1} -t ${REPO}/${1}:${TAG} ${2} && docker push ${REPO}/${1}:${TAG})
endef
else ifeq (${METHOD}-${CACHE},local-local)
define docker-build
	docker build ./${1} -t ${REPO}/${1}:${TAG} ${2}
endef
else ifeq (${METHOD},remote)
define docker-build
	skopeo inspect docker://${REPO}/${1}:${TAG} >/dev/null 2>&1 || \
	kubectl build -c ./${1} -d ${REPO}/${1}:${TAG} ${2}
endef
endif

.PHONY: all toolbox ${IMAGES}

all: ${IMAGES}

toolbox:
	$(call docker-build,toolbox)

${IMAGES}: toolbox
	$(call docker-build,$@,--build-arg TOOLBOX_IMAGE=${REPO}/toolbox:${TAG})
