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
        libnss3

# 复制 requirements.txt 文件并安装 Python 依赖
COPY requirements.txt .

RUN pip3 install -r requirements.txt

# 安装 Playwright 所需的 Chromium 浏览器
RUN playwright install chromium

# 复制应用代码到容器
COPY . /Signin_auto

# 设置虚拟显示环境变量
ENV DISPLAY=:99

# 设置容器的启动命令，启动 Xvfb 并运行 Flask 应用
CMD Xvfb :99 -screen 0 1024x768x16 & gunicorn Signin_auto:app
