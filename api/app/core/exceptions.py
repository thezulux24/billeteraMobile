from typing import Any
import logging

from fastapi import FastAPI, HTTPException, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

logger = logging.getLogger("billetera.errors")


class AppException(Exception):
    def __init__(
        self,
        *,
        status_code: int,
        code: str,
        message: str,
        details: Any | None = None,
    ) -> None:
        self.status_code = status_code
        self.code = code
        self.message = message
        self.details = details
        super().__init__(message)


def _error_payload(code: str, message: str, details: Any | None = None) -> dict[str, Any]:
    return {"code": code, "message": message, "details": details}


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(AppException)
    async def app_exception_handler(_: Request, exc: AppException) -> JSONResponse:
        logger.warning(
            "app_exception status=%s code=%s message=%s details=%s",
            exc.status_code,
            exc.code,
            exc.message,
            jsonable_encoder(exc.details),
        )
        return JSONResponse(
            status_code=exc.status_code,
            content=_error_payload(exc.code, exc.message, exc.details),
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(
        _: Request, exc: RequestValidationError
    ) -> JSONResponse:
        try:
            details = exc.errors(include_context=False)
        except TypeError:
            details = exc.errors()

        return JSONResponse(
            status_code=422,
            content=_error_payload(
                "VALIDATION_ERROR",
                "Request validation failed.",
                jsonable_encoder(details),
            ),
        )

    @app.exception_handler(HTTPException)
    async def http_exception_handler(_: Request, exc: HTTPException) -> JSONResponse:
        message = (
            exc.detail if isinstance(exc.detail, str) else "Request could not be processed."
        )
        return JSONResponse(
            status_code=exc.status_code,
            content=_error_payload("HTTP_ERROR", message),
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(_: Request, exc: Exception) -> JSONResponse:
        return JSONResponse(
            status_code=500,
            content=_error_payload(
                "INTERNAL_SERVER_ERROR",
                "Unexpected error.",
                str(exc),
            ),
        )
