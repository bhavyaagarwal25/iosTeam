import os
import json
import urllib.request
from duckduckgo_search import DDGS

products = [
    "bread", "epigamia natural greek yogurt", "icecream", "fruits basket", "mixed green vegetables", 
    "tomato ketchup sauce", "dahi curd", "mixed fruit jam", "tomato", "red onion", 
    "potato", "banana", "eggs", "maggi noodles", "lays potato chips", "aloo bhujia",
    "doritos chips", "cadbury dairy milk silk", "coca cola original", "real fruit power alphonso mango juice",
    "red bull energy drink", "bisleri water", "vim dishwash gel", "dettol antiseptic",
    "fortune sunlite refined sunflower oil", "tata salt"
]

assets_dir = "/Users/bhavyaagarwal/iosTeam/trial/trial/Assets.xcassets"
ddgs = DDGS()

def fetch_image_url(query):
    try:
        results = ddgs.images(
            query,
            region="in-en",
            safesearch="on",
            size="Small",
            max_results=1
        )
        if results:
            return results[0]["image"]
    except Exception as e:
        print(f"Search failed for {query}: {e}")
    return None

def create_imageset(name):
    clean_name = name.split()[0].replace("'", "").replace("-", "").lower()
    if clean_name == "epigamia": clean_name = "epigamia"
    if clean_name == "mixed" and "vegetables" in name: clean_name = "vegetables"
    if clean_name == "mixed" and "jam" in name: clean_name = "jam"
    if clean_name == "fruits": clean_name = "fruits"
    if clean_name == "tomato" and "sauce" in name: clean_name = "sauce"
    if clean_name == "dahi": clean_name = "dahi"
    
    imageset_dir = os.path.join(assets_dir, f"{clean_name}_product.imageset")
    
    if os.path.exists(imageset_dir):
        print(f"Skipping {clean_name}, already exists")
        return

    img_url = fetch_image_url(name + " grocery india isolated white background")
    if not img_url:
        print(f"No image found for {name}")
        return
        
    os.makedirs(imageset_dir, exist_ok=True)
    img_path = os.path.join(imageset_dir, f"{clean_name}_product.png")
    
    try:
        req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(img_path, 'wb') as out_file:
            out_file.write(response.read())
    except Exception as e:
        print(f"Failed to download {name} from {img_url}: {e}")
        return
        
    contents = {
        "images": [
            {
                "filename": f"{clean_name}_product.png",
                "idiom": "universal",
                "scale": "1x"
            },
            {
                "idiom": "universal",
                "scale": "2x"
            },
            {
                "idiom": "universal",
                "scale": "3x"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print(f"Created imageset for {clean_name}")

for product in products:
    create_imageset(product)

print("Done generating images.")
