PGDMP                      }            indie_stream    16.4    16.4 g    B           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            C           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            D           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            E           1262    18067    indie_stream    DATABASE     �   CREATE DATABASE indie_stream WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Portuguese_Brazil.1252';
    DROP DATABASE indie_stream;
                postgres    false            �            1259    18068    cidade    TABLE     �   CREATE TABLE public.cidade (
    id_cidade bigint NOT NULL,
    nome character varying(255),
    id_estado bigint NOT NULL,
    id bigint NOT NULL
);
    DROP TABLE public.cidade;
       public         heap    postgres    false            �            1259    18071    cidade_id_cidade_seq    SEQUENCE     �   ALTER TABLE public.cidade ALTER COLUMN id_cidade ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.cidade_id_cidade_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    215            �            1259    18072    cidade_id_seq    SEQUENCE     �   ALTER TABLE public.cidade ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.cidade_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    215            �            1259    18073 
   comentario    TABLE     �   CREATE TABLE public.comentario (
    id_comentario bigint NOT NULL,
    texto character varying(255),
    id_projeto bigint NOT NULL,
    id_usuario bigint NOT NULL
);
    DROP TABLE public.comentario;
       public         heap    postgres    false            �            1259    18076    comentario_id_comentario_seq    SEQUENCE     �   ALTER TABLE public.comentario ALTER COLUMN id_comentario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.comentario_id_comentario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    218            �            1259    18077    estado    TABLE     �   CREATE TABLE public.estado (
    id_estado bigint NOT NULL,
    nome character varying(255),
    id bigint NOT NULL,
    id_pais integer
);
    DROP TABLE public.estado;
       public         heap    postgres    false            �            1259    18080    estado_id_estado_seq    SEQUENCE     �   ALTER TABLE public.estado ALTER COLUMN id_estado ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.estado_id_estado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    220            �            1259    18081    estado_id_seq    SEQUENCE     �   ALTER TABLE public.estado ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.estado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    220            �            1259    18082 
   habilidade    TABLE     g   CREATE TABLE public.habilidade (
    id_habilidade bigint NOT NULL,
    nome character varying(255)
);
    DROP TABLE public.habilidade;
       public         heap    postgres    false            �            1259    18085    habilidade_id_habilidade_seq    SEQUENCE     �   ALTER TABLE public.habilidade ALTER COLUMN id_habilidade ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habilidade_id_habilidade_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    223            �            1259    18086    linha_do_tempo    TABLE     �   CREATE TABLE public.linha_do_tempo (
    id_linha_tempo bigint NOT NULL,
    descricao text,
    imagem_url character varying(255),
    id_projeto bigint NOT NULL
);
 "   DROP TABLE public.linha_do_tempo;
       public         heap    postgres    false            �            1259    18091 !   linha_do_tempo_id_linha_tempo_seq    SEQUENCE     �   ALTER TABLE public.linha_do_tempo ALTER COLUMN id_linha_tempo ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.linha_do_tempo_id_linha_tempo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    225            �            1259    18721    pais    TABLE     I   CREATE TABLE public.pais (
    id_pais bigint NOT NULL,
    nome text
);
    DROP TABLE public.pais;
       public         heap    postgres    false            �            1259    18720    pais_id_pais_seq    SEQUENCE     �   ALTER TABLE public.pais ALTER COLUMN id_pais ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.pais_id_pais_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    240            �            1259    18095 	   profissao    TABLE     e   CREATE TABLE public.profissao (
    id_profissao bigint NOT NULL,
    nome character varying(255)
);
    DROP TABLE public.profissao;
       public         heap    postgres    false            �            1259    18098    profissao_id_profissao_seq    SEQUENCE     �   ALTER TABLE public.profissao ALTER COLUMN id_profissao ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.profissao_id_profissao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    227            �            1259    18099    projeto    TABLE     ~  CREATE TABLE public.projeto (
    id_projeto bigint NOT NULL,
    descricao character varying(255),
    imagem_url character varying(255),
    localizacao character varying(255),
    status character varying(255),
    tipo character varying(255),
    titulo character varying(255),
    id_usuario_criador bigint,
    id_pais integer,
    id_cidade integer,
    id_estado integer
);
    DROP TABLE public.projeto;
       public         heap    postgres    false            �            1259    18104    projeto_id_projeto_seq    SEQUENCE     �   ALTER TABLE public.projeto ALTER COLUMN id_projeto ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.projeto_id_projeto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    229            �            1259    18105    projeto_id_seq    SEQUENCE     w   CREATE SEQUENCE public.projeto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.projeto_id_seq;
       public          postgres    false            �            1259    18321    rede_social    TABLE     a   CREATE TABLE public.rede_social (
    id_rede_social integer NOT NULL,
    nome text NOT NULL
);
    DROP TABLE public.rede_social;
       public         heap    postgres    false            �            1259    18320    rede_social_id_rede_social_seq    SEQUENCE     �   CREATE SEQUENCE public.rede_social_id_rede_social_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.rede_social_id_rede_social_seq;
       public          postgres    false    238            F           0    0    rede_social_id_rede_social_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.rede_social_id_rede_social_seq OWNED BY public.rede_social.id_rede_social;
          public          postgres    false    237            �            1259    18112    usuario    TABLE     �  CREATE TABLE public.usuario (
    id_usuario bigint NOT NULL,
    data_nascimento timestamp(6) without time zone,
    email character varying(255),
    imagem_url character varying(255),
    nome character varying(255),
    premium boolean,
    senha character varying(255),
    sobre_min text,
    username character varying(255),
    id_cidade bigint,
    id_estado bigint,
    localizacao character varying(255),
    id_pais integer
);
    DROP TABLE public.usuario;
       public         heap    postgres    false            �            1259    18117    usuario_habilidade    TABLE     n   CREATE TABLE public.usuario_habilidade (
    id_usuario bigint NOT NULL,
    id_habilidade bigint NOT NULL
);
 &   DROP TABLE public.usuario_habilidade;
       public         heap    postgres    false            �            1259    18120    usuario_id_usuario_seq    SEQUENCE     �   ALTER TABLE public.usuario ALTER COLUMN id_usuario ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.usuario_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    232            �            1259    18236    usuario_profissao    TABLE     l   CREATE TABLE public.usuario_profissao (
    id_usuario bigint NOT NULL,
    id_profissao bigint NOT NULL
);
 %   DROP TABLE public.usuario_profissao;
       public         heap    postgres    false            �            1259    19255    usuario_projeto    TABLE     �   CREATE TABLE public.usuario_projeto (
    id_usuario integer NOT NULL,
    id_projeto integer NOT NULL,
    obra_favorita boolean DEFAULT false,
    usuario_solicitante boolean DEFAULT false
);
 #   DROP TABLE public.usuario_projeto;
       public         heap    postgres    false            �            1259    18121    usuario_rede_social    TABLE     �   CREATE TABLE public.usuario_rede_social (
    id_usuario bigint NOT NULL,
    id_rede_social integer NOT NULL,
    link_perfil text
);
 '   DROP TABLE public.usuario_rede_social;
       public         heap    postgres    false            Z           2604    18324    rede_social id_rede_social    DEFAULT     �   ALTER TABLE ONLY public.rede_social ALTER COLUMN id_rede_social SET DEFAULT nextval('public.rede_social_id_rede_social_seq'::regclass);
 I   ALTER TABLE public.rede_social ALTER COLUMN id_rede_social DROP DEFAULT;
       public          postgres    false    237    238    238            %          0    18068    cidade 
   TABLE DATA           @   COPY public.cidade (id_cidade, nome, id_estado, id) FROM stdin;
    public          postgres    false    215   U       (          0    18073 
   comentario 
   TABLE DATA           R   COPY public.comentario (id_comentario, texto, id_projeto, id_usuario) FROM stdin;
    public          postgres    false    218          *          0    18077    estado 
   TABLE DATA           >   COPY public.estado (id_estado, nome, id, id_pais) FROM stdin;
    public          postgres    false    220   т       -          0    18082 
   habilidade 
   TABLE DATA           9   COPY public.habilidade (id_habilidade, nome) FROM stdin;
    public          postgres    false    223   $�       /          0    18086    linha_do_tempo 
   TABLE DATA           [   COPY public.linha_do_tempo (id_linha_tempo, descricao, imagem_url, id_projeto) FROM stdin;
    public          postgres    false    225   ��       >          0    18721    pais 
   TABLE DATA           -   COPY public.pais (id_pais, nome) FROM stdin;
    public          postgres    false    240   ^�       1          0    18095 	   profissao 
   TABLE DATA           7   COPY public.profissao (id_profissao, nome) FROM stdin;
    public          postgres    false    227   ��       3          0    18099    projeto 
   TABLE DATA           �   COPY public.projeto (id_projeto, descricao, imagem_url, localizacao, status, tipo, titulo, id_usuario_criador, id_pais, id_cidade, id_estado) FROM stdin;
    public          postgres    false    229   w�       <          0    18321    rede_social 
   TABLE DATA           ;   COPY public.rede_social (id_rede_social, nome) FROM stdin;
    public          postgres    false    238   o�       6          0    18112    usuario 
   TABLE DATA           �   COPY public.usuario (id_usuario, data_nascimento, email, imagem_url, nome, premium, senha, sobre_min, username, id_cidade, id_estado, localizacao, id_pais) FROM stdin;
    public          postgres    false    232   ��       7          0    18117    usuario_habilidade 
   TABLE DATA           G   COPY public.usuario_habilidade (id_usuario, id_habilidade) FROM stdin;
    public          postgres    false    233   ��       :          0    18236    usuario_profissao 
   TABLE DATA           E   COPY public.usuario_profissao (id_usuario, id_profissao) FROM stdin;
    public          postgres    false    236   '�       ?          0    19255    usuario_projeto 
   TABLE DATA           e   COPY public.usuario_projeto (id_usuario, id_projeto, obra_favorita, usuario_solicitante) FROM stdin;
    public          postgres    false    241   h�       9          0    18121    usuario_rede_social 
   TABLE DATA           V   COPY public.usuario_rede_social (id_usuario, id_rede_social, link_perfil) FROM stdin;
    public          postgres    false    235   ��       G           0    0    cidade_id_cidade_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.cidade_id_cidade_seq', 1, false);
          public          postgres    false    216            H           0    0    cidade_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.cidade_id_seq', 27, true);
          public          postgres    false    217            I           0    0    comentario_id_comentario_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.comentario_id_comentario_seq', 830, true);
          public          postgres    false    219            J           0    0    estado_id_estado_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.estado_id_estado_seq', 3, true);
          public          postgres    false    221            K           0    0    estado_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.estado_id_seq', 30, true);
          public          postgres    false    222            L           0    0    habilidade_id_habilidade_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.habilidade_id_habilidade_seq', 1, true);
          public          postgres    false    224            M           0    0 !   linha_do_tempo_id_linha_tempo_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.linha_do_tempo_id_linha_tempo_seq', 1, false);
          public          postgres    false    226            N           0    0    pais_id_pais_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.pais_id_pais_seq', 1, true);
          public          postgres    false    239            O           0    0    profissao_id_profissao_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.profissao_id_profissao_seq', 4, true);
          public          postgres    false    228            P           0    0    projeto_id_projeto_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.projeto_id_projeto_seq', 24, true);
          public          postgres    false    230            Q           0    0    projeto_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.projeto_id_seq', 1, true);
          public          postgres    false    231            R           0    0    rede_social_id_rede_social_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.rede_social_id_rede_social_seq', 1, false);
          public          postgres    false    237            S           0    0    usuario_id_usuario_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.usuario_id_usuario_seq', 6, true);
          public          postgres    false    234            ^           2606    18125    cidade cidade_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.cidade
    ADD CONSTRAINT cidade_pkey PRIMARY KEY (id_cidade);
 <   ALTER TABLE ONLY public.cidade DROP CONSTRAINT cidade_pkey;
       public            postgres    false    215            a           2606    18127    comentario comentario_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_pkey PRIMARY KEY (id_comentario);
 D   ALTER TABLE ONLY public.comentario DROP CONSTRAINT comentario_pkey;
       public            postgres    false    218            c           2606    18129    estado estado_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);
 <   ALTER TABLE ONLY public.estado DROP CONSTRAINT estado_pkey;
       public            postgres    false    220            f           2606    18131    habilidade habilidade_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.habilidade
    ADD CONSTRAINT habilidade_pkey PRIMARY KEY (id_habilidade);
 D   ALTER TABLE ONLY public.habilidade DROP CONSTRAINT habilidade_pkey;
       public            postgres    false    223            i           2606    18133 "   linha_do_tempo linha_do_tempo_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.linha_do_tempo
    ADD CONSTRAINT linha_do_tempo_pkey PRIMARY KEY (id_linha_tempo);
 L   ALTER TABLE ONLY public.linha_do_tempo DROP CONSTRAINT linha_do_tempo_pkey;
       public            postgres    false    225                       2606    18727    pais pais_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_pkey PRIMARY KEY (id_pais);
 8   ALTER TABLE ONLY public.pais DROP CONSTRAINT pais_pkey;
       public            postgres    false    240            k           2606    18137    profissao profissao_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.profissao
    ADD CONSTRAINT profissao_pkey PRIMARY KEY (id_profissao);
 B   ALTER TABLE ONLY public.profissao DROP CONSTRAINT profissao_pkey;
       public            postgres    false    227            n           2606    18141    projeto projeto_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.projeto
    ADD CONSTRAINT projeto_pkey PRIMARY KEY (id_projeto);
 >   ALTER TABLE ONLY public.projeto DROP CONSTRAINT projeto_pkey;
       public            postgres    false    229            }           2606    18328    rede_social rede_social_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.rede_social
    ADD CONSTRAINT rede_social_pkey PRIMARY KEY (id_rede_social);
 F   ALTER TABLE ONLY public.rede_social DROP CONSTRAINT rede_social_pkey;
       public            postgres    false    238            u           2606    18145 *   usuario_habilidade usuario_habilidade_pkey 
   CONSTRAINT        ALTER TABLE ONLY public.usuario_habilidade
    ADD CONSTRAINT usuario_habilidade_pkey PRIMARY KEY (id_usuario, id_habilidade);
 T   ALTER TABLE ONLY public.usuario_habilidade DROP CONSTRAINT usuario_habilidade_pkey;
       public            postgres    false    233    233            q           2606    18147    usuario usuario_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    232            {           2606    18240 (   usuario_profissao usuario_profissao_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.usuario_profissao
    ADD CONSTRAINT usuario_profissao_pkey PRIMARY KEY (id_usuario, id_profissao);
 R   ALTER TABLE ONLY public.usuario_profissao DROP CONSTRAINT usuario_profissao_pkey;
       public            postgres    false    236    236            �           2606    19261 $   usuario_projeto usuario_projeto_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.usuario_projeto
    ADD CONSTRAINT usuario_projeto_pkey PRIMARY KEY (id_usuario, id_projeto);
 N   ALTER TABLE ONLY public.usuario_projeto DROP CONSTRAINT usuario_projeto_pkey;
       public            postgres    false    241    241            w           2606    18319 ,   usuario_rede_social usuario_rede_social_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.usuario_rede_social
    ADD CONSTRAINT usuario_rede_social_pkey PRIMARY KEY (id_usuario, id_rede_social);
 V   ALTER TABLE ONLY public.usuario_rede_social DROP CONSTRAINT usuario_rede_social_pkey;
       public            postgres    false    235    235            _           1259    18710    idx_cidade_id_estado_id_cidade    INDEX     a   CREATE INDEX idx_cidade_id_estado_id_cidade ON public.cidade USING btree (id_cidade, id_estado);
 2   DROP INDEX public.idx_cidade_id_estado_id_cidade;
       public            postgres    false    215    215            d           1259    18709    idx_estado_id    INDEX     E   CREATE INDEX idx_estado_id ON public.estado USING btree (id_estado);
 !   DROP INDEX public.idx_estado_id;
       public            postgres    false    220            g           1259    19168    idx_linha_do_tempo_id_projeto    INDEX     ^   CREATE INDEX idx_linha_do_tempo_id_projeto ON public.linha_do_tempo USING btree (id_projeto);
 1   DROP INDEX public.idx_linha_do_tempo_id_projeto;
       public            postgres    false    225            l           1259    19033    idx_projeto_id_projeto    INDEX     P   CREATE INDEX idx_projeto_id_projeto ON public.projeto USING btree (id_projeto);
 *   DROP INDEX public.idx_projeto_id_projeto;
       public            postgres    false    229            r           1259    18375 !   idx_usuario_habilidade_habilidade    INDEX     i   CREATE INDEX idx_usuario_habilidade_habilidade ON public.usuario_habilidade USING btree (id_habilidade);
 5   DROP INDEX public.idx_usuario_habilidade_habilidade;
       public            postgres    false    233            s           1259    18374    idx_usuario_habilidade_usuario    INDEX     c   CREATE INDEX idx_usuario_habilidade_usuario ON public.usuario_habilidade USING btree (id_usuario);
 2   DROP INDEX public.idx_usuario_habilidade_usuario;
       public            postgres    false    233            o           1259    19032    idx_usuario_id_usuario    INDEX     P   CREATE INDEX idx_usuario_id_usuario ON public.usuario USING btree (id_usuario);
 *   DROP INDEX public.idx_usuario_id_usuario;
       public            postgres    false    232            x           1259    18373    idx_usuario_profissao_profissao    INDEX     e   CREATE INDEX idx_usuario_profissao_profissao ON public.usuario_profissao USING btree (id_profissao);
 3   DROP INDEX public.idx_usuario_profissao_profissao;
       public            postgres    false    236            y           1259    18372    idx_usuario_profissao_usuario    INDEX     a   CREATE INDEX idx_usuario_profissao_usuario ON public.usuario_profissao USING btree (id_usuario);
 1   DROP INDEX public.idx_usuario_profissao_usuario;
       public            postgres    false    236            �           2606    18158 .   usuario_habilidade fk7ymmkw4w5wm8wqymneov4oqad    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_habilidade
    ADD CONSTRAINT fk7ymmkw4w5wm8wqymneov4oqad FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 X   ALTER TABLE ONLY public.usuario_habilidade DROP CONSTRAINT fk7ymmkw4w5wm8wqymneov4oqad;
       public          postgres    false    4721    232    233            �           2606    18163 /   usuario_rede_social fk8yyaqgtv3653hb2rg8r4cx4wn    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_rede_social
    ADD CONSTRAINT fk8yyaqgtv3653hb2rg8r4cx4wn FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 Y   ALTER TABLE ONLY public.usuario_rede_social DROP CONSTRAINT fk8yyaqgtv3653hb2rg8r4cx4wn;
       public          postgres    false    4721    235    232            �           2606    18168 &   comentario fk9619kv3mim3a4yl0m5mdhhbh1    FK CONSTRAINT     �   ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT fk9619kv3mim3a4yl0m5mdhhbh1 FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 P   ALTER TABLE ONLY public.comentario DROP CONSTRAINT fk9619kv3mim3a4yl0m5mdhhbh1;
       public          postgres    false    232    218    4721            �           2606    18178 #   projeto fk9na0ub1ktn0rodfjduu36lvyg    FK CONSTRAINT     �   ALTER TABLE ONLY public.projeto
    ADD CONSTRAINT fk9na0ub1ktn0rodfjduu36lvyg FOREIGN KEY (id_usuario_criador) REFERENCES public.usuario(id_usuario);
 M   ALTER TABLE ONLY public.projeto DROP CONSTRAINT fk9na0ub1ktn0rodfjduu36lvyg;
       public          postgres    false    4721    232    229            �           2606    19174    projeto fk_id_cidade    FK CONSTRAINT     }   ALTER TABLE ONLY public.projeto
    ADD CONSTRAINT fk_id_cidade FOREIGN KEY (id_cidade) REFERENCES public.cidade(id_cidade);
 >   ALTER TABLE ONLY public.projeto DROP CONSTRAINT fk_id_cidade;
       public          postgres    false    4702    215    229            �           2606    19179    projeto fk_id_estado    FK CONSTRAINT     }   ALTER TABLE ONLY public.projeto
    ADD CONSTRAINT fk_id_estado FOREIGN KEY (id_estado) REFERENCES public.estado(id_estado);
 >   ALTER TABLE ONLY public.projeto DROP CONSTRAINT fk_id_estado;
       public          postgres    false    4707    220    229            �           2606    19169    projeto fk_id_pais    FK CONSTRAINT     u   ALTER TABLE ONLY public.projeto
    ADD CONSTRAINT fk_id_pais FOREIGN KEY (id_pais) REFERENCES public.pais(id_pais);
 <   ALTER TABLE ONLY public.projeto DROP CONSTRAINT fk_id_pais;
       public          postgres    false    229    240    4735            �           2606    18251 &   usuario_profissao fk_profissao_usuario    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_profissao
    ADD CONSTRAINT fk_profissao_usuario FOREIGN KEY (id_profissao) REFERENCES public.profissao(id_profissao);
 P   ALTER TABLE ONLY public.usuario_profissao DROP CONSTRAINT fk_profissao_usuario;
       public          postgres    false    236    227    4715            �           2606    18246 &   usuario_profissao fk_usuario_profissao    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_profissao
    ADD CONSTRAINT fk_usuario_profissao FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 P   ALTER TABLE ONLY public.usuario_profissao DROP CONSTRAINT fk_usuario_profissao;
       public          postgres    false    4721    236    232            �           2606    18329 *   usuario_rede_social fk_usuario_rede_social    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_rede_social
    ADD CONSTRAINT fk_usuario_rede_social FOREIGN KEY (id_rede_social) REFERENCES public.rede_social(id_rede_social);
 T   ALTER TABLE ONLY public.usuario_rede_social DROP CONSTRAINT fk_usuario_rede_social;
       public          postgres    false    238    4733    235            �           2606    18198 "   cidade fkjn311p28f0okajvcboowr5kpo    FK CONSTRAINT     �   ALTER TABLE ONLY public.cidade
    ADD CONSTRAINT fkjn311p28f0okajvcboowr5kpo FOREIGN KEY (id_estado) REFERENCES public.estado(id_estado);
 L   ALTER TABLE ONLY public.cidade DROP CONSTRAINT fkjn311p28f0okajvcboowr5kpo;
       public          postgres    false    220    4707    215            �           2606    18208 #   usuario fkmdcvw9791x6v81yvikqqnnukb    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fkmdcvw9791x6v81yvikqqnnukb FOREIGN KEY (id_cidade) REFERENCES public.cidade(id_cidade);
 M   ALTER TABLE ONLY public.usuario DROP CONSTRAINT fkmdcvw9791x6v81yvikqqnnukb;
       public          postgres    false    232    215    4702            �           2606    18213 &   comentario fkn6rdgqwpg2r4sx7w8l6du8ukm    FK CONSTRAINT     �   ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT fkn6rdgqwpg2r4sx7w8l6du8ukm FOREIGN KEY (id_projeto) REFERENCES public.projeto(id_projeto);
 P   ALTER TABLE ONLY public.comentario DROP CONSTRAINT fkn6rdgqwpg2r4sx7w8l6du8ukm;
       public          postgres    false    4718    229    218            �           2606    18218 #   usuario fkoi2e3mgfjvia6vuw1s5dh88t2    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fkoi2e3mgfjvia6vuw1s5dh88t2 FOREIGN KEY (id_estado) REFERENCES public.estado(id_estado);
 M   ALTER TABLE ONLY public.usuario DROP CONSTRAINT fkoi2e3mgfjvia6vuw1s5dh88t2;
       public          postgres    false    4707    220    232            �           2606    18223 .   usuario_habilidade fkqm23rheajcnf11gmicx7lyofs    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_habilidade
    ADD CONSTRAINT fkqm23rheajcnf11gmicx7lyofs FOREIGN KEY (id_habilidade) REFERENCES public.habilidade(id_habilidade);
 X   ALTER TABLE ONLY public.usuario_habilidade DROP CONSTRAINT fkqm23rheajcnf11gmicx7lyofs;
       public          postgres    false    223    4710    233            �           2606    18228 *   linha_do_tempo fkt6pu95tfk3fwg848eg0xlgf0q    FK CONSTRAINT     �   ALTER TABLE ONLY public.linha_do_tempo
    ADD CONSTRAINT fkt6pu95tfk3fwg848eg0xlgf0q FOREIGN KEY (id_projeto) REFERENCES public.projeto(id_projeto);
 T   ALTER TABLE ONLY public.linha_do_tempo DROP CONSTRAINT fkt6pu95tfk3fwg848eg0xlgf0q;
       public          postgres    false    4718    229    225            �           2606    18728    estado pais_fk    FK CONSTRAINT     q   ALTER TABLE ONLY public.estado
    ADD CONSTRAINT pais_fk FOREIGN KEY (id_pais) REFERENCES public.pais(id_pais);
 8   ALTER TABLE ONLY public.estado DROP CONSTRAINT pais_fk;
       public          postgres    false    240    220    4735            �           2606    18733    usuario pais_fk    FK CONSTRAINT     r   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT pais_fk FOREIGN KEY (id_pais) REFERENCES public.pais(id_pais);
 9   ALTER TABLE ONLY public.usuario DROP CONSTRAINT pais_fk;
       public          postgres    false    232    4735    240            �           2606    19267 /   usuario_projeto usuario_projeto_id_projeto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_projeto
    ADD CONSTRAINT usuario_projeto_id_projeto_fkey FOREIGN KEY (id_projeto) REFERENCES public.projeto(id_projeto);
 Y   ALTER TABLE ONLY public.usuario_projeto DROP CONSTRAINT usuario_projeto_id_projeto_fkey;
       public          postgres    false    4718    241    229            �           2606    19262 /   usuario_projeto usuario_projeto_id_usuario_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.usuario_projeto
    ADD CONSTRAINT usuario_projeto_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);
 Y   ALTER TABLE ONLY public.usuario_projeto DROP CONSTRAINT usuario_projeto_id_usuario_fkey;
       public          postgres    false    4721    241    232            %   ]  x�-��n1��٧�'�{��m�6'�@UZb�Q�ݥ��$�R��#��2JL�߀�`��۔���B����}(gL��S���4�ɭ34������2Z���)��:�i�С������У����s&d�]
��D1�n�\~��q-o3H�Uܬ��0������O��c����&Z���Tݧ^ӴЯ)����Gp�F��C�dl�<'n�R�CrX��������3��)�}�s�xb�Dǿ�|��&r�6���%8�FL�e�����K� ����ǯ	D31�\���@�Z��m�Jn*�S�ak��Mm�y���:\e~Է��u��x����;�j�<      (   �  x����r�0�g�)��")�㌹f�ԩ����N$UR�з�u�u����U/V����ZN��*���M���Bǽ&����;�x�A�S�8�t��ZPlH㕞{Vx�n�"��U�)o�;�q�����ޤ�G���xЃ�>� &�x�V�5�@Y��>������eG{fK.leM7y���4E��3�Y�w,`6<�"_dMDݞC����{U��Ύ�.v�7܈:p����i"���?ZС�h	v� {V�"�:R�%EC�I�a����]ek����hv2Å�/@�u���5����)���¥���yn��Gޡ&D<o���ZG>���h쫠}����Z?]e��oNq�/�nu�-[c��4~�g�r��{�	�ģ�		;�c�$��<����f� ��Ut�񩊪�ƩRv���`��q��JEhw�W�n4�ZB�t��7�-�F�q���R_�Z�'��eks7��T��I!���y�>B�.����(�<�=پ*      *   C  x�]�=nB1��������$H���L����F~�&�A��r�w�̒&J�]{�Y+�G�g���Nӓ��+z}�9�֧���0�y��y�)�M�M�^�.;bD{��������R�1�;�<��ZcB!],�X:�_t�/�K�kz������!N+=,"�9�������
#�C������A�\�w#y����P��6�-':����viog�	V��C�j)��.���ݞ�-����K��C�_͑�Өb�Ӯ�Nܤz��!�����ߗU3k�0ԃ� k�Z�嘡E�X���gN�(:�{��nL��{���.(>:���ņ�      -   �  x�U�KN�0���S�#��D�=##�a˦H��bbWƏ�m��Ũ�`9����e$G���ixS��#Mgې�I�6�Ѭ`�����9��(My��9�Ǳ`x�q���{���匝9�%n���Ĝ�oi�Ö�]m�)\I�ɒ�|7�\t�s����1� ~r["�)��za��k�S���8K��z�9W�6�Q��~1�^Wp�%���uZ�a-��4K�s**��ZK;z�I�N������AƝ���h��;դ?��`]"6���Wp�!kH�Q�K7�M��E
*�S��QniԈ�a�PUfU���	�.��l�ڴ_h���+�^�����Z1=�<i�ok�;�7�W�+"���9�t=�<<�Ӳ�c� {�      /   �   x�u�A� ��5���T�Q��;��0�c�0)4��51.Lܾ���Yݙ��@K�f5�&���͞�1c��d;���	�r�M��c׹���od-�j��~1)�j�2�GQN;5P>�_�������
��&��������j�_�H      >      x�3�t*J,������� <J      1   �   x�U�MN�@���)r�I��Q�"��H�ظ7���g�@�+���1I�(�'?�{��bP,��
�E-���!����p5��U�\�^ڤ�'k����l次&�J�<n`g��6\-��A�M�s�*/n�7�t�n�����GGc���S�������p�r�����}�a�+�XAý���x����ЬaןS7�78����c�Ȩ42�38r��w~9)�����?��i      3   �  x�mT�n�8��>�U3Z��@���V@)��eʴL5�IL0Mlc��i��jV�S�b{:�vw%G�cߛ{�=Ǯ5����s�%	����oF�n۩I�	+�D
���0�,�	�Q<�$�1N�M0����Ƶ� +H��12���Y�3ajd�	0a�!�$+���C9���I|L�ߔ���%@0U�J��Uox�!�46��i��)�ƫG��>O";�	w??���߶��Ir>PJ�7睇uvΩ�h{��ۡ-��$�S�եL�ӈ��OM��Z� ��r�4�� wi���by�ea����	:M贻~�h��������/�Z��P�P��4�z5����_������m<?�_���Tf�͸�Dd��4��	�QB ���_��0Rő2����8��$��
��&Y(��aJ�p�iLȈ()���_UB՗���a���5Sq�@3H�B�PifLET��DDJ3KK��K��sxbfYV�@$퍊�����A�����}��:�jU����P�%���r��T��u	����ZsV2RU�-U.�[��p�F�����I�9>uZ��6�d����E��n�HAb�ǟXh�Rd�HE`<}�!��]^���������{M��x�k9�I�;^�^)z�˙����b�4�;�� 3���#K�F�DI_�,Ҳr�0����ȓ)]\���s4Hu$r�l�x��8���cELۑ�Q��g�E� �������.���|aF�j�m�nCo��K9T�np�qw��0�f��k�d2ؙ�ԅ�\M�Cw�6!Κn�0],2�����e��+�{��B��x�yۡ������p��/��ug���rUt��?Y����N��oz��o�k_M�����>_�?8�B~�{�ڲm��-�EQQ6���������	��Y��D���LT.y��S�|t3�-�}tt�Rvx      <      x������ � �      6   D  x�œ�N�0��ӫ�ڎ��P��J�������&'qS����i���.��U��z�dK���������{�z�I)(�a����V�c���<�V��x����M�AƄ8�������W��y��>w��/-^����R,n���Ɇvv}�����ߏַ�����Y"�Q:�N�����j�V��QKnW��>Քo]U(_�Ʒ,��V%�>�Tk�������n�^��t�eƲ=�\�p�0�yO��,��m��H�ܪ��B0�Yc���GJ��(8�!��ӧ�˿���ok}w�ͶӉ�(���cʖ�͇%4g7���ŧ��|:_��ߌ6q5�]��4���a �����J���-�f��6�`��eN/�� WҺ��Z��8_�if��ƽ�;�pԲ`f����r�}��;�?r$���U����,#�Eq�HQ���g$JI�4Y�.Ĕ�iFX��{�.�TR����D?�A�s۪�\a���,��z�1�u[rI7�RA_T�Љ�7�� AQ��%��ni��htx��W�Y�
���%�e�PM��eˍ�R�-ZU�%���5x����R�i      7   7   x���  �7c�{��:D;	l�09��S��)T����o�
����R	1      :   1   x�3��2�44�2�44 F\��� l�e�ih	",���BF �=... ���      ?      x������ � �      9      x������ � �     