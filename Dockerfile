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
        yarn  # 安装 yarn

# 设置工作目录
WORKDIR /app

# 拷贝项目的 requirements.txt
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install -r requirements.txt

# 安装 Playwright 和 Playwright 的浏览器
RUN yarn add playwright && \
    yarn playwright install chromium

# 拷贝项目文件到容器中
COPY . .

# 设置环境变量
ENV DISPLAY=:99

# 启动应用
CMD ["Xvfb", ":99", "-screen", "0", "1024x768x16", "&", "python3", "Signin_auto.py"]
