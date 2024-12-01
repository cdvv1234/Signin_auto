# 使用 Playwright 官方镜像
FROM mcr.microsoft.com/playwright:v1.49.0-noble

# 安装 Python 和虚拟环境工具
RUN apt-get update -q && \
    apt-get install -y -qq --no-install-recommends \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        python3-venv  # 安装 Python 虚拟环境工具

# 设置工作目录
WORKDIR /app

# 拷贝项目的 requirements.txt
COPY requirements.txt .

# 创建虚拟环境并激活
RUN python3 -m venv /venv

# 激活虚拟环境并安装 Python 依赖
RUN /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install -r requirements.txt

# 拷贝项目文件到容器中
COPY . .

# 设置环境变量
ENV PATH="/venv/bin:$PATH"
ENV DISPLAY=:99

# 启动应用
CMD ["python3", "Signin_auto.py"]
