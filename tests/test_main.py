from fastapi.testclient import TestClient

from app.main import app
from app import config

client = TestClient(app)


def test_root(requests_mock):
    requests_mock.get(config.PUBLIC_IP_SERVICE_URL, text="123.45.67.89")
    response = client.get("/")
    assert response.status_code == 200
    assert (
        response.content.decode()
        == "<h1>Hello, John Ripper!<h1><p>Public IP: 123.45.67.89</p>"
    )
    response = client.get("/?name=Bob")
    assert response.status_code == 200
    assert (
        response.content.decode() == "<h1>Hello, Bob!<h1><p>Public IP: 123.45.67.89</p>"
    )
