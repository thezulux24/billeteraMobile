#!/usr/bin/env python3
from __future__ import annotations

import os
from pathlib import Path
from urllib.parse import urlparse

import psycopg
from dotenv import load_dotenv


ROOT_DIR = Path(__file__).resolve().parents[1]
MIGRATIONS_DIR = ROOT_DIR / "supabase" / "migrations"


def load_local_migrations() -> list[str]:
    if not MIGRATIONS_DIR.exists():
        return []
    return [file_path.name for file_path in sorted(MIGRATIONS_DIR.glob("*.sql"))]


def _project_ref_from_url(supabase_url: str) -> str:
    try:
        hostname = (urlparse(supabase_url).hostname or "").strip()
    except Exception:
        return ""
    return hostname.split(".")[0] if hostname else ""


def validate_db_url(db_url: str) -> list[str]:
    hints: list[str] = []
    try:
        parsed = urlparse(db_url)
    except ValueError:
        hints.append(
            "SUPABASE_DB_URL no se puede parsear. "
            "Si el password tiene caracteres especiales, codificalo (URL encode). "
            "No uses corchetes [] alrededor del password."
        )
        return hints

    username = (parsed.username or "").strip()
    password = parsed.password or ""
    host = (parsed.hostname or "").strip()
    port = parsed.port

    if (
        "YOUR-PASSWORD" in db_url
        or "YOUR_DB_PASSWORD" in db_url
        or password in {"[YOUR-PASSWORD]", "YOUR-PASSWORD", "YOUR_DB_PASSWORD"}
    ):
        hints.append(
            "SUPABASE_DB_URL usa un placeholder de password. Reemplazalo con la Database Password real."
        )

    project_ref = _project_ref_from_url(os.getenv("SUPABASE_URL", "").strip())
    if host.endswith("pooler.supabase.com") and username and "." not in username:
        if project_ref:
            hints.append(
                "Para pooler usa usuario `postgres.<project-ref>` "
                f"(ejemplo: postgres.{project_ref})."
            )
        else:
            hints.append("Para pooler usa usuario `postgres.<project-ref>`.")

    if host.startswith("db.") and host.endswith(".supabase.co") and port == 5432:
        hints.append(
            "La conexion directa `db.<ref>.supabase.co:5432` puede requerir IPv6. "
            "Si falla, usa pooler IPv4 (puerto 6543)."
        )

    return hints


def main() -> int:
    load_dotenv(ROOT_DIR / ".env")
    db_url = os.getenv("SUPABASE_DB_URL", "").strip()
    if not db_url:
        print("ERROR: SUPABASE_DB_URL is required in api/.env")
        return 1

    hints = validate_db_url(db_url)
    if hints:
        print("SUPABASE_DB_URL validation hints:")
        for hint in hints:
            print(f"- {hint}")

    local = load_local_migrations()
    try:
        with psycopg.connect(db_url) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    select exists (
                      select 1
                      from information_schema.tables
                      where table_schema = 'public'
                        and table_name = 'schema_migrations'
                    )
                    """
                )
                has_registry = bool(cur.fetchone()[0])

                if not has_registry:
                    print("schema_migrations table does not exist yet.")
                    print(f"Local migration files: {len(local)}")
                    for name in local:
                        print(f"- PENDING {name}")
                    return 0

                cur.execute(
                    "select name, applied_at from public.schema_migrations order by applied_at asc"
                )
                rows = cur.fetchall()
                applied = {str(row[0]) for row in rows}
    except psycopg.OperationalError as error:
        message = str(error)
        print(f"ERROR: {message.splitlines()[0]}")
        if "Tenant or user not found" in message:
            print("Hint: revisa host de pooler y usuario `postgres.<project-ref>`.")
        if "getaddrinfo failed" in message:
            print("Hint: usa URI de pooler IPv4 (puerto 6543).")
        return 1

    pending = [name for name in local if name not in applied]
    print(f"Applied: {len(applied)}")
    print(f"Pending: {len(pending)}")

    if rows:
        print("\nApplied migrations:")
        for name, applied_at in rows:
            print(f"- {name} @ {applied_at}")

    if pending:
        print("\nPending migrations:")
        for name in pending:
            print(f"- {name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
