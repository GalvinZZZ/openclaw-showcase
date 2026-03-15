#!/bin/bash
# Cloudflare 注册和隧道配置脚本

echo "=== OpenClaw 固定域名配置 ==="
echo ""
echo "步骤："
echo "1. 访问 https://dash.cloudflare.com/sign-up 注册账号"
echo "2. 验证邮箱"
echo "3. 登录后获取 API Token"
echo "4. 运行本脚本完成配置"
echo ""

# 检查 cloudflared
if ! command -v cloudflared &> /dev/null; then
    echo "安装 cloudflared..."
    curl -L --output /tmp/cloudflared.tgz https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz
    tar -xzf /tmp/cloudflared.tgz -C /tmp
    cp /tmp/cloudflared ~/.local/bin/
    chmod +x ~/.local/bin/cloudflared
fi

echo ""
echo "请按以下步骤操作："
echo ""
echo "1. 打开浏览器访问："
echo "   https://dash.cloudflare.com/sign-up"
echo ""
echo "2. 使用邮箱注册（推荐用您的常用邮箱）"
echo ""
echo "3. 验证邮箱后，访问："
echo "   https://dash.cloudflare.com"
echo ""
echo "4. 在左侧菜单找到："
echo "   Zero Trust → Networks → Tunnels"
echo ""
echo "5. 点击 'Create a tunnel'，选择 'Cloudflared'"
echo ""
echo "6. 输入隧道名称：openclaw-showcase"
echo ""
echo "7. 复制显示的 Token（一长串字符）"
echo ""
echo "8. 回到终端，运行："
echo "   ~/.local/bin/cloudflared tunnel run --token YOUR_TOKEN"
echo ""
echo "9. 配置固定域名后，您的网站将永久可用："
echo "   https://openclaw-showcase.your-account.workers.dev"
echo ""

# 创建启动脚本
cat > ~/.local/bin/start-openclaw-fixed.sh << 'SCRIPT'
#!/bin/bash
# OpenClaw 固定域名启动脚本

TUNNEL_TOKEN="${TUNNEL_TOKEN:-}"

if [ -z "$TUNNEL_TOKEN" ]; then
    echo "错误：未设置 TUNNEL_TOKEN"
    echo "请先配置 Cloudflare Tunnel Token"
    exit 1
fi

# 启动本地服务
cd /Users/sz/.openclaw/workspace/projects/openclaw-showcase/backend
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8080 > /tmp/openclaw-showcase.log 2>&1 &

sleep 3

# 启动固定隧道
~/.local/bin/cloudflared tunnel run --token "$TUNNEL_TOKEN"
SCRIPT

chmod +x ~/.local/bin/start-openclaw-fixed.sh

echo "启动脚本已创建：~/.local/bin/start-openclaw-fixed.sh"
echo ""
echo "配置完成后，使用以下命令启动："
echo "   export TUNNEL_TOKEN=your_token_here"
echo "   start-openclaw-fixed.sh"
