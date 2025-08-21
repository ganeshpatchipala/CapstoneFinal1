from flask import Flask, request, jsonify
from models.detection import run_detection
from models.recipe_gen import generate_recipe
from utils.merge_utils import merge_detections
from flask_cors import CORS
import pprint
import sqlite3
from datetime import datetime

app = Flask(__name__)
CORS(app)

DB_PATH = 'meals.db'

# DB INITIALISATION 
def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            calories REAL,
            protein REAL,
            carbs REAL,
            fats REAL
        )
    ''')
    conn.commit()
    conn.close()

init_db()

# ROUTES 
@app.route('/log_meal', methods=['POST'])
def log_meal():
    data = request.get_json()
    print("RAW received:", data)
    try:
        name = str(data['name'])
        calories = float(data.get('calories', 0))
        protein = float(data.get('protein', 0))
        carbs = float(data.get('carbs', 0))
        fats = float(data.get('fats', 0))
        date = datetime.now().strftime('%Y-%m-%d')


        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO meals (name, date, calories, protein, carbs, fats)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (name, date, calories, protein, carbs, fats))
        conn.commit()
        conn.close()

        return jsonify({'status': 'success'}), 201
    except Exception as e:
        print("ERROR while logging meal:", str(e))  # ✅ Print to terminal
        return jsonify({'status': 'error', 'message': str(e)}), 400


@app.route('/daily_totals', methods=['GET'])
def get_daily_totals():
    date = datetime.now().strftime('%Y-%m-%d')
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        SELECT 
            SUM(calories),
            SUM(protein),
            SUM(carbs),
            SUM(fats)
        FROM meals
        WHERE date = ?
    ''', (date,))
    result = cursor.fetchone()
    conn.close()

    return jsonify({
        'date': date,
        'total_calories': result[0] or 0,
        'total_protein': result[1] or 0,
        'total_carbs': result[2] or 0,
        'total_fats': result[3] or 0
    })

@app.route('/daily_meals', methods=['GET'])
def get_daily_meals():
    date = datetime.now().strftime('%Y-%m-%d')
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        SELECT name, calories, protein, carbs, fats
        FROM meals
        WHERE date = ?
    ''', (date,))
    rows = cursor.fetchall()
    conn.close()

    meals = [
        {
            'name': row[0],
            'calories': row[1],
            'protein': row[2],
            'carbs': row[3],
            'fats': row[4]
        }
        for row in rows
    ]
    return jsonify(meals)

@app.route('/')
def home():
    return """
    <h2> Fridge AI Backend is Running</h2>
    
    """

@app.route('/detect', methods=['POST'])
def detect():
    from models.detection import run_detection
    image = request.files['image'].read()
    yolov8_dets, zsd_dets = run_detection(image)
    merged = merge_detections(yolov8_dets, zsd_dets)
    pprint.pprint(merged)
    print("Returning:", merged)
    return jsonify({"detections": merged})

@app.route('/generate_recipe', methods=['POST'])
def recipe():
    from models.recipe_gen import generate_recipe
    data = request.json
    ingredients = data.get('ingredients')
    recipe_output = generate_recipe(ingredients)
    print("=== RETURNING JSON TO FLUTTER ===")
    print("Returning:", recipe_output)
    return jsonify({"recipe": recipe_output})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)