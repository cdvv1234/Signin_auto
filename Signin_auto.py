from flask import Flask, render_template, request, jsonify
from playwright.sync_api import sync_playwright, TimeoutError
from datetime import datetime
import time

app = Flask(__name__)

def get_today_date():
    return datetime.now().strftime("%Y-%m-%d")

def login_and_punch_in_or_out(action, username, password):
    if not username or not password:
        return {"error": "账号或密码不能为空，请输入完整信息！"}

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            page = browser.new_page()
            page.goto("http://daka.bbnamg.com/login")
            page.fill("#username", username)
            page.fill("#password", password)
            page.click("button[type='submit']")
            page.wait_for_selector('#ReadBulletinModal', state='visible')

            if page.is_visible("#ReadBulletinModal"):
                close_button = page.locator("#ReadBulletinModal").locator("button.btn.btn-secondary:has-text('关闭')")
                close_button.click()
                page.wait_for_selector("#ReadBulletinModal", state="hidden")

            today_date = get_today_date()
            row_locator = page.locator(f"table tbody tr:has(td:text-is('{today_date}'))")
            punch_in_time_locator = row_locator.locator("td:nth-child(2)")
            punch_out_time_locator = row_locator.locator("td:nth-child(3)")

            punch_in_time = (
                punch_in_time_locator.inner_text().strip() if punch_in_time_locator.count() > 0 else None
            )
            punch_out_time = (
                punch_out_time_locator.inner_text().strip() if punch_out_time_locator.count() > 0 else None
            )

            result = {}

            if action == "上班签到":
                if punch_in_time:
                    result["message"] = f"今天已签到，签到时间：{punch_in_time}"
                else:
                    page.click("#work_btn")
                    page.wait_for_selector('#ConfirmModal', state='visible')
                    close_button = page.locator("#ConfirmModal").locator("button.btn-confirm.btn-primary:has-text('确认')")
                    close_button.click()
                    page.wait_for_selector("#ConfirmModal", state="hidden")
                    time.sleep(2)
                    punch_in_time = punch_in_time_locator.inner_text().strip()
                    result["message"] = f"上班签到成功，签到时间：{punch_in_time}"

            elif action == "下班签退":
                if punch_out_time:
                    result["message"] = f"今天已签退，签退时间：{punch_out_time}"
                else:
                    page.click("#off_work_btn")
                    page.wait_for_selector('#ConfirmModal', state='visible')
                    close_button = page.locator("#ConfirmModal").locator("button.btn-confirm.btn-primary:has-text('确认')")
                    close_button.click()
                    page.wait_for_selector("#ConfirmModal", state="hidden")
                    time.sleep(2)
                    punch_out_time = punch_out_time_locator.inner_text().strip()
                    result["message"] = f"下班签退成功，签退时间：{punch_out_time}"

            browser.close()
            return result

    except TimeoutError:
        return {"error": "页面加载超时，请检查网络连接。"}
    except Exception as e:
        return {"error": f"发生未知错误：{e}"}

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/punch', methods=['POST'])
def punch():
    action = request.form.get('action')
    username = request.form.get('username')
    password = request.form.get('password')

    if not action or not username or not password:
        return jsonify({"error": "請輸入所有必要的信息！"})

    print(f"Received action: {action}, username: {username}, password: {password}")
    
    result = login_and_punch_in_or_out(action, username, password)
    return jsonify(result)

if __name__ == '__main__':
     # 获取环境变量中的端口（如果没有指定端口，默认使用 5000）
    port = int(os.environ.get('PORT', 5000))
    # 绑定到 0.0.0.0 以允许外部访问
    app.run(host='0.0.0.0', port=port, debug=True)
