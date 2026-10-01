import json
import requests
import pandas as pd
import logging
import os
from dotenv import load_dotenv
from connection import engine

load_dotenv("ingestion.env")

logging.basicConfig(
    filename='Ingestion.log', 
    level=logging.INFO, 
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s')

logger = logging.getLogger(__name__)

def get_products():
    try:
        url = os.getenv("PRODUCTS_URL")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        product_data = response.json()
        return product_data
    except requests.exceptions.RequestException as e:
        logger.error(f"Products API failed {e}")
        print(f"Products API failed {e}")
        return None
        
def get_users():
    try:
        url = os.getenv("USERS_URL")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        user_data = response.json()
        return user_data
    except requests.exceptions.RequestException as e:
        logger.error(f"Users API failed {e}")
        print(f"Users API failed {e}")
        return None

def get_carts():
    try:
        url = os.getenv("CARTS_URL")
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        cart_data = response.json()
        return cart_data
    except requests.exceptions.RequestException as e:
        logger.error(f"Carts API failed {e}")
        print(f"Carts API failed {e}")
        return None

def main():
    logger.info("Starting API ingestion")
    
    try:
        print("<<======= PRODUCT DATA =======>>")
        logger.info("Fetching products")
        product_data = get_products()
        if product_data is None:
            pass
        else:
            logger.info("Products fetched successfully")
            product_df = pd.DataFrame(product_data["products"])
            logger.info("Products transformed to DataFrame")

            for col in ['tags', 'dimensions', 'meta', 'images', 'reviews']:
                if col in product_df.columns:
                    product_df[col] = product_df[col].apply(json.dumps)
                    
            print(product_df.head())
    
            logger.info(f"Loading products into SQL Server")
            product_df.to_sql(
                'products',
                con=engine,
                if_exists='replace',
                index=False
            )
            logger.info(f"Products loaded successfully")
    except Exception as e:
        logger.error(f"Products API not fetched {e}")
        print(f"Products API not fetched: {e}")
        
    try:
        print("<<======= USERS DATA =======>>")
        logger.info("Fetching users")
        user_data = get_users()
        if user_data is None:
            pass
        else:
            logger.info("Users fetched successfully")
            user_df = pd.DataFrame(user_data["users"])
            logger.info("Users transformed to DataFrame")
            
            for col in ['address', 'bank', 'company', 'hair', 'crypto']:
                if col in user_df.columns:
                    user_df[col] = user_df[col].apply(json.dumps)
                    
            print(user_df.head())
            
            logger.info(f"Loading users into SQL Server")
            user_df.to_sql(
                'users',
                con=engine,
                if_exists='replace',
                index=False
            )
            logger.info(f"Users loaded successfully")
    except Exception as e:
        logger.error(f"Users API not fetched {e}")
        print(f"Users API not fetched: {e}")

    try:
        print("<<======= CARTS DATA =======>>")
        logger.info("Fetching carts")
        cart_data = get_carts()
        if cart_data is None:
            pass
        else:
            logger.info("Carts fetched successfully")
            cart_df = pd.DataFrame(cart_data["carts"])
            logger.info("Carts transformed to DataFrame")

            for col in ['products']:
                if col in cart_df.columns:
                    cart_df[col] = cart_df[col].apply(json.dumps)

            print(cart_df.head())
    
            logger.info(f"Loading carts into SQL Server")
            cart_df.to_sql(
                'carts',
                con=engine,
                if_exists='replace',
                index=False
            )
            logger.info(f"Carts loaded successfully")
    except Exception as e:
        logger.error(f"Carts API not fetched {e}")
        print(f"Carts API not fetched: {e}")

    logger.info("Ingestion completed")
    
if __name__ == '__main__':
    main()