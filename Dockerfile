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
RUN apk update && apk add --no-cache curl bash sed

# Modify services.go to pass device argument to grabInput.sh
RUN curl -sSL https://raw.githubusercontent.com/Forceu/barcodebuddy-docker/master/supervisor/services/services.go -o /app/bbuddy/supervisor/services/services.go && \
    sed -i 's|"/bin/bash",|"/bin/bash", "/dev/input/event2",|' /app/bbuddy/supervisor/services/services.go

# Modify grabInput.sh to default to /dev/input/event2 if no argument is passed
RUN curl -sSL https://raw.githubusercontent.com/Forceu/barcodebuddy-docker/master/supervisor/example/grabInput.sh -o /app/bbuddy/example/grabInput.sh && \
    sed -i 's|# deviceToUse=""|deviceToUse="/dev/input/event2"|' /app/bbuddy/example/grabInput.sh && \
    sed -i 's|if [ $# -eq 0 ]; then|if [ $# -eq 0 ] && [ ! -e "$deviceToUse" ]; then|' /app/bbuddy/example/grabInput.sh

# Default command with the updated device argument for barcode scanner
CMD ["/app/supervisor"]
