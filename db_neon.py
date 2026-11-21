"""Optional PostgreSQL connection adapter for Neon staging.

This preserves the tuple/dict cursor interface used by the legacy Flask
application. Do not use against a schema other than database/neon_schema.sql.
MySQL remains the default backend for existing installations.
"""
import re
import psycopg
from psycopg.rows import dict_row


class NeonCursor:
    def __init__(self, inner):
        self._cursor = inner
        self.lastrowid = None

    def execute(self, sql, params=None):
        statement = str(sql).strip()
        # No MySQL-specific functions are required by the new PostgreSQL schema.
        statement = re.sub(r"\bCURDATE\(\)", "CURRENT_DATE", statement, flags=re.I)
        statement = re.sub(
            r'\bstatus\s*=\s*"([a-z_]+)"',
            lambda m: "status = '" + m.group(1) + "'",
            statement,
            flags=re.I,
        )
        statement = re.sub(r"\bIFNULL\s*\(", "COALESCE(", statement, flags=re.I)
        statement = re.sub(r"\\x60([a-zA-Z_][a-zA-Z_0-9]*)\\x60", r'"\1"', statement)
        if params is not None and re.search(r"\bSET\s+is_active\s*=\s*%s", statement, re.I):
            params = list(params)
            if params and isinstance(params[0], (int, str)):
                params[0] = str(params[0]).strip().lower() in ("1", "true", "yes")
            params = tuple(params)

        # PyMySQL exposes cursor.lastrowid. PostgreSQL needs RETURNING id.
        is_insert = bool(re.match(r"^INSERT\s+INTO\s+\w+\s*", statement, re.I))
        if is_insert and not re.search(r"\bRETURNING\b", statement, re.I):
            statement = statement.rstrip(";") + " RETURNING id"
            self._cursor.execute(statement, params)
            row = self._cursor.fetchone()
            self.lastrowid = row[0] if row else None
        else:
            self._cursor.execute(statement, params)
            self.lastrowid = None
        return self

    def executemany(self, sql, params_seq):
        return self._cursor.executemany(sql, params_seq)

    def fetchone(self):
        return self._cursor.fetchone()

    def fetchall(self):
        return self._cursor.fetchall()

    def fetchmany(self, size=None):
        return self._cursor.fetchmany(size) if size is not None else self._cursor.fetchmany()

    def close(self):
        return self._cursor.close()

    def __iter__(self):
        return iter(self._cursor)

    def __getattr__(self, name):
        return getattr(self._cursor, name)


class NeonConnection:
    def __init__(self, inner):
        self._connection = inner

    def cursor(self, cursorclass=None):
        use_dict = cursorclass is not None and "dict" in cursorclass.__name__.lower()
        raw = (self._connection.cursor(row_factory=dict_row)
               if use_dict else self._connection.cursor())
        return NeonCursor(raw)

    def commit(self):
        self._connection.commit()

    def rollback(self):
        self._connection.rollback()

    def close(self):
        self._connection.close()

    def __getattr__(self, name):
        return getattr(self._connection, name)


def connect_neon(url):
    if not url or not url.startswith(("postgresql://", "postgres://")):
        raise ValueError("Neon requires a PostgreSQL DATABASE_URL")
    # Neon requires TLS. URL can include sslmode=require already.
    connection = psycopg.connect(url, connect_timeout=20, autocommit=False)
    return NeonConnection(connection)
