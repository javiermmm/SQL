CREATE TABLE Restaurantes
( código Number(8) NOT NULL,
  nombre Char(20),
  calle	Char(30),
  "código postal" Char(5),
  comisión Number(8,2), 
  PRIMARY KEY (código)
);
CREATE SEQUENCE	restaurantes_seq;
INSERT INTO Restaurantes VALUES (12345678, 'NombreRestaurante_A', 'calle_A', 'AAAAA', 123456.78);
INSERT INTO Restaurantes VALUES (01234567, 'NombreRestaurante_B', 'calle_B', 'BBBBB', 123456.78);


CREATE TABLE "Areas Cobertura"
( restaurante 	Number(8) NOT NULL,
  "código postal"	Char(5) NOT NULL,
  PRIMARY KEY (restaurante, "código postal"),
  FOREIGN KEY (restaurante) REFERENCES Restaurantes ON DELETE CASCADE
);
INSERT INTO "Areas Cobertura" VALUES (12345678, 'XXXXX');
INSERT INTO "Areas Cobertura" VALUES (01234567, 'YYYYY');


CREATE TABLE Horarios
( restaurante Number(8) NOT NULL,
  "día semana" Char (1) NOT NULL,
  hora_apertura Date,
  hora_cierre Date,
  PRIMARY KEY (restaurante, "día semana"),
  FOREIGN KEY (restaurante) REFERENCES Restaurantes ON DELETE CASCADE
);
--------------------------------------------------------------------------------------------
------FALTABAN LOS NOT NULL. (Tabla modificada [ALTER TABLE]. ya están puestos los NOT NULL)
ALTER TABLE Horarios MODIFY restaurante Number(8) NOT NULL;
ALTER TABLE Horarios MODIFY "día semana" Char (1) NOT NULL;
--------------------------------------------------------------------------------------------
INSERT INTO Horarios VALUES (12345678, 'L',  TO_DATE('09:00', 'HH24:MI'),  TO_DATE('22:00', 'HH24:MI'));
INSERT INTO Horarios VALUES (01234567, 'D',  TO_DATE('09:00', 'HH24:MI'),  TO_DATE('22:00', 'HH24:MI'));
-------ESTO FUNCIONA PERO AÑADE POR DEFECTO LA FECHA DEL DÍA DE HOY, Y AL HACERLE UN SELECT SOLO SE VE LA FECHA Y NO LA HORA


CREATE TABLE Platos
( restaurante Number(8) NOT NULL,
  nombre Char(20) NOT NULL,
  precio Number(8,2),
  descripción Char(30),
  categoría Char(10),
  PRIMARY KEY (restaurante, nombre),
  FOREIGN KEY (restaurante) REFERENCES Restaurantes ON DELETE CASCADE
);
CREATE INDEX indice_platos ON Platos (categoría);
INSERT INTO Platos VALUES (12345678, 'NombrePlato_C', 123456.78, 'filete de ternera', 'carnes');
INSERT INTO Platos VALUES (01234567, 'NombrePlato_D', 123456.78, 'merluza a la vasca', 'pescados');


CREATE TABLE Clientes
( DNI Char(9) NOT NULL,
  nombre Char (20),
  apellidos Char (20),
  calle Char (20),
  número Number(4),
  piso Char(5),
  localidad Char(15),
  "código postal" Char(5),
  teléfono Char (9),
  usuario Char (8) UNIQUE,
  contraseña Char(8) DEFAULT "Nopass",
  PRIMARY KEY (DNI),
);
INSERT INTO Clientes VALUES ('98765432K', 'Manuel', 'Fernández Gómez', 'Gran Vía', 16, 2, 'Madrid', 'AAAAA', '600606060', 'user1', 'pass1');
INSERT INTO Clientes VALUES ('98765432W', 'Clara', 'García Nuñez', 'Capitán Almanzor', 84, 5, 'Teruel', 'BBBBB', '611616161', 'user2', 'pass2');


CREATE TABLE Pedidos
( código Number(8) NOT NULL,
  estado Char(9) DEFAULT 'REST',
  CONSTRAINT estado CHECK (estado IN ('REST', 'CANCEL', 'RUTA', 'ENTREGADO', 'RECHAZADO')),
  fecha_hora_pedido Date,
  fecha_hora_entrega Date,
  "importe total" Number(8,2),
  cliente Char (9),
  PRIMARY KEY (código),
  FOREIGN KEY (cliente) REFERENCES Clientes ON DELETE CASCADE
);
CREATE INDEX indice_pedidos ON Pedidos (estado);
CREATE SEQUENCE	pedidos_seq START WITH 1;
--------------------------------------------------------------------------------------------
INSERT INTO Pedidos VALUES (12345678, 'RECHAZADO', TO_DATE('11-11-2011 11:11:11', 'DD-MM-YYYY HH24:MI:SS'), TO_DATE('12-12-2011 12:12:12', 'DD-MM-YYYY HH24:MI:SS'), 123456.78, '98765432K');
INSERT INTO Pedidos VALUES (01234567, 'CANCEL', TO_DATE('12-12-2011 12:12:12', 'DD-MM-YYYY HH24:MI:SS'), TO_DATE('11-11-2011 11:11:11', 'DD-MM-YYYY HH24:MI:SS'), 122223.78, '98765432W');
-------ESTO FUNCIONA PERO AL HACERLE UN SELECT SOLO SE VE LA FECHA Y NO LA HORA


CREATE TABLE Contiene
( restaurante Number(8) NOT NULL,
  plato Char(20) NOT NULL,
  pedido Number(8) NOT NULL,
  "precio con comisión" Number(8,2),
  unidades Number(4),
  PRIMARY KEY (restaurante, plato, pedido),
  FOREIGN KEY (pedido) REFERENCES Pedidos ON DELETE CASCADE,
  FOREIGN KEY (restaurante, plato) REFERENCES Platos ON DELETE CASCADE
);
INSERT INTO Contiene VALUES (12345678, 'NombrePlato_C', 01234567, 123456.78, 23);
INSERT INTO Contiene VALUES (01234567, 'NombrePlato_D', 12345678, 123456.78, 5);


CREATE TABLE Descuentos
( código Number(8) NOT NULL,
  fecha_caducidad Date,
  "porcentaje descuento" Number(3) CHECK (("porcentaje descuento" > 0) AND ("porcentaje descuento" <= 100)),
  PRIMARY KEY (código)
);
CREATE SEQUENCE	descuentos_seq;
INSERT INTO Descuentos VALUES (12345678, '11-11-2011', 15);
INSERT INTO Descuentos VALUES (01234567, '12-12-2011', 18);


CREATE TABLE AplicadoA 
( descuento Number(8) NOT NULL,
  pedido Number(8) NOT NULL,
  PRIMARY KEY (descuento, pedido),
  FOREIGN KEY (descuento) REFERENCES Descuentos ON DELETE CASCADE,
  FOREIGN KEY (pedido) REFERENCES Pedidos ON DELETE CASCADE
);
INSERT INTO AplicadoA VALUES (01234567, 12345678);
INSERT INTO AplicadoA VALUES (12345678, 01234567);