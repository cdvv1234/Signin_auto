# 使用 Playwright 官方 Docker 镜像
FROM mcr.microsoft.com/playwright:v1.49.0-noble

# 安装系统依赖和 Python 依赖
RUN apt-get update -q && \
    apt-get install -y -qq --no-install-recommends \
        curl \
        gnupg \
        lsb-release \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        npm  # 安装 npm

# 设置工作目录
WORKDIR /app

# 拷贝项目的 requirements.txt
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install -r requirements.txt

# 拷贝项目文件到容器中
COPY . .

# 设置环境变量
ENV DISPLAY=:99

# 启动应用
CMD ["python3", "Signin_auto.py"]
