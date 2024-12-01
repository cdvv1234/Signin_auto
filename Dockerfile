# 使用 Python 3.11 基础镜像
FROM python:3.11

# 设置非交互模式，避免 apt-get 安装过程中出现提示
ARG DEBIAN_FRONTEND=noninteractive

# 更新并安装 Chromium 所需的库和 Xvfb（虚拟显示）
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
        yarn # 安装 yarn

# 复制 requirements.txt 文件并安装 Python 依赖
COPY requirements.txt .

RUN pip3 install -r requirements.txt

# 安装 Playwright 所需的 Chromium 浏览器
RUN yarn playwright install chromium

# 设置 Playwright 浏览器缓存路径为 /opt/render/project/playwright
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/render/project/playwright

# 确保 Playwright 安装了 Chromium，如果缓存不存在则下载并保存缓存
RUN if [ ! -d "$PLAYWRIGHT_BROWSERS_PATH" ]; then \
    echo "...Storing Playwright Cache in Build Cache" && \
    cp -R $PLAYWRIGHT_BROWSERS_PATH $XDG_CACHE_HOME/playwright/; \
  else \
    echo "...Copying Playwright Cache from Build Cache" && \
    cp -R $XDG_CACHE_HOME/playwright/ $PLAYWRIGHT_BROWSERS_PATH; \
  fi

# 复制应用代码到容器
COPY . /Signin_auto

# 设置虚拟显示环境变量
ENV DISPLAY=:99

# 设置容器的启动命令，启动 Xvfb 并运行 Flask 应用
CMD Xvfb :99 -screen 0 1024x768x16 & gunicorn Signin_auto:app
