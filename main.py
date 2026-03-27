from flask import Flask, request, jsonify, render_template, make_response
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import pandas as pd
import io

app = Flask(__name__)
CORS(app)

# --- КОНФИГУРАЦИЯ БАЗЫ ДАННЫХ ---
DB_CONFIG = {
    "host": "localhost",
    "database": "restaurant_db",
    "user": "root",
    "password": "1234"  # <--- ВВЕДИ СВОЙ ПАРОЛЬ ОТ MYSQL
}


def get_db_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        print(f"Ошибка БД: {e}")
        return None


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    u, p = data.get("username"), data.get("password")
    if u == "guest": return jsonify({"user": {"id": 0, "username": "Гость", "role": "гость"}}), 200

    conn = get_db_connection()
    if not conn: return jsonify({"message": "Ошибка БД"}), 500
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, username, role FROM users WHERE username=%s AND password=%s", (u, p))
    user = cursor.fetchone()
    conn.close()

    if user: return jsonify({"user": user}), 200
    return jsonify({"message": "Неверные данные"}), 401


@app.route("/api/stats", methods=["GET"])
def get_stats():
    conn = get_db_connection()
    if not conn: return jsonify({}), 500
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM tables WHERE status='свободен'")
    free = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM tables WHERE status='занят'")
    busy = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM reservations WHERE DATE(reservation_datetime)=CURDATE()")
    res = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM orders WHERE status!='закрыт'")
    ord_act = cursor.fetchone()[0]
    conn.close()
    return jsonify({"free_tables": free, "busy_tables": busy, "today_reservations": res, "active_orders": ord_act})


# --- АНАЛИТИКА PRO И ПРОГНОЗИРОВАНИЕ ---
@app.route("/api/analytics", methods=["GET"])
def get_analytics():
    conn = get_db_connection()
    if not conn: return jsonify({}), 500
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT DATE(o.order_datetime) as date, SUM(oi.quantity * m.price) as total_revenue 
        FROM orders o 
        JOIN order_items oi ON o.id = oi.order_id 
        JOIN menu m ON oi.dish_name = m.name 
        WHERE o.status = 'закрыт' 
        GROUP BY DATE(o.order_datetime) 
        ORDER BY date ASC LIMIT 7
    """)
    rev = cursor.fetchall()

    cursor.execute("""
        SELECT dish_name, SUM(quantity) as total_sold 
        FROM order_items 
        GROUP BY dish_name 
        ORDER BY total_sold DESC LIMIT 5
    """)
    pop = cursor.fetchall()

    # Прогнозирование на основе последних двух дней
    forecast_hint = "Слишком мало данных для составления точного прогноза."
    if len(rev) >= 2:
        last_val = rev[-1]['total_revenue']
        prev_val = rev[-2]['total_revenue']
        if last_val > prev_val:
            forecast_hint = f"📈 Выручка растет! Сегодня заработали {last_val}₽ (больше, чем вчера - {prev_val}₽). Рекомендуем вывести больше поваров в выходные."
        else:
            forecast_hint = f"📉 Спрос немного упал. Сегодня {last_val}₽ против {prev_val}₽ вчера. Отличное время для инвентаризации склада."
    elif len(rev) == 1:
        forecast_hint = f"📊 Выручка за зафиксированный день: {rev[0]['total_revenue']}₽. Ждем данных за завтра для прогноза."

    conn.close()
    return jsonify({"revenue": rev, "popular": pop, "forecast": forecast_hint})


# --- ВЫГРУЗКА EXCEL ОТЧЕТА ---
@app.route("/api/report/download", methods=["GET"])
def download_report():
    conn = get_db_connection()
    if not conn: return "Ошибка БД", 500
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT o.id as 'Номер заказа', 
               o.order_datetime as 'Дата и время', 
               IFNULL(u.username, 'Неизвестно') as 'Кем закрыт', 
               t.table_number as 'Стол',
               GROUP_CONCAT(CONCAT(oi.dish_name, ' (', oi.quantity, ' шт)') SEPARATOR ', ') as 'Блюда',
               SUM(oi.quantity * m.price) as 'Сумма (Без чаевых, ₽)'
        FROM orders o
        LEFT JOIN users u ON o.created_by = u.id
        JOIN tables t ON o.table_id = t.id
        JOIN order_items oi ON o.id = oi.order_id
        JOIN menu m ON oi.dish_name = m.name
        WHERE o.status = 'закрыт'
        GROUP BY o.id
        ORDER BY o.order_datetime DESC
    """)
    data = cursor.fetchall()
    conn.close()

    if not data:
        return "Нет закрытых заказов для формирования отчета", 404

    # Формируем Excel файл в памяти
    df = pd.DataFrame(data)
    # Убираем временную зону для корректного сохранения в Excel
    df['Дата и время'] = pd.to_datetime(df['Дата и время']).dt.tz_localize(None)

    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Отчет по заказам')

    output.seek(0)

    response = make_response(output.getvalue())
    response.headers["Content-Disposition"] = "attachment; filename=restaurant_report.xlsx"
    response.headers["Content-type"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    return response


# --- СТОЛЫ И БРОНИРОВАНИЕ ---
@app.route("/api/tables", methods=["GET", "PUT"])
def handle_tables():
    conn = get_db_connection()
    if not conn: return jsonify([]), 500
    cursor = conn.cursor(dictionary=True)
    if request.method == "GET":
        cursor.execute("SELECT * FROM tables")
        t = cursor.fetchall()
        conn.close()
        return jsonify(t)
    else:
        cursor.execute("UPDATE tables SET status=%s WHERE id=%s", (request.json.get("status"), request.json.get("id")))
        conn.commit()
        conn.close()
        return jsonify({"msg": "ok"}), 200


@app.route("/api/reservations", methods=["GET", "POST"])
def handle_reservations():
    conn = get_db_connection()
    if not conn: return jsonify([]), 500
    cursor = conn.cursor(dictionary=True)
    if request.method == "GET":
        cursor.execute(
            "SELECT r.*, t.table_number FROM reservations r JOIN tables t ON r.table_id = t.id ORDER BY r.reservation_datetime")
        data = cursor.fetchall()
        for d in data:
            if d["reservation_datetime"]: d["reservation_datetime"] = d["reservation_datetime"].strftime(
                "%Y-%m-%d %H:%M")
        conn.close()
        return jsonify(data)
    else:
        d = request.json
        uid = d.get("user_id") if d.get("user_id") != 0 else None
        try:
            cursor.execute(
                "INSERT INTO reservations (client_name, client_phone, reservation_datetime, table_id, created_by) VALUES (%s, %s, %s, %s, %s)",
                (d["client_name"], d.get("client_phone", ""), d["datetime"], d["table_id"], uid))
        except Error:
            cursor.execute(
                "INSERT INTO reservations (client_name, reservation_datetime, table_id, created_by) VALUES (%s, %s, %s, %s)",
                (d["client_name"], d["datetime"], d["table_id"], uid))
        cursor.execute("UPDATE tables SET status='занят' WHERE id=%s", (d["table_id"],))
        conn.commit()
        conn.close()
        return jsonify({"message": "Создано"}), 201


@app.route("/api/reservations/<int:id>", methods=["DELETE"])
def delete_reservation(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM reservations WHERE id=%s", (id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Удалено"}), 200


# --- МЕНЮ И ОТЗЫВЫ ---
@app.route("/api/menu", methods=["GET", "POST"])
def handle_menu():
    conn = get_db_connection()
    if not conn: return jsonify([]), 500
    cursor = conn.cursor(dictionary=True)
    if request.method == "GET":
        try:
            cursor.execute(
                "SELECT m.*, IFNULL(ROUND(AVG(r.rating), 1), 0) as avg_rating, COUNT(r.id) as review_count FROM menu m LEFT JOIN reviews r ON m.id = r.dish_id GROUP BY m.id ORDER BY m.category, m.name")
            menu = cursor.fetchall()
        except Error:
            cursor.execute("SELECT * FROM menu ORDER BY category, name")
            menu = cursor.fetchall()
        conn.close()
        return jsonify(menu)
    else:
        d = request.json
        try:
            cursor.execute("INSERT INTO menu (name, price, category, stock) VALUES (%s, %s, %s, %s)",
                           (d["name"], d["price"], d["category"], d.get("stock", 10)))
        except Error:
            cursor.execute("INSERT INTO menu (name, price, category) VALUES (%s, %s, %s)",
                           (d["name"], d["price"], d["category"]))
        conn.commit()
        conn.close()
        return jsonify({"message": "Добавлено"}), 201


@app.route("/api/menu/<int:id>", methods=["DELETE"])
def delete_menu_item(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM menu WHERE id=%s", (id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Удалено"}), 200


@app.route("/api/all_reviews", methods=["GET"])
def get_all_reviews():
    conn = get_db_connection()
    if not conn: return jsonify([]), 500
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(
            "SELECT r.*, m.name as dish_name FROM reviews r JOIN menu m ON r.dish_id = m.id ORDER BY r.created_at DESC")
        res = cursor.fetchall()
        for r in res:
            if r['created_at']: r['created_at'] = r['created_at'].strftime('%d.%m.%Y %H:%M')
        conn.close()
        return jsonify(res)
    except Error:
        conn.close()
        return jsonify([])


@app.route("/api/reviews", methods=["POST"])
def add_review():
    d = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO reviews (dish_id, client_name, rating, comment) VALUES (%s, %s, %s, %s)",
                   (d["dish_id"], d["client_name"], d["rating"], d["comment"]))
    conn.commit()
    conn.close()
    return jsonify({"message": "Отзыв добавлен"}), 201


# --- ЗАКАЗЫ И БИЛЛИНГ (ЧЕКИ) ---
@app.route("/api/orders", methods=["GET", "POST"])
def handle_orders():
    conn = get_db_connection()
    if not conn: return jsonify([]), 500
    cursor = conn.cursor(dictionary=True)

    if request.method == "GET":
        cursor.execute(
            "SELECT o.id, t.table_number, o.status, o.order_datetime, GROUP_CONCAT(CONCAT(oi.dish_name, ' x', oi.quantity) SEPARATOR ', ') as dishes FROM orders o JOIN tables t ON o.table_id = t.id JOIN order_items oi ON o.id = oi.order_id GROUP BY o.id ORDER BY o.order_datetime DESC")
        orders = cursor.fetchall()
        for o in orders:
            if o["order_datetime"]: o["order_datetime"] = o["order_datetime"].strftime("%H:%M")
        conn.close()
        return jsonify(orders)
    else:
        data = request.json
        cart = data.get("cart", [])
        uid = data.get("user_id") if data.get("user_id") != 0 else None

        try:
            # Создаем заказ ('открыт')
            cursor.execute("INSERT INTO orders (table_id, created_by, status) VALUES (%s, %s, 'открыт')",
                           (data["table_id"], uid))
            oid = cursor.lastrowid

            for item in cart:
                cursor.execute("INSERT INTO order_items (order_id, dish_name, quantity) VALUES (%s, %s, %s)",
                               (oid, item["name"], item["quantity"]))
                try:
                    cursor.execute("UPDATE menu SET stock = stock - %s WHERE name = %s",
                                   (item['quantity'], item['name']))
                except Error:
                    pass

            cursor.execute("UPDATE tables SET status='занят' WHERE id=%s", (data["table_id"],))
            conn.commit()
            return jsonify({"message": "Заказ создан"}), 201
        except Error as e:
            conn.rollback()
            return jsonify({"message": str(e)}), 500
        finally:
            conn.close()


@app.route("/api/orders/<int:id>/status", methods=["PUT"])
def update_order_status(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE orders SET status=%s WHERE id=%s", (request.json.get("status"), id))
    conn.commit()
    conn.close()
    return jsonify({"message": "Статус обновлен"}), 200


@app.route("/api/orders/<int:id>/bill", methods=["GET"])
def get_order_bill(id):
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Ошибка БД"}), 500
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT oi.dish_name, oi.quantity, m.price, (oi.quantity * m.price) as item_total FROM order_items oi JOIN menu m ON oi.dish_name = m.name WHERE oi.order_id = %s",
        (id,))
    items = cursor.fetchall()

    subtotal = sum(i["item_total"] for i in items)
    tax = round(subtotal * 0.1, 2)
    conn.close()
    return jsonify({"items": items, "subtotal": subtotal, "tax": tax, "total": subtotal + tax})


@app.route("/api/orders/<int:id>/close", methods=["PUT"])
def close_order(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE tables SET status='свободен' WHERE id=(SELECT table_id FROM orders WHERE id=%s)", (id,))
    cursor.execute("UPDATE orders SET status='закрыт' WHERE id=%s", (id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Заказ закрыт"}), 200


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)