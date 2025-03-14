FROM f0rc3/barcodebuddy:latest

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Barcode Buddy for Grocy" \
    io.hass.description="Barcode system for Grocy" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION}

# Install dependencies for modifying files
RUN apk update && apk add --no-cache bash sed

# Modify services.go directly
#RUN sed -i 's|"/bin/bash",|"/bin/bash", "/dev/input/event2",|' /app/supervisor/services/services.go

# Modify grabInput.sh directly to default to /dev/input/event2
RUN sed -i 's|deviceToUse=""|deviceToUse="/dev/input/event2"|g' /app/bbuddy/example/grabInput.sh
# Remove if clause from lines 111-122
RUN sed -i '111,122d' /app/bbuddy/example/grabInput.sh
# Remove option that runs the command in "screen" which introduces massive lag
RUN sed -i 's|sudo -H -u \$WWW_USER /usr/bin/screen -dm /usr/bin/php "\$SCRIPT_LOCATION" \$enteredText|sudo -H -u \$WWW_USER /usr/bin/php "\$SCRIPT_LOCATION" \$enteredText &|' /app/bbuddy/example/grabInput.sh


# Default command with the updated device argument for barcode scanner
CMD ["/app/supervisor"]
