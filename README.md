# Python Insecure and Vulnerable Demo App

This project is a deliberately vulnerable **FastAPI** application created to demonstrate common web vulnerabilities and how to perform **remediation** to mitigate them. The goal is to provide a practical example of **Data-Driven Development**, where **security audits** and **assessments** guide the development process to improve application security.

## Features

- **FastAPI application** with endpoints vulnerable to common web attacks.
- **Vulnerability analysis** using tools such as **pip-audit**, **Bandit**, **Trivy**, and other security tools.
- Practical demonstration of vulnerabilities and their corresponding **remediation**.
- Use of **shift-left** security practices, involving developers in security efforts from the early stages of development.

## Demonstrated Vulnerabilities

This application intentionally includes the following vulnerabilities:

1. **Insecure Dependencies**: Use of libraries with known vulnerabilities.
2. **Hardcoded Secrets**: Credentials and API keys hardcoded into the code.
3. **Server-Side Template Injection (SSTI)**: Execution of malicious code via untrusted input in templates.

## Project Objectives

1. **Demonstrate vulnerabilities**: Show how certain configurations or lack of validation can lead to real security risks.
2. **Security Audits**: Use static and dynamic analysis tools to detect and categorize vulnerabilities.
3. **Remediation**: Show how to apply countermeasures to mitigate or eliminate vulnerabilities by following security best practices.
4. **Data-Driven Development**: Demonstrate how security audits can guide the development cycle, integrating fixes based on concrete data.
5. **Shift Left in Security**: Integrate security in the early stages of the development and application lifecycle (DevSecOps).

## Tools Used

- **FastAPI**: Framework used to build the application.
- **pip-audit**: Scans Python dependencies for known vulnerabilities.
- **Bandit**: Static code analysis for security vulnerabilities.
- **Trivy**: Scans for vulnerabilities in containers and dependencies.
- **Pre-commit**: Automates security checks before each commit.
- **Fuzzy Testing**: Automatic testing to uncover bugs and vulnerabilities.
- **OWASP Zap**: Testing tool for web vulnerabilities.

## Requirements

- **Python 3.9+**
- **make**
- **Docker**

## Installation

1. Clone the repository:

```shell
git clone https://github.com/your-username/fastapi-vulnerable-demo.git
```

2. Create and activate a virtual environment:

```shell
python3 -m venv .venv
source .venv/bin/activate
```

3. Install the dependencies:

```shell
make install_dev
```

## Running the Application

To run the FastAPI application locally:

```shell
make rundev
```

The app will be available at http://127.0.0.1:8000


## Running Tests

1. Quick tests with coverage report

```shell
make quicktest
```

## Running Security Tests

1. Check dependencies and common security issue

```shell
make audit
```

In this step, `pip-audit` and `bandit` will scan the project for known vulnerabilities in your Python dependencies and perform static code analysis to detect potential security flaws in your code. pip-audit checks for outdated or vulnerable packages, while bandit analyzes the codebase for common security issues such as hardcoded secrets, improper exception handling, and unsafe configurations.

2. Fuzzy tests

```shell
make rundev
make fuzzytests
```

In this step, `schemathesis` will be used to perform fuzzy testing on your API endpoints. Schemathesis generates random, unexpected, and malformed inputs based on the OpenAPI specification of your application. This allows for the discovery of edge cases, bugs, and vulnerabilities that traditional unit tests might miss. By executing these tests, you can uncover issues such as improper input validation, crashes, or unhandled exceptions that could lead to security risks or degraded performance.

3. Vulnerability Assessment

```shell
make build
make vulnerabilityassessment
```

In this step, a Docker image of the application will be built, and **Trivy** will perform a vulnerability scan on the image. Trivy checks for known vulnerabilities in the base image, OS packages, application dependencies and Dockerfile misconfigurations. It identifies any critical, high, or medium security risks that could be present in your containerized application, such as outdated or insecure libraries, misconfigurations, or weak security settings. The results will help guide remediation efforts to secure the Docker environment and dependencies.

4. Penetration test

```shell
make rundev
make pentest
```

In this step, we use `OWASP ZAP` to conduct a penetration test on the running application. **OWASP ZAP** (Zed Attack Proxy) is a widely used open-source tool for finding vulnerabilities in web applications. By configuring ZAP to perform automated scanning and manual testing, you can identify security weaknesses such as cross-site scripting (XSS), SQL injection, and security misconfigurations. The results will provide insights into potential vulnerabilities that may need remediation, helping to strengthen the overall security posture of the application.

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
