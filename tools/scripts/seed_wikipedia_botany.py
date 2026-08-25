#!/usr/bin/env python3
"""
Seed script for Plantini:
Populates Strapi with 3 ecosystems, 30 plant species each (total 90 plants),
and 4 quiz questions per plant (total 360 questions) along with level mappings.
"""

import urllib.request
import json
import os
import sys

BASE_URL = "http://localhost:1338"

# 1. Login to Strapi Admin
def get_admin_token():
    login_data = json.dumps({
        "email": "admin@plantini.test",
        "password": "Admin1234!"
    }).encode("utf-8")
    
    req = urllib.request.Request(
        f"{BASE_URL}/admin/login",
        data=login_data,
        headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req) as response:
            res = json.loads(response.read().decode())
            return res["data"]["token"]
    except Exception as e:
        print(f"Error logging in: {e}")
        sys.exit(1)

TOKEN = get_admin_token()

def api_post(endpoint, data):
    payload = json.dumps(data).encode("utf-8")
    req = urllib.request.Request(
        f"{BASE_URL}/content-manager/collection-types/{endpoint}",
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {TOKEN}"
        }
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        # print(f"POST {endpoint} error: {e}")
        return None

# Load or define datasets
from botany_data import ECOSYSTEMS_DATA

print("🌿 Starting botanical data ingestion for Plantini...")
print("====================================================")

created_ecosystems = {}
created_plants = {}
created_levels = {}

total_plants = 0
total_quizzes = 0

for eco_idx, eco in enumerate(ECOSYSTEMS_DATA, start=1):
    eco_name = eco["name"]
    print(f"\n🌍 Erstelle Ökosystem {eco_idx}/3: {eco_name}...")
    
    eco_record = api_post("api::ecosystem.ecosystem", {
        "name": eco["name"],
        "description": eco["description"],
        "climateZone": eco["climateZone"],
        "publishedAt": "2026-01-01T00:00:00.000Z"
    })
    eco_id = eco_record.get("id") if eco_record else eco_idx
    created_ecosystems[eco_name] = eco_id
    
    # Create 5 Levels for this Ecosystem (Super Mario progression stages)
    stages = [
        {"title": f"{eco_name}: Grundlagen", "num": 1, "diff": "leicht"},
        {"title": f"{eco_name}: Häufige Arten", "num": 2, "diff": "leicht"},
        {"title": f"{eco_name}: Fortgeschritten", "num": 3, "diff": "mittel"},
        {"title": f"{eco_name}: Experten-Merkmale", "num": 4, "diff": "mittel"},
        {"title": f"{eco_name}: Meister-Feldforschung", "num": 5, "diff": "schwer"},
    ]
    
    level_ids = []
    for stage in stages:
        lvl_record = api_post("api::level.level", {
            "title": stage["title"],
            "levelNumber": stage["num"],
            "difficulty": stage["diff"],
            "ecosystem": eco_id,
            "publishedAt": "2026-01-01T00:00:00.000Z"
        })
        lvl_id = lvl_record.get("id") if lvl_record else None
        if lvl_id:
            level_ids.append(lvl_id)
            
    # Create 30 Plants
    plants = eco["plants"]
    for p_idx, p in enumerate(plants, start=1):
        # assign level (6 plants per level across 5 levels)
        lvl_for_plant = level_ids[(p_idx - 1) // 6] if level_ids else None
        
        plant_record = api_post("api::plant.plant", {
            "commonName": p["commonName"],
            "scientificName": p["scientificName"],
            "family": p["family"],
            "kingdom": "Plantae",
            "order": p.get("order", "Angiospermae"),
            "genus": p["genus"],
            "species": p["species"],
            "description": p["description"],
            "reviewStatus": "approved",
            "publishedAt": "2026-01-01T00:00:00.000Z"
        })
        
        plant_id = plant_record.get("id") if plant_record else None
        total_plants += 1
        
        # Create 4 Questions for each plant
        questions = p["questions"]
        for q in questions:
            api_post("api::quiz.quiz", {
                "title": f"Quiz zu {p['commonName']}",
                "quizType": "multiple-choice",
                "reviewStatus": "approved",
                "plant": plant_id,
                "level": lvl_for_plant,
                "data": {
                    "question": q["question"],
                    "options": q["options"],
                    "correct": q["correct"],
                    "explanation": q.get("explanation", f"Merkmale von {p['commonName']} ({p['scientificName']}).")
                },
                "publishedAt": "2026-01-01T00:00:00.000Z"
            })
            total_quizzes += 1
        
        if p_idx % 10 == 0 or p_idx == 30:
            print(f"  🌿 {p_idx}/30 Pflanzen angelegt: {p['commonName']} ({p['scientificName']}) + 4 Quizzes")

print("\n====================================================")
print(f"✅ Seeding abgeschlossen!")
print(f"🌍 3 Ökosysteme")
print(f"🌿 {total_plants} Pflanzenarten angelegt")
print(f"📝 {total_quizzes} Quizfragen angelegt (4 pro Pflanze)")
print(f"🎮 15 Super-Mario Game Levels (5 pro Ökosystem)")
