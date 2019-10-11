# Envisaged - Dockerized Gource Visualizations
#
# VERSION 0.1.4

FROM utensils/opengl:stable

# Install all needed runtime dependencies.
COPY build_scripts/build_image.sh /tmp/build_image.sh
RUN /bin/sh /tmp/build_image.sh


# Copy our assets
COPY ./docker-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY . /visualization/

WORKDIR /visualization

# Labels and metadata.
ARG VCS_REF
ARG BUILD_DATE
LABEL maintainer="James Brink, brink.james@gmail.com" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.decription="Envisaged-Redux - Dockerized Gource Visualizations, Redefined." \
      org.label-schema.name="Envisaged-Redux" \
      org.label-schema.schema-version="0.1.0" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://gitlab.com/Cartoonman/envisaged-redux" \
      org.label-schema.version="0.1.4"

# Set our environment variables.
ENV XVFB_WHD="3840x2160x24" \
    DISPLAY=":99" \
    H265_PRESET="medium" \
    H265_CRF="28" \
    VIDEO_RESOLUTION="1080p" \
    GIT_URL="https://github.com/moby/moby" \
    LOGO_URL="" \
    GOURCE_SECONDS_PER_DAY="0.1" \
    GOURCE_TIME_SCALE="1.5" \
    GOURCE_USER_SCALE="1.5" \
    GOURCE_AUTO_SKIP_SECONDS="0.5" \
    GOURCE_TITLE="Software Development" \ 
    GOURCE_USER_IMAGE_DIR="/visualization/avatars" \
    GOURCE_BACKGROUND_COLOR="000000" \
    GOURCE_TEXT_COLOR="FFFFFF" \
    GOURCE_CAMERA_MODE="overview" \
    GOURCE_HIDE_ITEMS="mouse,date,filenames" \
    GOURCE_FONT_SIZE="48" \
    GOURCE_DIR_DEPTH="3" \
    GOURCE_FILENAME_TIME="2" \
    GOURCE_MAX_USER_SPEED="500" \
    OVERLAY_FONT_COLOR="0f5ca8" \
    INVERT_COLORS="false" \
    GLOBAL_FILTERS="" \
    GOURCE_FILTERS="" \
    TEMPLATE="border"

# Expose port 80 to serve mp4 video over HTTP
EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
