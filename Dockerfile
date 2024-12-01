FROM python:3.11

# 安装必要的系统依赖
RUN apt-get update -q && \
    apt-get install -y -qq --no-install-recommends \
        xvfb \
        libxcomposite1 \
        libxdamage1 \
        libatk1.0-0 \
        libasound2 \
        libdbus-1-3 \
        libnspr4 \
        libgbm1 \
        libatk-bridge2.0-0 \
        libcups2 \
        libxkbcommon0 \
        libatspi2.0-0 \
        libnss3 \
        curl \
        gnupg \
        lsb-release \
        npm && \
    rm -rf /var/lib/apt/lists/*  # 清理 apt 缓存以减小镜像

# 设置工作目录
WORKDIR /app

# 拷贝项目的 requirements.txt
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 安装 Playwright 和 Playwright 的浏览器
RUN npm install playwright && \
    npx playwright install chromium

# 设置环境变量
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/render/project/playwright
ENV XDG_CACHE_HOME=/opt/render/project/.cache

# 打印调试信息
RUN echo "PLAYWRIGHT_BROWSERS_PATH=$PLAYWRIGHT_BROWSERS_PATH"
RUN echo "XDG_CACHE_HOME=$XDG_CACHE_HOME"

# 确保缓存路径存在并处理 Playwright 缓存
RUN mkdir -p $PLAYWRIGHT_BROWSERS_PATH && \
    mkdir -p $XDG_CACHE_HOME/playwright && \
    if [ ! -d "$PLAYWRIGHT_BROWSERS_PATH" ]; then \
    echo "...Copying Playwright Cache from Build Cache" && \
    cp -R $XDG_CACHE_HOME/playwright/ $PLAYWRIGHT_BROWSERS_PATH; \
    else \
    echo "...Storing Playwright Cache in Build Cache" && \
    cp -R $PLAYWRIGHT_BROWSERS_PATH $XDG_CACHE_HOME; \
    fi

# 拷贝项目文件到容器中
COPY . .

# 设置环境变量
ENV DISPLAY=:99

# 启动应用，使用 shell 脚本来同时启动 Xvfb 和 Python 应用
CMD Xvfb :99 -screen 0 1024x768x16 & python3 Signin_auto.py
