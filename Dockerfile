# Use the official bash image from the Docker Hub
FROM bash 

# add main script
COPY sbom.sh /usr/local/bin/sbom.sh
RUN chmod +x /usr/local/bin/sbom.sh

# add OS tools
RUN apk add --update --no-cache curl jq

# add trivy, syft and grype
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -x -s -- -b /usr/local/bin
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

ENV SBOM_SH_SERVER="https://sbom.sh"

# RUN Entrypoint Script sbom.sh
ENTRYPOINT ["/usr/local/bin/sbom.sh"]

