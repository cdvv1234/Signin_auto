# 使用 Playwright 官方 Python 镜像
FROM mcr.microsoft.com/playwright/python:v1.38.0-focal

# 设置工作目录为 /app
WORKDIR /app

# 将本地代码复制到容器中
COPY . /app

# 安装 Python 依赖
RUN pip install -r requirements.txt

# 确保 Playwright 的浏览器已安装
RUN playwright install

# 设置默认启动命令，运行你的主程序
CMD ["python", "your_script.py"]
