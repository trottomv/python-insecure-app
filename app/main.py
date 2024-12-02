import requests
from app import config
from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI(
    title="Try Hack Me",
    description="A sample project that will be hacked soon.",
    version="0.0.1337",
    debug=config.DEBUG,
)


@app.get("/", response_class=HTMLResponse)
def try_hack_me(name: str = None):
    query = name or config.SUPER_SECRET_NAME
    public_ip = requests.get(config.PUBLIC_IP_SERVICE_URL, timeout=1).text
    content = f"<h1>Hello, {query}!<h1><p>Public IP: {public_ip}</p>"
    # NOTE: https://fastapi.tiangolo.com/advanced/custom-response/#return-a-response
    return HTMLResponse(content)
