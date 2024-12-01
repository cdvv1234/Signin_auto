# 使用 Playwright 官方 Python 镜像
FROM mcr.microsoft.com/playwright/python:v1.38.0-focal

# 设置工作目录为 /app
WORKDIR /Signin_auto

# 复制代码到容器
COPY . /Signin_auto

# 安装依赖
RUN pip install -r requirements.txt

# 安装 Playwright 浏览器
RUN playwright install

# 设置默认启动命令，使用 gunicorn 启动
CMD ["gunicorn", "Signing_auto:app"]
