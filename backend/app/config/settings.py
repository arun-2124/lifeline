import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "Lifeline AI Engine API"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = True

    FIREBASE_PROJECT_ID: str = "lifeline-42717"
    FIREBASE_CREDENTIALS_PATH: str = "config/firebase-service-account.json"
    GOOGLE_MAPS_API_KEY: str = ""

    DEFAULT_CLUSTER_K: int = 3
    ROUTING_SEARCH_TIMEOUT_SECONDS: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
