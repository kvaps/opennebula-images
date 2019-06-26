FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y install \
     libguestfs-tools \
     linux-image-generic \
 && apt-get clean
