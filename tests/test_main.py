"""Test cases for the FastAPI application."""

import requests
from fastapi.testclient import TestClient

from app import config
from app.main import app

client = TestClient(app)


def test_root(requests_mock):
    # Mock the public IP service response to raise an HTTPError exception
    requests_mock.get(config.PUBLIC_IP_SERVICE_URL, exc=requests.HTTPError)
    # Test root endpoint with 'Unknown' public IP
    response = client.get("/")
    assert response.status_code == 200
    assert (
        response.content.decode()
        == "<h1>Hello, John Ripper!</h1><h2>Public IP: <code>Unknown</code></h2>"
    )
    # Mock the public IP service response
    requests_mock.get(config.PUBLIC_IP_SERVICE_URL, text="123.45.67.89")
    # Test the root endpoint
    response = client.get("/")
    assert response.status_code == 200
    assert (
        response.content.decode()
        == "<h1>Hello, John Ripper!</h1><h2>Public IP: <code>123.45.67.89</code></h2>"
    )
    # Test the root endpoint with name parameter
    response = client.get("/?name=Bob")
    assert response.status_code == 200
    assert (
        response.content.decode()
        == "<h1>Hello, Bob!</h1><h2>Public IP: <code>123.45.67.89</code></h2>"
    )
    response = client.get("/?name={{7*6}}")
    assert response.status_code == 200
    assert "42" not in response.content.decode()
    assert "{{7*6}}" in response.content.decode()
