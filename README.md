# SBOM.sh Container Image

This repository contains the Dockerfile and scripts to build a container image that facilitates generating and uploading Software Bill of Materials (SBOM) to [SBOM.sh](https://sbom.sh) utilizing various open-source SBOM tools such as Trivy, Grype, and Syft.

## Container Image Location

You can pull the ready-made container image from Docker Hub:

```bash
docker pull codenotary/sbom.sh
```

## Features

- Generate SBOM for filesystems, container images, and local SBOM files.
- Upload SBOM to SBOM.sh and obtain a shareable URL.
- Optionally, trigger vulnerability scan and SBOM score calculation at SBOM.sh.

## Usage

### Building the Container Image yourself

```bash
git clone https://github.com/your-username/sbom-sh-container.git
cd sbom-sh-container
docker build -t sbom.sh:latest .
```

### Running the Container

#### Scanning Filesystems

```bash
docker run -v $(pwd):/app -it sbom.sh:latest trivyfs
```

#### Scanning Container Images

```bash
docker run -it sbom.sh:latest trivyimage [vulnscan] image-name
```

#### Sending Local SBOM file

```bash
docker run -v $(pwd):/app -it sbom.sh:latest sendsbom sbom-file-name # SBOM file in the mapped app folder
```

- Make sure to map your local directory to `/app` in the container using the `-v` flag.
- The `vulnscan` flag is optional and is used to trigger a vulnerability scan and SBOM score calculation at SBOM.sh.

## Commands Supported

- `trivyfs`: Scan the filesystem mapped to `/app` in the container using Trivy.
- `trivyimage`: Scan a specified container image using Trivy.
- `grypefs`: Scan the filesystem mapped to `/app` in the container using Grype.
- `grypeimage`: Scan a specified container image using Grype.
- `syftfs`: Scan the filesystem mapped to `/app` in the container using Syft.
- `syftimage`: Scan a specified container image using Syft.
- `sendsbom`: Send a local SBOM file to sbom.sh.

For each command, a URL to the generated SBOM on SBOM.sh is outputted to the terminal. If the `vulnscan` flag is specified (where applicable), additional vulnerability scanning and SBOM score calculation are triggered at sbom.sh.

## Dependencies

- [Trivy](https://github.com/aquasecurity/trivy)
- [Grype](https://github.com/anchore/grype)
- [Syft](https://github.com/anchore/syft)

## Contributing

Feel free to open issues or PRs if you have suggestions for improvements or additions to this container image.

## License

[Apache License 2.0](LICENSE)
