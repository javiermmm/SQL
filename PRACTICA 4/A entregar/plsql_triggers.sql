-----------------------------------------------------------------------------
--Antes de comenzar a crear nuestros disparadores debemos conceder
--los permisos pertinentes. Para ello deberemos adoptar el papel de ADMINUSER
--y realizar la siguiente sentencia:
--
--	GRANT CREATE TRIGGER TO GESB03
--
--Ahora ya podemos pasar a la creacion de los disparadores pedidos
-----------------------------------------------------------------------------


/*
ENUNCIADO APARTADO 2
-------------------------------
2. Crea un disparador llamado control_pedidos_restaurantes que se asocie a Contiene y
que controle que los pedidos sólo pueden tener platos de un único restaurante. Para cancelar una
operación se lanzará una excepción de usuario con el comando RAISE_APPLICATION_ERROR.
*/

-----------------------------------------------------------------------------
--APARTADO 2
--Pedidos con platos de un solo restaurante
-----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER control_pedidos_restaurantes
	BEFORE INSERT OR UPDATE OF Restaurante ON Contiene
	FOR EACH ROW
DECLARE
	rest Contiene.Restaurante%TYPE;
	
BEGIN

	--Conseguimos el restaurante en cuestión
	SELECT Restaurante INTO rest
	FROM Contiene c
	WHERE c.pedido = :NEW.pedido
	GROUP BY Restaurante;	
	
	--Si es distinto del que tratamos de insertar
	IF (rest <> :NEW.Restaurante) THEN	
	
			RAISE_APPLICATION_ERROR 
					(-20000, 'ERROR: UN PEDIDO SOLO PUEDE CONTENER PLATOS DE UN MISMO RESTAURANTE');	
					
	END IF;	
	
END control_pedidos_restaurantes;


---------------------------------
--SENTENCIA DE PRUEBA
---------------------------------
INSERT INTO Contiene VALUES (2345, 'hot-burguer', 8, 99.99, 50);



/*
ENUNCIADO APARTADO 3
-------------------------------
3. Crea un disparador llamado control_detalle_pedidos que se asocie a todas las
operaciones posibles sobre la tabla Contiene. Al insertar una nueva fila en esta tabla, se deberá
incrementar el valor del campo importe_total de Pedidos. Si se produce la eliminación de una fila ó
una actualización, el importe se debe rectificar según la modificación introducida.
*/

-----------------------------------------------------------------------------
--APARTADO 3
--Modificacion del importe según la operación realizada
-----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER control_detalle_pedidos
	AFTER INSERT OR DELETE OR UPDATE ON Contiene
	FOR EACH ROW
DECLARE

BEGIN

	IF INSERTING THEN
	
		--Le sumamos a lo que teníamos el nuevo precio con comision segun el código del pedido
		UPDATE Pedidos SET "importe total" = "importe total" + :NEW."precio con comisión"
		WHERE código = :NEW.pedido;
	
	ELSIF UPDATING THEN
	
		--Si el valor que inserto es mayor que el antiguo
		IF (:NEW."precio con comisión" > :OLD."precio con comisión") THEN
			
			UPDATE Pedidos SET "importe total" = "importe total" + 
										(:NEW."precio con comisión" - :OLD."precio con comisión")
			WHERE código = :NEW.pedido;
		
		--Si el valor que inserto es menor que el antiguo
		ELSIF (:NEW."precio con comisión" < :OLD."precio con comisión") THEN
		
			UPDATE Pedidos SET "importe total" = "importe total" -
										(:OLD."precio con comisión" - :NEW."precio con comisión")
			WHERE código = :NEW.pedido;
		
		END IF;
	
	ELSE --DELETING
	
		--Le restamos a lo que teníamos el nuevo precio con comision segun el código del pedido
		UPDATE Pedidos SET "importe total" = "importe total" - :OLD."precio con comisión"
		WHERE código = :OLD.pedido;
	
	END IF;

END control_detalle_pedidos;


---------------------------------
--SENTENCIA DE PRUEBA
---------------------------------
UPDATE Contiene SET "precio con comisión" = 999.99
WHERE pedido = 9;
--Solucionada la cadena de disparadores con el trigger del apartado 4.



/*
ENUNCIADO APARTADO 4
-------------------------------
4.Crea un disparador llamado control_registro_ventas que se asocie a Pedidos y mantenga
actualizados los valores de la tabla REGISTRO_VENTAS. Para ello se asociará el disparador a
cada inserción o modificación de "importe total". Además, el disparador deberá evitar la
eliminación de filas en la tabla PEDIDOS. Para ello, al detectar el borrado de una fila, se deberá
mostrar un mensaje en pantalla y después cancelar la operación. Para cancelar una operación se
lanzará una excepción de usuario con el comando RAISE_APPLICATION_ERROR. ¿Qué sucede
cuando se ejecuta este disparador?, modifica mínimamente el esquema de la tabla Pedidos para
evitar que suceda este error.
*/

-----------------------------------------------------------------------------
--APARTADO 4
--Modificacion del importe según la operación realizada
-----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER control_registro_ventas
	BEFORE INSERT OR DELETE OR UPDATE OF "importe total" ON Pedidos
	FOR EACH ROW
DECLARE

	numPedidos INTEGER;
	FechaUltimoPed DATE;

BEGIN

	IF DELETING THEN
		RAISE_APPLICATION_ERROR 
					(-20001, 'ERROR: PROHIBIDA LA ELIMINACION DE FILAS EN LA TABLA DE PEDIDOS');			
	ELSE 
				
		--Conseguimos el ultimo pedido del restaurante
		SELECT fecha_ult_pedido into FechaUltimoPed
		FROM Registro_Ventas
		WHERE COD_REST = :NEW.restaurante;
		
		--Conseguimos el numero de pedidos del restaurante
		SELECT total_pedidos into numPedidos
		FROM Registro_Ventas
		WHERE COD_REST = :NEW.restaurante;
		
		--Si lo nuevo tiene fecha posterior, actualizamos la fecha
		IF (:NEW.fecha_hora_pedido > FechaUltimoPed) THEN
		
			UPDATE Registro_Ventas SET fecha_ult_pedido = :NEW.fecha_hora_pedido
			WHERE COD_REST = :NEW.restaurante;
			
		END IF;
			
		IF INSERTING THEN
		
			--Como estamos insertando un pedido nuevo, le sumamos uno
			--al numero de pedidos del restaurante
			UPDATE Registro_Ventas SET total_pedidos = total_pedidos + 1
			WHERE COD_REST = :NEW.restaurante;
				
		END IF;
		
	END IF;
	
END control_registro_ventas;


---------------------------------
--SENTENCIA DE PRUEBA
---------------------------------
UPDATE Pedidos SET "importe total" = 999.99
WHERE código = 9;
--Solucionado el error de tablas mutantes





----------------------------------------------
--CONSIDERACIONES ADICIONALES
----------------------------------------------

--Se añade a la tabla pedidos una columna nueva para poner los restaurantes:

--		ALTER TABLE Pedidos
--		ADD Restaurante NUMBER(8);


----------------------------------------------
/* PARA RELLENAR LA NUEVA COLUMNA RESTAURANTE
----------------------------------------------
--Ahora podemos usar el valor de :NEW.restaurante. Sin embargo, 
--el campo restaurante está totalmente vacio, (ERROR: No se encontraron datos)
--por lo que debemos rellenarlo primero. Para eso, creamos un bloque anónimo como el siguiente:

DECLARE
	CURSOR contenido IS SELECT pedido, restaurante
						FROM Contiene c
						GROUP BY pedido, restaurante;
BEGIN

	FOR conte IN contenido LOOP
		
		UPDATE Pedidos SET restaurante = conte.restaurante
		WHERE código = conte.pedido;
		
	END LOOP;
	
END;
*/


----------------------------------------------
/* PARA RELLENAR LA TABLA REGISTRO_VENTAS
----------------------------------------------
--Queremos rellenar la tabla registro_ventas para realizar las comprobaciones necesarias.
--Para ello ejecutamos el siguiente bloque de código anónimo

DECLARE
	CURSOR restaurante IS SELECT DISTINCT código
						  FROM Restaurantes r;
						  
	numPedidos Registro_Ventas.total_pedidos%TYPE;
	
	ultimaFecha Registro_Ventas.fecha_ult_pedido%TYPE;
	
BEGIN

	FOR rest IN restaurante LOOP
		
		SELECT COUNT(DISTINCT pedido) INTO numPedidos
		FROM Contiene
		WHERE restaurante = rest.código;
		
		SELECT MAX(fecha_hora_pedido) INTO ultimaFecha
		FROM Pedidos
		WHERE restaurante = rest.código;
		
		UPDATE Registro_ventas SET total_pedidos = numPedidos, fecha_ult_pedido = ultimaFecha
		WHERE COD_REST = rest.código;
		
	END LOOP;
	
END;
*/