import os
import psycopg
import pandas as pd
from dotenv import load_dotenv
import random
import logging
import colorlog

class Logger:
    @staticmethod
    def get(nome=__name__):
        logger = logging.getLogger(nome)
        logger.setLevel(logging.DEBUG)

        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = colorlog.ColoredFormatter(
                '%(white)s%(asctime)s | %(log_color)s%(levelname)-8s%(reset)s %(blue)s%(message)s',
                datefmt='%Y-%m-%d %H:%M:%S',
                log_colors={
                    'DEBUG': 'cyan',
                    'INFO': 'green',
                    'WARNING': 'yellow',
                    'ERROR': 'red',
                    'CRITICAL': 'red,bg_white',
                }
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)

        return logger

log = Logger.get()

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
            log.error(f"Erro ao conectar ao banco de dados: {e}")

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
            #print(f"A tabela '{tabela}' foi truncada com sucesso.")
            log.info(f"A tabela '{tabela}' foi truncada com sucesso.")
        except Exception as e:
            log.error(f"Erro ao truncar tabela: {e}")
            self.db.conn.rollback()

class Profissao:
    def __init__(self, id_profissao, nome):
        self.id_profissao = id_profissao
        self.nome = nome

class ProfissaoRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def inserir_profissoes(self, profissoes):
        try:
            query = "INSERT INTO profissao (id_profissao, nome) VALUES (%s, %s)"
            self.db.cursor.executemany(query, [(p.id_profissao, p.nome) for p in profissoes])
            self.db.conn.commit()
            log.info("Dados salvos com sucesso na tabela 'profissao'.")
        except Exception as e:
            log.error(f"Erro ao salvar dados no banco: {e}")
            self.db.conn.rollback()

class UsuarioProfissao:
    def __init__(self, id_profissao, id_usuario):
        self.id_profissao = id_profissao
        self.id_usuario = id_usuario

class UsuarioProfissaoRepository:
    """Gerencia as operações no banco de dados para a tabela 'usuario_profissao'."""
    def __init__(self, db_connection):
        self.db = db_connection

    def obter_usuarios(self):
        """Obtém a lista de usuários do banco de dados."""
        try:
            self.db.cursor.execute("SELECT id_usuario FROM usuario")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar usuários: {e}")
            return []

    def obter_profissoes(self):
        try:
            self.db.cursor.execute("SELECT id_profissao FROM profissao")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar profissões: {e}")
            return []

    def inserir_usuario_profissoes(self, usuario_profissoes):
        try:
            query = "INSERT INTO usuario_profissao (id_profissao, id_usuario) VALUES (%s, %s)"
            self.db.cursor.executemany(query, usuario_profissoes)
            self.db.conn.commit()
            log.info("Dados salvos com sucesso na tabela 'usuario_profissao'.")
        except Exception as e:
            log.error(f"Erro ao salvar dados no banco: {e}")
            self.db.conn.rollback()

class Habilidade:
    def __init__(self, id_habilidade,nome):
        self.id_habilidade = id_habilidade
        self.nome = nome

class HabilidadeRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def inserir_habilidades(self, habilidades):
        try:
            query = "INSERT INTO habilidade (id_habilidade, nome) VALUES (%s, %s)"
            self.db.cursor.executemany(query, [(h.id_habilidade, h.nome) for h in habilidades])
            self.db.conn.commit()
            log.info("Dados salvos com sucesso na tabela 'habilidade'.")
        except Exception as e:
            log.error(f"Erro ao salvar dados no banco: {e}")
            self.db.conn.rollback()

class UsuarioHabilidade:

    def __init__(self, id_habilidade, id_usuario):
        self.id_habilidade = id_habilidade
        self.id_usuario = id_usuario

class UsuarioHabilidadeRepository:

    def __init__(self, db_connection):
        self.db = db_connection

    def obter_usuarios(self):
        try:
            self.db.cursor.execute("SELECT id_usuario FROM usuario")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar usuários: {e}")
            return []

    def obter_habilidades(self):
        try:
            self.db.cursor.execute("SELECT id_habilidade FROM habilidade")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar habilidades: {e}")
            return []

    def inserir_usuario_habilidades(self, usuario_habilidades):
        try:
            query = "INSERT INTO usuario_habilidade (id_habilidade, id_usuario) VALUES (%s, %s)"
            self.db.cursor.executemany(query, usuario_habilidades)
            self.db.conn.commit()
            log.info("Dados salvos com sucesso na tabela 'usuario_habilidade'.")
        except Exception as e:
            log.error(f"Erro ao salvar dados no banco: {e}")
            self.db.conn.rollback()

class Comentario:
    def __init__(self, id_projeto, id_usuario, texto):
        self.id_projeto = id_projeto
        self.id_usuario = id_usuario
        self.texto = texto

class ComentarioRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def inserir_comentario(self, usuario_habilidades):
        try:
            query = "INSERT INTO comentario (texto, id_projeto, id_usuario) VALUES (%s, %s, %s)"
            self.db.cursor.executemany(query, usuario_habilidades)
            self.db.conn.commit()
            log.info("Dados salvos com sucesso na tabela 'comentario'.")
        except Exception as e:
            log.error(f"Erro ao salvar dados no banco: {e}")
            self.db.conn.rollback()
class Projeto:
    def __init__(self, id_projeto, nome):
        self.id_projeto = id_projeto
        self.nome = nome

class ProjetoRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def obter_projetos(self):
        try:
            self.db.cursor.execute("SELECT id_projeto FROM projeto")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar projetos: {e}")
            return []

class ObraFavorita:
    def __init__(self, id_usuario, id_projeto):
        self.id_usuario = id_usuario
        self.id_projeto = id_projeto

class ObraFavoritaRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def obter_usuarios(self):
        try:
            self.db.cursor.execute("SELECT id_usuario FROM usuario")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar usuários: {e}")
            return []

    def obter_projetos(self):
        try:
            self.db.cursor.execute("SELECT id_projeto FROM projeto")
            return [row[0] for row in self.db.cursor.fetchall()]
        except Exception as e:
            log.error(f"Erro ao buscar projetos: {e}")
            return []

    def inserir_obras_favoritas(self, obras_favoritas):
        try:
            query = "INSERT INTO obra_favorita (id_usuario, id_projeto) VALUES (%s, %s)"
            self.db.cursor.executemany(query, [(o.id_usuario, o.id_projeto) for o in obras_favoritas])
            self.db.conn.commit()
            log.info("Obras favoritas inseridas com sucesso na tabela 'obra_favorita'.")
        except Exception as e:
            log.error(f"Erro ao salvar obras favoritas: {e}")
            self.db.conn.rollback()

def main():
    """Função principal para executar o script."""
    # Lista de profissões
    profissoes = [
        "Ator", "Diretor de Cinema", "Roteirista", "Cenógrafo", "Figurinista",
        "Maquiador", "Cameraman", "Editor de Vídeo", "Produtor de Cinema", "Animador",
        "Dublador", "Sonoplasta", "Iluminador", "Crítico de Cinema", "Diretor de Fotografia",
        "Designer Gráfico", "Escultor", "Pintor", "Curador de Arte", "Restaurador de Obras"
    ]

    #Lista de habilidades
    habilidades = [
        "Roteirização", "Direção de fotografia", "Edição de vídeo", "Produção cinematográfica",
        "Animação digital", "Design gráfico", "Modelagem 3D", "Sonorização e mixagem",
        "Iluminação cênica", "Figurino e maquiagem artística", "Efeitos especiais",
        "Escrita criativa", "Storytelling", "Composição visual", "Criação de personagens",
        "Direção de arte", "Improvisação", "Ilustração", "Curadoria artística",
        "Pintura e escultura",
        "Gerenciamento de projetos audiovisuais", "Captação de recursos para produção",
        "Distribuição e marketing de filmes", "Produção executiva", "Coordenação de equipe técnica"
    ]

    #Lista de comentarios
    temas = ["O filme", "A trilha sonora", "A direção de arte", "A atuação", "A fotografia", "O roteiro"]
    adjetivos = ["é incrível", "é mediana", "decepcionou um pouco", "é uma obra-prima", "é confusa", "é emocionante"]
    complementos = [
        "Definitivamente uma das melhores obras do ano!",
        "Achei que faltou algo para ser memorável.",
        "Vale muito a pena conferir.",
        "Com certeza vai dividir opiniões.",
        "Impossível não se emocionar com essa obra.",
        "Um marco na história do cinema/música/arte."
    ]

    # Enumera cada profissão
    lista_profissoes = [Profissao(i, nome) for i, nome in enumerate(profissoes, start=1)]

    # Enumera cada habilidade
    lista_habilidades = [Habilidade(i, nome) for i, nome in enumerate(habilidades, start=1)]

    # Conectar ao banco
    db = DatabaseConnection()
    db.connect()

    # Operacoes no banco
    op = DatabaseOperation(db)

    # Inserir dados
    repo = ProfissaoRepository(db)
    repo_habilidade = HabilidadeRepository(db)
    repo_projeto = ProjetoRepository(db)
    repo_obra_favorita = ObraFavoritaRepository(db)
    op.truncate_table("profissao", "CASCADE")
    op.truncate_table("habilidade", "CASCADE")
    op.truncate_table("comentario")
    op.truncate_table("obra_favorita")
    repo.inserir_profissoes(lista_profissoes)
    repo_habilidade.inserir_habilidades(lista_habilidades)

    repo_usuario_profissao = UsuarioProfissaoRepository(db)
    repo_usuario_habilidade = UsuarioHabilidadeRepository(db)
    repo_comentario = ComentarioRepository(db)
    usuarios = repo_usuario_profissao.obter_usuarios()
    profissoes = repo_usuario_profissao.obter_profissoes()
    habilidades = repo_usuario_habilidade.obter_habilidades()
    projetos = repo_projeto.obter_projetos()

    if not usuarios or not profissoes:
        log.warning("Nenhum usuário ou profissão encontrado no banco de dados.")
        db.close()
        return
    if not usuarios or not habilidades:
        log.warning("Nenhum usuário ou habilidade encontrado no banco de dados.")
        db.close()
        return

    # Associar usuários a pelo menos 2 profissões
    usuario_profissoes = []
    for usuario in usuarios:
        escolhidas = random.sample(profissoes, k=min(2, len(profissoes)))  # Pelo menos 2 profissões
        usuario_profissoes.extend([(prof, usuario) for prof in escolhidas])

    # Associar usuários a pelo menos 3 habilidades
    usuario_habilidades = []
    for usuario in usuarios:
        escolhidas = random.sample(habilidades, k=min(3, len(habilidades)))  # Pelo menos 3 habilidades
        usuario_habilidades.extend([(hab, usuario) for hab in escolhidas])

    # Associar um projeto a um funcionário e adicionar um comentário
    comentarios = []
    for usuario in usuarios:
        for projeto in projetos:
            tema = random.choice(temas)
            adjetivo = random.choice(adjetivos)
            complemento = random.choice(complementos)
            texto = f"{tema} {adjetivo}. {complemento}"
            comentarios.append((texto, projeto, usuario))

    # Associar usuários a 2 obras favoritas
    obras_favoritas = []
    for usuario in usuarios:
        favoritos = random.sample(projetos, 2)
        for projeto in favoritos:
            obras_favoritas.append(ObraFavorita(usuario, projeto))

    # Inserir as associações na tabela usuario_profissao
    repo_usuario_profissao.inserir_usuario_profissoes(usuario_profissoes)

    # Inserir as associações na tabela usuario_profissao
    repo_usuario_habilidade.inserir_usuario_habilidades(usuario_habilidades)

    # Inserir os comentários no banco de dados
    repo_comentario.inserir_comentario(comentarios)

    # Inserir as associações na tabela obra_favorita
    repo_obra_favorita.inserir_obras_favoritas(obras_favoritas)

    # Fechar conexão
    db.close()

if __name__ == "__main__":
    main()
