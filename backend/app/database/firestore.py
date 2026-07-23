import os
import firebase_admin
from firebase_admin import credentials, firestore
from app.config.settings import settings
from app.utils.logger import logger

class FirestoreDB:
    _instance = None
    _db = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(FirestoreDB, cls).__new__(cls)
            cls._initialize_firebase()
        return cls._instance

    @classmethod
    def _initialize_firebase(cls):
        try:
            if not firebase_admin._apps:
                cred_path = settings.FIREBASE_CREDENTIALS_PATH
                if os.path.exists(cred_path):
                    cred = credentials.Certificate(cred_path)
                    firebase_admin.initialize_app(cred, {
                        'projectId': settings.FIREBASE_PROJECT_ID,
                    })
                    logger.info("Firebase Admin initialized with service account.")
                else:
                    # Fallback for local emulator or default GCP credentials
                    firebase_admin.initialize_app(options={
                        'projectId': settings.FIREBASE_PROJECT_ID,
                    })
                    logger.info("Firebase Admin initialized with default project config.")
            
            cls._db = firestore.client()
        except Exception as e:
            logger.warning(f"Firestore initialization warning: {e}. Operating in standalone mock/fallback mode.")
            cls._db = None

    @property
    def client(self):
        return self._db

db_client = FirestoreDB()
