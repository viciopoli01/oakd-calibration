# parameters
ARG REPO_NAME="oakd-calibration"
ARG DESCRIPTION="OAK-D calibration support"
ARG MAINTAINER="Vincenzo Polizzi (polivicio@gmail.com)"
# pick an icon from: https://fontawesome.com/v4.7.0/icons/
ARG ICON="cube"

# ==================================================>
# ==> Do not change the code below this line
ARG ARCH=amd64
ARG DISTRO=daffy
ARG BASE_TAG=${DISTRO}-${ARCH}
ARG BASE_IMAGE=dt-gui-tools
ARG LAUNCHER=default

# define base image
ARG DOCKER_REGISTRY=docker.io
FROM duckietown/dt-gui-tools:${BASE_IMAGE}:${BASE_TAG} as BASE

# recall all arguments
ARG ARCH
ARG DISTRO
ARG REPO_NAME
ARG DESCRIPTION
ARG MAINTAINER
ARG ICON
ARG BASE_TAG
ARG BASE_IMAGE
ARG LAUNCHER

# check build arguments
RUN dt-build-env-check "${REPO_NAME}" "${MAINTAINER}" "${DESCRIPTION}"

# define/create repository path
ARG REPO_PATH="${CATKIN_WS_DIR}/src/${REPO_NAME}"
ARG LAUNCH_PATH="${LAUNCH_DIR}/${REPO_NAME}"
RUN mkdir -p "${REPO_PATH}"
RUN mkdir -p "${LAUNCH_PATH}"
WORKDIR "${REPO_PATH}"

# keep some arguments as environment variables
ENV DT_MODULE_TYPE "${REPO_NAME}"
ENV DT_MODULE_DESCRIPTION "${DESCRIPTION}"
ENV DT_MODULE_ICON "${ICON}"
ENV DT_MAINTAINER "${MAINTAINER}"
ENV DT_REPO_PATH "${REPO_PATH}"
ENV DT_LAUNCH_PATH "${LAUNCH_PATH}"
ENV DT_LAUNCHER "${LAUNCHER}"

RUN apt-get update && apt-get -y install libgtk-3-dev \
    software-properties-common \
    curl \
    apache2-utils \
    supervisor \
    nginx \
    sudo \
    net-tools \
    zenity \
    xz-utils \
    dbus-x11 \
    x11-utils \
    alsa-utils \
    mesa-utils \
    libgl1-mesa-dri \
    xvfb \
    x11vnc \
    vim-tiny \
    ttf-ubuntu-font-family \
    ttf-wqy-zenhei \
    lxde \
    gtk2-engines-murrine \
    gnome-themes-standard \
    gtk2-engines-pixbuf \
    gtk2-engines-murrine \
    arc-theme \
    curl \
    udev \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1-mesa-glx \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-22-dev \
    usbutils

RUN curl -fL http://docs.luxonis.com/_static/install_dependencies.sh | bash
RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules
RUN pip3 install depthai==2.7.1

# install python3 dependencies
ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
RUN echo PIP_INDEX_URL=${PIP_INDEX_URL}
COPY ./dependencies-py3.txt "${REPO_PATH}/"
RUN pip3 uninstall opencv-python &&\
    pip3 uninstall opencv-contrib-python &&\
    pip3 install opencv-python &&\
    pip3 install opencv-contrib-python

RUN git clone https://github.com/luxonis/depthai.git && cd depthai && python3 install_requirements.py


# install launcher scripts
COPY ./launchers/. "${LAUNCH_PATH}/"
COPY ./launchers/default.sh "${LAUNCH_PATH}/"
RUN dt-install-launchers "${LAUNCH_PATH}"

# define default command
CMD ["bash", "-c", "dt-launcher-${DT_LAUNCHER}"]

# store module metadata
LABEL org.duckietown.label.module.type="${REPO_NAME}" \
    org.duckietown.label.module.description="${DESCRIPTION}" \
    org.duckietown.label.module.icon="${ICON}" \
    org.duckietown.label.architecture="${ARCH}" \
    org.duckietown.label.code.location="${REPO_PATH}" \
    org.duckietown.label.code.version.distro="${DISTRO}" \
    org.duckietown.label.base.image="${BASE_IMAGE}" \
    org.duckietown.label.base.tag="${BASE_TAG}" \
    org.duckietown.label.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================
