import os
import psycopg
import pandas as pd
from dotenv import load_dotenv
import random

load_dotenv()

class DatabaseConnection:
    def __init__(self):
        self.conn = None
        self.cursor = None

    def connect(self):
        try:
            self.conn = psycopg.connect(
                dbname=os.getenv("db_name"),
                user=os.getenv("db_user"),
                password=os.getenv("db_password"),
                host=os.getenv("db_host"),
                port=os.getenv("db_port")
            )
            self.cursor = self.conn.cursor()
        except Exception as e:
            print(f"Erro ao conectar ao banco de dados: {e}")

    def close(self):
        """Fecha a conexão com o banco."""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()

class DatabaseOperation:
    def __init__(self, db_connection):
        self.db = db_connection

    def truncate_table(self, tabela, opcao = None):
        try:
            if opcao is None:
                self.db.cursor.execute(f"TRUNCATE TABLE {tabela};")
            else:
                self.db.cursor.execute(f"TRUNCATE TABLE {tabela} {opcao};")
            print(f"A tabela '{tabela}' foi truncada com sucesso.")
        except Exception as e:
            print(f"Erro ao truncar tabela: {e}")
            self.db.conn.rollback()



def main():

    # Conectar ao banco
    db = DatabaseConnection()
    db.connect()

    # Operacoes no banco
    op = DatabaseOperation(db)


if __name__ == "__main__":
    main()
