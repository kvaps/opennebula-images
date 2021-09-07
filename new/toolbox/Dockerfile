# ------------------------------------------------------------------------------
# Guestfish
# ------------------------------------------------------------------------------
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install \
     libguestfs-tools \
     linux-image-generic \
     make \
     bash-completion \
 && apt-get clean
RUN wget https://raw.githubusercontent.com/OpenNebula/addon-context-linux/v6.0.0/src/usr/sbin/onesysprep
