#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlparse

import psycopg
from dotenv import load_dotenv


ROOT_DIR = Path(__file__).resolve().parents[1]
MIGRATIONS_DIR = ROOT_DIR / "supabase" / "migrations"


@dataclass(frozen=True)
class MigrationFile:
    name: str
    path: Path
    checksum: str
    sql: str


def load_migration_files() -> list[MigrationFile]:
    if not MIGRATIONS_DIR.exists():
        raise FileNotFoundError(f"Migration directory not found: {MIGRATIONS_DIR}")

    files = sorted(MIGRATIONS_DIR.glob("*.sql"))
    migrations: list[MigrationFile] = []
    for file_path in files:
        sql = file_path.read_text(encoding="utf-8")
        checksum = hashlib.sha256(sql.encode("utf-8")).hexdigest()
        migrations.append(
            MigrationFile(
                name=file_path.name,
                path=file_path,
                checksum=checksum,
                sql=sql,
            )
        )
    return migrations


def ensure_migrations_table(conn: psycopg.Connection) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            create table if not exists public.schema_migrations (
              name text primary key,
              checksum text not null,
              applied_at timestamptz not null default timezone('utc', now())
            )
            """
        )
    conn.commit()


def get_applied_checksum(conn: psycopg.Connection, name: str) -> str | None:
    with conn.cursor() as cur:
        cur.execute(
            "select checksum from public.schema_migrations where name = %s",
            (name,),
        )
        row = cur.fetchone()
    return None if row is None else str(row[0])


def apply_migration(conn: psycopg.Connection, migration: MigrationFile) -> None:
    with conn.cursor() as cur:
        cur.execute(migration.sql)
        cur.execute(
            "insert into public.schema_migrations (name, checksum) values (%s, %s)",
            (migration.name, migration.checksum),
        )
    conn.commit()


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

    if not parsed.scheme.startswith("postgres"):
        hints.append("SUPABASE_DB_URL debe usar esquema postgresql://.")

    if not username:
        hints.append("SUPABASE_DB_URL debe incluir usuario en la URL.")

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
            "Si falla, usa el pooler IPv4 (puerto 6543)."
        )

    return hints


def print_connection_help(error: Exception) -> None:
    message = str(error)
    print("ERROR: No se pudo conectar a SUPABASE_DB_URL.")
    print(f"Detalle: {message.splitlines()[0]}")
    if "Tenant or user not found" in message:
        print("Hint: revisa host de pooler y usuario `postgres.<project-ref>`.")
    if "getaddrinfo failed" in message:
        print(
            "Hint: el host puede resolver solo IPv6. Usa URI de pooler IPv4 en puerto 6543."
        )
    print("Valida en Supabase Dashboard -> Settings -> Database -> Connection string (URI).")


def main() -> int:
    load_dotenv(ROOT_DIR / ".env")
    db_url = os.getenv("SUPABASE_DB_URL", "").strip()
    if not db_url:
        print("ERROR: SUPABASE_DB_URL is required in api/.env")
        print("Example: postgresql://postgres.<ref>:<password>@<host>:6543/postgres")
        return 1

    hints = validate_db_url(db_url)
    if hints:
        print("SUPABASE_DB_URL validation hints:")
        for hint in hints:
            print(f"- {hint}")

    migrations = load_migration_files()
    if not migrations:
        print("No migration files found.")
        return 0

    print(f"Applying migrations from: {MIGRATIONS_DIR}")
    try:
        with psycopg.connect(db_url) as conn:
            ensure_migrations_table(conn)

            applied = 0
            skipped = 0

            for migration in migrations:
                existing_checksum = get_applied_checksum(conn, migration.name)

                if existing_checksum is not None:
                    if existing_checksum != migration.checksum:
                        print(
                            "ERROR: Checksum mismatch for already applied migration "
                            f"{migration.name}. Applied checksum differs from local file."
                        )
                        return 2
                    print(f"SKIP  {migration.name}")
                    skipped += 1
                    continue

                print(f"APPLY {migration.name}")
                apply_migration(conn, migration)
                applied += 1
    except psycopg.OperationalError as error:
        print_connection_help(error)
        return 1

    print(f"Done. applied={applied}, skipped={skipped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
