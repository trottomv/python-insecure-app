# Python insecure and vulnerable demo app

This project is a deliberately vulnerable **FastAPI** application created to demonstrate common web vulnerabilities and how to perform **remediation** to mitigate them. The goal is to provide a practical example of **Data-Driven Development**, where **security audits** and **assessments** guide the development process to improve application security.

## Features

- **FastAPI application** with endpoints vulnerable to common web attacks.
- **Vulnerability analysis** using tools such as **pip-audit**, **Bandit**, **Trivy**, and other security tools.
- Practical demonstration of vulnerabilities and their corresponding **remediation**.
- Use of **shift-left** security practices, involving developers in security efforts from the early stages of development.

## Demonstrated vulnerabilities

This application intentionally includes the following vulnerabilities:

1. **Insecure dependencies**: Use of libraries with known vulnerabilities.
2. **Hardcoded secrets**: Credentials and API keys hardcoded into the code.
3. **Server-Side Template Injection (SSTI)**: Execution of malicious code via untrusted input in templates.

## Project objectives

1. **Demonstrate vulnerabilities**: Show how certain configurations or lack of validation can lead to real security risks.
2. **Security audits**: Use static and dynamic analysis tools to detect and categorize vulnerabilities.
3. **Remediation**: Show how to apply countermeasures to mitigate or eliminate vulnerabilities by following security best practices.
4. **Data-Driven development**: Demonstrate how security audits can guide the development cycle, integrating fixes based on concrete data.
5. **Shift-Left in security**: Integrate security in the early stages of the development and application lifecycle (DevSecOps).

## Tools used

- **FastAPI**: Framework used to build the web application.

    https://fastapi.tiangolo.com/

- **pip-audit**: Scans Python dependencies for known vulnerabilities.

    https://pypi.org/project/pip-audit/

- **Bandit**: Static code analysis for security vulnerabilities.

    https://bandit.readthedocs.io/en/latest/

- **Aqasec Trivy**: Scans for vulnerabilities in containers and dependencies.

    https://aquasecurity.github.io/trivy

- **Fuzzy Testing**: Fuzzy testing to uncover bugs and vulnerabilities.

    https://schemathesis.readthedocs.io/

- **OWASP Zap API Scan**: Testing tool for web vulnerabilities.

    https://www.zaproxy.org/docs/docker/api-scan/

- **Pre-commit**: Automates security checks before each commit.

    https://pre-commit.com/

## Requirements

- **Python 3.9+**
- **Astral uv**
- **make**
- **Docker**
- **Docker Compose**

## Installation

1. Clone the repository:

```shell
git clone https://github.com/trottomv/python-insecure-app
```

2. Copy the `.env_temp` file to `.env`

```shell
cp .env_temp .env
```

And update the necessary environment variables into `.env` file, such as:

```shell
SUPER_SECRET_NAME='John Ripper'
SUPER_SECRET_TOKEN='5u93R53Cr3tT0k3n'
```

3. Create and activate a virtual environment:

```shell
make venv
source .venv/bin/activate
```

4. Install the development dependencies:

```shell
make install_dev
```

## Running the application in development mode

To run the FastAPI application locally:

```shell
make rundev
```

The app will be available at http://127.0.0.1:1337

## Run with Docker Compose (optional)

To build and run the Docker image of the application:

```shell
make build
```

Set the `APP_IMAGE` environment variable in the `.env` file:

```shell
APP_IMAGE=python-insecure-app:latest
```

Then, run the application using Docker Compose:

```shell
docker compose up
```

## Running Tests

### Unit tests

1. Quick tests with coverage report

```shell
make quicktest
```

### Static security tests (SCA / SAST)

1. Check dependencies and common security issue

```shell
make audit
```

In this step, `pip-audit` and `bandit` will scan the project for known vulnerabilities in your Python dependencies and perform static code analysis to detect potential security flaws in your code. pip-audit checks for outdated or vulnerable packages, while bandit analyzes the codebase for common security issues such as hardcoded secrets, improper exception handling, and unsafe configurations.

### Fuzzy tests

```shell
make rundev
make fuzzytest
```

In this step, `schemathesis` will be used to perform fuzzy testing on your API endpoints. Schemathesis generates random, unexpected, and malformed inputs based on the OpenAPI specification of your application. This allows for the discovery of edge cases, bugs, and vulnerabilities that traditional unit tests might miss. By executing these tests, you can uncover issues such as improper input validation, crashes, or unhandled exceptions that could lead to security risks or degraded performance.

### Vulnerability Assessment

In this step, a Docker image of the application will be built, and **Trivy** will perform a vulnerability scan on the image. Trivy checks for known vulnerabilities in the base image, OS packages, application dependencies and Dockerfile misconfigurations. It identifies any critical, high, or medium security risks that could be present in your containerized application, such as outdated or insecure libraries, misconfigurations, or weak security settings. The results will help guide remediation efforts to secure the Docker environment and dependencies.

We have four different Dockerfiles:
- `Dockerfile`: The default Dockerfile that uses python:debian base image.
- `Dockerfile.alpine`: A Dockerfile that uses python:alpine base image.
- `Dockerfile.distroless`: A Dockerfile that uses python:distroless base image.
- `Dockerfile.wolfi`: A Dockerfile that uses python:wolfi base image.

1. Vulnerability Assessment for debian

```shell
make build
make vuln_assessment
```

2. Vulnerability Assessment for alpine

```shell
make build_alpine
make vuln_assessment tag=alpine
```

3. Vulnerability Assessment for distroless

```shell
make build_distroless
make vuln_assessment tag=distroless
```
4. Vulnerability Assessment for wolfi

```shell
make build_wolfi
make vuln_assessment tag=wolfi
```

### Verify distroless provenance

```shell
make verify_distroless_provenance
```

### Penetration test

```shell
make rundev
make pentest
```

In this step, we use `OWASP ZAP API Scan` to conduct a penetration test on the running application. **OWASP ZAP** (Zed Attack Proxy) is a widely used open-source tool for finding vulnerabilities in web applications. By configuring ZAP to perform automated scanning and manual testing, you can identify security weaknesses such as cross-site scripting (XSS), SQL injection, and security misconfigurations. The results will provide insights into potential vulnerabilities that may need remediation, helping to strengthen the overall security posture of the application.

## Pre-commit

1. Install pre-commit

```shell
pre-commit install
```

2. Run pre-commit

```shell
make precommit
```

3. Update pre-commit

```shell
make precommit_update
```
