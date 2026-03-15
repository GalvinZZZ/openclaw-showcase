"""
OpenClaw 展示网站后端
FastAPI + Jinja2 模板
"""

from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse
from markupsafe import Markup
import json
import os

app = FastAPI(title="OpenClaw 展示网站")

# 获取数据目录路径
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
FRONTEND_DIR = os.path.join(os.path.dirname(BASE_DIR), "frontend")

# 加载内容数据
def load_content():
    with open(os.path.join(DATA_DIR, "content.json"), "r", encoding="utf-8") as f:
        return json.load(f)

# 静态文件配置
app.mount("/images", StaticFiles(directory=os.path.join(FRONTEND_DIR, "images")), name="images")

# 模板配置
templates = Jinja2Templates(directory=FRONTEND_DIR)

# 添加 safe 过滤器
def safe_filter(text):
    return Markup(text)

templates.env.filters['safe'] = safe_filter

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    """首页"""
    content = load_content()
    return templates.TemplateResponse("index.html", {
        "request": request,
        "content": content
    })

@app.get("/api/content")
async def get_content():
    """获取所有内容数据 API"""
    return load_content()

@app.get("/api/health")
async def health_check():
    """健康检查"""
    return {"status": "ok", "service": "openclaw-showcase"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
