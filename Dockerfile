# 使用 Playwright 官方 Docker 镜像
FROM mcr.microsoft.com/playwright:v1.49.0-noble

# 安装 Python 依赖和其他必要的系统依赖
RUN apt-get update -q && \
    apt-get install -y -qq --no-install-recommends \
        curl \
        gnupg \
        lsb-release \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        npm

# 设置工作目录
WORKDIR /app

# 拷贝项目的 requirements.txt 并安装 Python 依赖
COPY requirements.txt . 
RUN pip3 install -r requirements.txt

# 拷贝项目文件到容器中
COPY . .

# 设置环境变量
ENV DISPLAY=:99

# 启动应用
CMD ["python3", "Signin_auto.py"]
