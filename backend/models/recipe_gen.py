import re
import openai
import os
from dotenv import load_dotenv
load_dotenv()


client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def generate_recipe(ingredients):
    prompt = (
    f"Given the following fridge contents: {', '.join(ingredients)}, "
    "generate a healthy high-protein recipe using these ingredients. "
    "Format your output as follows:\n\n"
    "Title: <Recipe Name>\n\n"
    "Ingredients:\n- List ingredients with amounts and calories/macros if known\n\n"
    "Instructions:\n- List clear steps\n\n"
    "Nutrition (Approximate):\n"
    "- Total Calories: <number>\n"
    "- Protein: <number>g\n"
    "- Fat: <number>g\n"
    "- Carbohydrates: <number>g\n\n"
    "Make sure to provide actual numeric values for calories and macros, not placeholders like XXX. You do not need to use all the ingredients, just what makes sense for the recipe."
)


    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are a helpful AI chef assistant."},
            {"role": "user", "content": prompt}
        ]
    )

    content = response.choices[0].message.content

    # Extract title
    title_match = re.search(r'^Title:\s*(.+)', content, re.MULTILINE)
    title = title_match.group(1).strip() if title_match else "Unnamed Recipe"

    # Extract nutrition info
    calories = extract_number(content, r'Total Calories:\s*(\d+)')
    protein = extract_number(content, r'Protein:\s*(\d+)\s?g')
    fats = extract_number(content, r'Fat[s]?:\s*(\d+)\s?g')
    carbs = extract_number(content, r'Carbohydrates:\s*(\d+)\s?g')

    return {
        "recipe_text": content,
        "meal_name": title,
        "calories": calories,
        "protein": protein,
        "carbs": carbs,
        "fats": fats
    }

def extract_number(text, pattern):
    match = re.search(pattern, text, re.IGNORECASE)
    return float(match.group(1)) if match else 0.0
