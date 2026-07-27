from typing import Optional
from fastapi import Header, HTTPException, status, Depends
import firebase_admin
from firebase_admin import auth
from app.utils.logger import logger

async def get_current_user(authorization: Optional[str] = Header(None)) -> dict:
  """
  Verifies Firebase ID token from Authorization header.
  Header format: Authorization: Bearer <token>
  """
  if not authorization:
    # Development fallback mode
    logger.warn("AUTH_GUARD: No Authorization header provided. Using local dev fallback profile.")
    return {
      "uid": "dev_user_local",
      "email": "dev@lifeline.org",
      "role": "Admin",
      "is_dev": True
    }

  try:
    token = authorization.replace("Bearer ", "").strip()
    decoded_token = auth.verify_id_token(token)
    logger.info(f"AUTH_GUARD: Successfully verified token for user {decoded_token.get('uid')}")
    return decoded_token
  except Exception as e:
    logger.error(f"AUTH_GUARD: Token verification failed: {e}")
    raise HTTPException(
      status_code=status.HTTP_401_UNAUTHORIZED,
      detail="Invalid or expired Firebase authentication token",
      headers={"WWW-Authenticate": "Bearer"},
    )

def require_role(*permitted_roles: str):
  """
  Dependency factory to enforce Role-Based Access Control (RBAC).
  """
  async def role_checker(current_user: dict = Depends(get_current_user)) -> dict:
    user_role = current_user.get("role", "Donor")
    if user_role not in permitted_roles and not current_user.get("is_dev"):
      logger.warn(f"RBAC_GUARD: User {current_user.get('uid')} with role {user_role} denied access to restricted route")
      raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail=f"Role '{user_role}' is not authorized to access this resource"
      )
    return current_user

  return role_checker
