/*
ENUNCIADO APARTADO 1
-------------------------------
1. Procedimiento almacenado llamado PEDIDOS_CLIENTE que reciba como par�metro el DNI de un
cliente y muestre por pantalla sus datos personales, junto con un listado con los datos de los pedidos
que ha realizado (c�digo de pedido, fecha, fecha de entrega, estado e importe del pedido), ordenados
crecientemente por fecha. En caso de error (DNI no existe, no hay pedidos para ese cliente, etc..), deber�
mostrarse por pantalla un mensaje de advertencia explicando el error. Al finalizar el listado se deber�
mostrar la suma de los importes de todos los pedidos del cliente. Incluye un bloque de c�digo an�nimo
para probar el procedimiento. 
*/

-----------------------------------------------------------------------------
--Antes de comenzar a crear nuestros procedimientos debemos conceder
--los permisos pertinentes. Para ello deberemos adoptar el papel de ADMINUSER
--y realizar la siguiente sentencia:
--
--	GRANT CREATE PROCEDURE TO GESB03
--
--Ahora ya podemos pasar a la creacion de los subprogramas pedidos
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
--APARTADO 1
--Datos Personales e informaci�n sobre los pedidos de un cliente, dado su DNI
-----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE PEDIDOS_CLIENTE (dni_cliente IN Clientes.DNI%TYPE)
IS
--Declaracion de variables
dniCliente Clientes.DNI%TYPE;
nombreCliente Clientes.nombre%TYPE;
apellidosCliente Clientes.apellidos%TYPE;
calleCliente Clientes.calle%TYPE;
numeroCliente Clientes.n�mero%TYPE;
pisoCliente Clientes.piso%TYPE;
localidadCliente Clientes.localidad%TYPE;
cod_postalCliente Clientes."c�digo postal"%TYPE;
telfCliente Clientes.tel�fono%TYPE;
usuarioCliente Clientes.usuario%TYPE;
contrase�aCliente Clientes.contrase�a%TYPE;
numPedidos NUMBER;
sumaImportes NUMBER;
DNINoValido EXCEPTION;
codigoError NUMBER;
mensajeError VARCHAR2 (255);

--Con este cursor tratamos de almacenar una tabla con los pedidos del cliente,
--para ir procesandola fila a fila
CURSOR pedClientes IS  SELECT p.c�digo, p.estado, p.fecha_hora_pedido, p.fecha_hora_entrega, 
							  p."importe total"
					   FROM Pedidos p, Clientes c
					   WHERE p.cliente = c.DNI
					   AND c.DNI = dni_cliente
					   ORDER BY p.fecha_hora_pedido;

BEGIN
	--Cargamos los datos personales del cliente en sendas variables
	SELECT * INTO dniCliente, nombreCliente, apellidosCliente, calleCliente, numeroCliente, 
				  pisoCliente, localidadCliente, cod_postalCliente, telfCliente, 
				  usuarioCliente, contrase�aCliente
	FROM Clientes
	WHERE DNI = dni_cliente;

	--Mostramos los datos por pantalla
	dbms_output.put_line ('----------DATOS DEl CLIENTE----------');
	dbms_output.put_line ('DNI: ' || dniCliente);
	dbms_output.put_line ('Nombre: ' || nombreCliente);
	dbms_output.put_line ('Apellidos: ' || apellidosCliente);
	dbms_output.put_line ('Calle: ' || calleCliente);
	dbms_output.put_line ('N�mero: ' || numeroCliente);
	dbms_output.put_line ('Piso: ' || pisoCliente);
	dbms_output.put_line ('Localidad: ' || localidadCliente);
	dbms_output.put_line ('C�digo Postal: ' || cod_postalCliente);
	dbms_output.put_line ('Tel�fono: ' || telfCliente);
	dbms_output.put_line ('-------------------------------------');
	dbms_output.put_line ('');
	dbms_output.put_line ('---------------PEDIDOS---------------');
		
	--Con pedido tratamos de identificar una fila de la tabla
	--Para cada fila (pedido), mostramos por pantalla sus datos
	--NOTA: Al hacer un bucle FOR...LOOP se ejecutan autoamticamente las instruciones
	--      OPEN, FETCH y CLOSE
	FOR pedido IN pedClientes LOOP
		
		dbms_output.put_line ('C�digo: ' || pedido.c�digo);
		dbms_output.put_line ('Estado: ' || pedido.estado);
		dbms_output.put_line ('Fecha y Hora de Pedido: ' || TO_CHAR(pedido.fecha_hora_pedido));
		dbms_output.put_line ('Fecha y Hora de Entrega: ' || TO_CHAR(pedido.fecha_hora_entrega));
		dbms_output.put_line ('Importe: ' || pedido."importe total");
		dbms_output.put_line ('');
		
	END LOOP;
	
	dbms_output.put_line ('');
		
	--Calculamos la suma total de los importes de los pedidos
	SELECT SUM("importe total") 
	INTO   sumaImportes
	FROM   Pedidos 
	WHERE  cliente = dni_cliente;
	
	--Mostramos por pantalla la cantidad anteriormente calculada
	dbms_output.put_line ('-------------------------------------');
	dbms_output.put_line ('IMPORTE TOTAL DE LOS PEDIDOS:' || sumaImportes);

	--Excepciones
	EXCEPTION
		WHEN NO_DATA_FOUND THEN 
			dbms_output.put_line ('ERROR: El cliente con ese DNI no tiene pedidos');
		WHEN DNINoValido THEN 
			dbms_output.put_line ('ERROR: No se pudo recuperar los datos del cliente con ese DNI');
		WHEN PROGRAM_ERROR THEN 
			dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
		WHEN TOO_MANY_ROWS THEN 
			dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
		WHEN OTHERS THEN 
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
			codigoError := SQLCODE;
			mensajeError := SQLERRM;
			dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
			dbms_output.put_line (mensajeError);
	
END PEDIDOS_CLIENTE;


------------------------------
--BLOQUE An�nimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	PEDIDOS_CLIENTE ('12345678M');
END;


/*
ENUNCIADO APARTADO 2
-------------------------------
2. Procedimiento almacenado con el nombre MENU que reciba el nombre (no el c�digo) de un
restaurante y muestre, para cada categor�a de productos almacenada en la base de datos (ordenadas
alfab�ticamente), un listado con el nombre de sus platos y precio de venta, comisi�n incluida. El
listado para cada categor�a estar� ordenado por nombre de producto e incluir� el n�mero de platos
para cada categor�a. Al final del listado se mostrar� tambi�n el total de platos en el restaurante.
[...]
Incluye un bloque de c�digo an�nimo para probar el procedimiento. Se debe implementar tambi�n un
control de errores an�logo a los descritos en los apartados anteriores.
*/


-----------------------------------------------------------------------------
--APARTADO 2
--Platos por categoria a partir del nombre (no c�digo) de un restaurante dado
-----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE MENU (nombre_res IN Restaurantes.nombre%TYPE)
IS
--Declaracion de variables
codigoRes Restaurantes.c�digo%TYPE;
contPlatosTotales NUMBER;
contPlatosCat NUMBER;
nombreResNoValido EXCEPTION;
codigoError NUMBER;
mensajeError VARCHAR2 (255);

--Con este cursor conseguimos una tabla con todas las categor�as que deberemos procesar despues
CURSOR categorias IS SELECT DISTINCT p.categor�a
					 FROM Platos p
					 ORDER BY p.categor�a;


--Con este cursor tratamos de almacenar una tabla con los platos de un restaurante, 
--ordenados por categoria, para ir procesandola fila a fila
CURSOR platosCategorias (codRes IN Restaurantes.c�digo%TYPE)
IS 
	SELECT p.nombre, p.categor�a, p.precio, r.comisi�n
	FROM Restaurantes r, Platos p
	WHERE r.c�digo = p.restaurante
	AND p.restaurante = codRes
	ORDER BY p.nombre;

--Bloque del PROCEDURE
BEGIN

	--Obtenemos el c�digo del restaurante pedido en la variable codigoRes
	SELECT r.c�digo INTO codigoRes
	FROM Restaurantes r
	WHERE r.nombre = nombre_res;
	
	--Inicio de la impresion por pantalla
	dbms_output.put_line ('#   Restaurante: ' || nombre_res || '   #');
	dbms_output.put_line ('----------------------------------------------------');
	
	--Inicializamos un contador para llevar el numero total de platos del restaurante
	contPlatosTotales := 0;
	
	--Empezamos el procesamiento. Para cada categor�a almacenada en la Base de Datos...
	FOR cat IN categorias LOOP
		
		--Escribimos el nombre de la categor�a
		dbms_output.put ('--   Categor�a: ' || cat.categor�a || '   --');
		
		--Inicializamos un contador de platos a cero para poder mostrar el total posteriormente
		contPlatosCat := 0;
		
		--...Para cada plato asociado con el restaurante introducido...
		FOR plato IN platosCategorias (codigoRes) LOOP
		
			--Si la categor�a del plato coincide con la categor�a que estoy mostrando...
			IF (cat.categor�a = plato.categor�a) THEN
				
				--Salto de l�nea para que tenga el formato correcto
				dbms_output.new_line;
				
				--Actualizamos el contador
				contPlatosCat := contPlatosCat + 1;
				
				--Mostramos la informacion. La comisi�n es un porcentaje, y hacemos el c�lculo
				dbms_output.put (plato.nombre || '  ' || plato.precio*(1 + plato.comisi�n/100));
				dbms_output.put_line ('  ' || '�' );
			END IF;
		
		END LOOP;
		
		--Mostramos la cuenta final de platos
		IF (contPlatosCat = 0) THEN 
			BEGIN
				dbms_output.put_line (' Ning�n Plato ');
			END;
		ELSE
			BEGIN
				dbms_output.put_line ('-----------------------------------------');
				dbms_output.put_line ('Total en categor�a: ' || contPlatosCat);
				dbms_output.put_line ('-----------------------------------------');
			END;
		END IF;
		
		--Actualizamos el numero de platos totales
		contPlatosTotales := contPlatosTotales + contPlatosCat;
	
	END LOOP;
	
	--Escribimos el final del conteo con los platos totales
	dbms_output.put_line ('----------------------------------------------------');
	dbms_output.put_line ('#   Total Platos: ' || contPlatosTotales || '   #');

	--Excepciones
	EXCEPTION
		WHEN NO_DATA_FOUND THEN 
			dbms_output.put_line ('ERROR: El restaurante con ese nombre no tiene platos');
		WHEN nombreResNoValido THEN 
			dbms_output.put_line ('ERROR: Recuperaci�n de datos incorrecta. Nombre NO V�LIDO.');
		WHEN PROGRAM_ERROR THEN 
			dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
		WHEN TOO_MANY_ROWS THEN 
			dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
		WHEN OTHERS THEN 
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
			codigoError := SQLCODE;
			mensajeError := SQLERRM;
			dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
			dbms_output.put_line (mensajeError);
	
END MENU;


------------------------------
--BLOQUE An�nimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	MENU ('pizzahud');
END;

/*
ENUNCIADO APARTADO 3
-------------------------------
3. Procedimiento almacenado llamado REVISA_PEDIDOS (sin argumentos) cuya misi�n es
comprobar la consistencia de los datos de todos los pedidos. El campo �precio con comisi�n� de la
tabla �Contiene� debe almacenar el precio del plato, comisi�n incluida. El campo �importe total� de
la tabla �Pedidos� debe almacenar la suma de los �precio con comisi�n� de los platos del pedido. El
procedimiento debe verificar y actualizar estos datos para todos los pedidos, de modo que resulten
consistentes. Si todos los datos son correctos, se mostrar� un mensaje indicando �Ning�n cambio en
los datos�. En caso contrario se indicar� el n�mero de filas modificadas en cada tabla. Incluye un
bloque an�nimo de prueba.
*/

-----------------------------------------------------------------------------
--APARTADO 3
--Revisi�n de datos y modificacion, en su caso, para asegurar la consistencia
-----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE REVISA_PEDIDOS
IS
--Declaracion de variables
comisionRestaurante Restaurantes.comisi�n%TYPE;
precioPlato Platos.precio%TYPE;
contCambiosContiene NUMBER;
contCambiosPedidos NUMBER;
sumaPreciosFinales NUMBER;
codigoError NUMBER;
mensajeError VARCHAR2 (255);

CURSOR contenido IS SELECT restaurante, plato, pedido, unidades,
						   NVL ("precio con comisi�n", 0) AS "precio con comisi�n"
					FROM Contiene;
					
CURSOR pedido IS SELECT c�digo, "importe total"
				 FROM Pedidos;


--Bloque del PROCEDURE
BEGIN

	--Inicializamos el contador de cambios en 'Contiene' y el de 'Pedidos'
	contCambiosContiene := 0;
	contCambiosPedidos := 0;

	--Procesamos fila a fila, la informaci�n de la tabla 'Contiene'
	--Es necesario tener almacenado el precio con comision del plato, teniendo en cuenta el n�mero
	--de unidades pedidas. Para ello, simplemente calculamos el precio del plato en concreto
	--y lo multiplicamos por la cantidad.
	FOR conte IN contenido LOOP
		
		--Conseguimos la comisi�n a aplicar, seg�n el restaurante
		SELECT comisi�n INTO comisionRestaurante
		FROM Restaurantes r
		WHERE r.c�digo = conte.restaurante;
		
		--Conseguimos el precio del plato de la fila que estamos tratando
		SELECT precio INTO precioPlato
		FROM Platos p
		WHERE p.nombre = conte.plato;
		
		--Comprobamos que no se cumpla la condici�n. Realizamos los redondeos porque aunque la
		--cantidad obtenida se trunca sola por el tipo de finido (NUMBER (8,2)), lo que comparamos
		--son el valor almacenado y el calculado.
		IF (conte."precio con comisi�n") <> 
		   round (conte.unidades * round ((precioPlato * (1 + comisionRestaurante/100)), 2), 2) THEN
		 
			--Actualizamos el contenido de la tabla 'Contiene'
			UPDATE Contiene 
			SET "precio con comisi�n" = 
			    round (conte.unidades * round ((precioPlato * (1 + comisionRestaurante/100)), 2), 2)
			WHERE conte.plato = plato
			AND conte.pedido = pedido;
		
			--Actualizamos el contador
			contCambiosContiene := contCambiosContiene + 1;
		
		END IF;

	END LOOP;
	
	--Procesamos fila a fila, la informaci�n de la tabla Pedidos
	FOR ped IN pedido LOOP
	
		--Conseguimos la suma de los precios con comision de los platos del pedido actual
		SELECT SUM("precio con comisi�n") INTO sumaPreciosFinales
		FROM Contiene c
		WHERE c.pedido = ped.c�digo;
		
		IF ((ped."importe total") <> sumaPreciosFinales) THEN
			
			--Actualizamos el importe total con la suma de los precios finales del pedido actual
			UPDATE Pedidos p SET p."importe total" = sumaPreciosFinales
			WHERE c�digo = ped.c�digo;
		
		
			--Actualizamos el contador
			contCambiosPedidos := contCambiosPedidos + 1;
		
		END IF;
		
	END LOOP;
	
	--Mostramos por pantalla el n�mero de cambios realizados
	IF (contCambiosContiene = 0) AND (contCambiosPedidos = 0) THEN
		dbms_output.put_line ('Ning�n cambio en los datos');
	ELSE
		dbms_output.put_line('Filas modificadas en la tabla Contiene: '||contCambiosContiene );
		dbms_output.put_line('Filas modificadas en la tabla Pedidos: '||contCambiosPedidos );
	END IF;
	
	--Excepciones
	EXCEPTION
		WHEN NO_DATA_FOUND THEN 
			dbms_output.put_line ('ERROR: Se trat� de recuperar valores inexistentes');
		WHEN PROGRAM_ERROR THEN 
			dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
		WHEN TOO_MANY_ROWS THEN 
			dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
		WHEN VALUE_ERROR THEN
			dbms_output.put_line ('ERROR: Se detect� un fallo aritm�tico');
		WHEN ZERO_DIVIDE THEN
			dbms_output.put_line ('ERROR: Se intent� realizar una division por cero');
		WHEN OTHERS THEN 
			dbms_output.put_line ('ERROR: Problema no esperado.');
			codigoError := SQLCODE;
			mensajeError := SQLERRM;
			dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
			dbms_output.put_line (mensajeError);
		
END REVISA_PEDIDOS;


------------------------------
--BLOQUE An�nimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	REVISA_PEDIDOS;
END;

/*
ENUNCIADO APARTADO 3
-------------------------------
4. Construye un paquete llamado PRACTICA3 que incluya los subprogramas creados en los apartados
anteriores. Para probar su funcionamiento crea un bloque an�nimo que unifique las pruebas de los
apartados anteriores �retocadas� para utilizar los subprogramas del paquete.
*/

-----------------------------------------------------------------------------
--APARTADO 4
--Crear un paquete denominado "PRACTICA3" para agrupar
--los procedimientos creados en los apartados anteriores
-----------------------------------------------------------------------------

--Para crear un paquete son necesarios dos pasos:
--		Su especificacion (interfaz)
--		Su implementacion.

--ESPECIFICACION
CREATE OR REPLACE PACKAGE PRACTICA3
IS

	--Declaraci�n de los procedimientos p�blicos
	PROCEDURE PEDIDOS_CLIENTE (dni_cliente IN Clientes.DNI%TYPE);

	PROCEDURE MENU (nombre_res IN Restaurantes.nombre%TYPE);
	
	PROCEDURE REVISA_PEDIDOS;
	
END PRACTICA3;


--IMPLEMENTACION
CREATE OR REPLACE PACKAGE BODY PRACTICA3
IS
	
	----------------------------------------------
	--PROCEDIMIENTO PEDIDOS_CLIENTE DEL APARTADO 1
	----------------------------------------------
	
	PROCEDURE PEDIDOS_CLIENTE (dni_cliente IN Clientes.DNI%TYPE)
	IS
	--Declaracion de variables
	dniCliente Clientes.DNI%TYPE;
	nombreCliente Clientes.nombre%TYPE;
	apellidosCliente Clientes.apellidos%TYPE;
	calleCliente Clientes.calle%TYPE;
	numeroCliente Clientes.n�mero%TYPE;
	pisoCliente Clientes.piso%TYPE;
	localidadCliente Clientes.localidad%TYPE;
	cod_postalCliente Clientes."c�digo postal"%TYPE;
	telfCliente Clientes.tel�fono%TYPE;
	usuarioCliente Clientes.usuario%TYPE;
	contrase�aCliente Clientes.contrase�a%TYPE;
	numPedidos NUMBER;
	sumaImportes NUMBER;
	DNINoValido EXCEPTION;
	codigoError NUMBER;
	mensajeError VARCHAR2 (255);

	--Con este cursor tratamos de almacenar una tabla con los pedidos del cliente,
	--para ir procesandola fila a fila
	CURSOR pedClientes IS  SELECT p.c�digo, p.estado, p.fecha_hora_pedido, p.fecha_hora_entrega, 
								  p."importe total"
						   FROM Pedidos p, Clientes c
						   WHERE p.cliente = c.DNI
						   AND c.DNI = dni_cliente
						   ORDER BY p.fecha_hora_pedido;

	BEGIN
		--Cargamos los datos personales del cliente en sendas variables
		SELECT * INTO dniCliente, nombreCliente, apellidosCliente, calleCliente, numeroCliente, 
					  pisoCliente, localidadCliente, cod_postalCliente, telfCliente, 
					  usuarioCliente, contrase�aCliente
		FROM Clientes
		WHERE DNI = dni_cliente;

		--Mostramos los datos por pantalla
		dbms_output.put_line ('----------DATOS DEl CLIENTE----------');
		dbms_output.put_line ('DNI: ' || dniCliente);
		dbms_output.put_line ('Nombre: ' || nombreCliente);
		dbms_output.put_line ('Apellidos: ' || apellidosCliente);
		dbms_output.put_line ('Calle: ' || calleCliente);
		dbms_output.put_line ('N�mero: ' || numeroCliente);
		dbms_output.put_line ('Piso: ' || pisoCliente);
		dbms_output.put_line ('Localidad: ' || localidadCliente);
		dbms_output.put_line ('C�digo Postal: ' || cod_postalCliente);
		dbms_output.put_line ('Tel�fono: ' || telfCliente);
		dbms_output.put_line ('-------------------------------------');
		dbms_output.put_line ('');
		dbms_output.put_line ('---------------PEDIDOS---------------');
			
		--Con pedido tratamos de identificar una fila de la tabla
		--Para cada fila (pedido), mostramos por pantalla sus datos
		--NOTA: Al hacer un bucle FOR...LOOP se ejecutan autoamticamente las instruciones
		--      OPEN, FETCH y CLOSE
		FOR pedido IN pedClientes LOOP
			
			dbms_output.put_line('C�digo: ' || pedido.c�digo);
			dbms_output.put_line('Estado: ' || pedido.estado);
			dbms_output.put_line('Fecha y Hora de Pedido: ' || TO_CHAR(pedido.fecha_hora_pedido));
			dbms_output.put_line('Fecha y Hora de Entrega: ' || TO_CHAR(pedido.fecha_hora_entrega));
			dbms_output.put_line('Importe: ' || pedido."importe total");
			dbms_output.put_line('');
			
		END LOOP;
		
		dbms_output.put_line ('');
			
		--Calculamos la suma total de los importes de los pedidos
		SELECT SUM("importe total") 
		INTO   sumaImportes
		FROM   Pedidos 
		WHERE  cliente = dni_cliente;
		
		--Mostramos por pantalla la cantidad anteriormente calculada
		dbms_output.put_line ('-------------------------------------');
		dbms_output.put_line ('IMPORTE TOTAL DE LOS PEDIDOS:' || sumaImportes);

		--Excepciones
		EXCEPTION
			WHEN NO_DATA_FOUND THEN 
				dbms_output.put_line('ERROR: El cliente con ese DNI no tiene pedidos');
			WHEN DNINoValido THEN 
				dbms_output.put_line('ERROR: No se recuperaron los datos del cliente con ese DNI');
			WHEN PROGRAM_ERROR THEN 
				dbms_output.put_line('ERROR: Se Produjo un fallo interno al ejecutar el programa');
			WHEN TOO_MANY_ROWS THEN 
				dbms_output.put_line('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
			WHEN OTHERS THEN 
				dbms_output.put_line('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
				dbms_output.put_line('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
				codigoError := SQLCODE;
				mensajeError := SQLERRM;
				dbms_output.put_line('Error: ' || TO_CHAR(codigoError));
				dbms_output.put_line(mensajeError);
		
	END PEDIDOS_CLIENTE;
	
	
	----------------------------------------------
	--PROCEDIMIENTO MENU DEL APARTADO 2
	----------------------------------------------

	PROCEDURE MENU (nombre_res IN Restaurantes.nombre%TYPE)
	IS
	--Declaracion de variables
	codigoRes Restaurantes.c�digo%TYPE;
	contPlatosTotales NUMBER;
	contPlatosCat NUMBER;
	nombreResNoValido EXCEPTION;
	codigoError NUMBER;
	mensajeError VARCHAR2 (255);

	--Con este cursor conseguimos una tabla con todas las categor�as que deberemos procesar despues
	CURSOR categorias IS SELECT DISTINCT p.categor�a
						 FROM Platos p
						 ORDER BY p.categor�a;


	--Con este cursor tratamos de almacenar una tabla con los platos de un restaurante, 
	--ordenados por categoria, para ir procesandola fila a fila
	CURSOR platosCategorias (codRes IN Restaurantes.c�digo%TYPE)
	IS 
		SELECT p.nombre, p.categor�a, p.precio, r.comisi�n
		FROM Restaurantes r, Platos p
		WHERE r.c�digo = p.restaurante
		AND p.restaurante = codRes
		ORDER BY p.nombre;

	--Bloque del PROCEDURE
	BEGIN

		--Obtenemos el c�digo del restaurante pedido en la variable codigoRes
		SELECT r.c�digo INTO codigoRes
		FROM Restaurantes r
		WHERE r.nombre = nombre_res;
		
		--Inicio de la impresion por pantalla
		dbms_output.put_line ('#   Restaurante: ' || nombre_res || '   #');
		dbms_output.put_line ('----------------------------------------------------');
		
		--Inicializamos un contador para llevar el numero total de platos del restaurante
		contPlatosTotales := 0;
		
		--Empezamos el procesamiento. Para cada categor�a almacenada en la Base de Datos...
		FOR cat IN categorias LOOP
			
			--Escribimos el nombre de la categor�a
			dbms_output.put ('--   Categor�a: ' || cat.categor�a || '   --');
			
			--Inicializamos un contador de platos a cero para poder mostrar el total posteriormente
			contPlatosCat := 0;
			
			--...Para cada plato asociado con el restaurante introducido...
			FOR plato IN platosCategorias (codigoRes) LOOP
			
				--Si la categor�a del plato coincide con la categor�a que estoy mostrando...
				IF (cat.categor�a = plato.categor�a) THEN
					
					--Salto de l�nea para que tenga el formato correcto
					dbms_output.new_line;
					
					--Actualizamos el contador
					contPlatosCat := contPlatosCat + 1;
					
					--Mostramos la informacion. La comisi�n es un porcentaje, y hacemos el c�lculo
					dbms_output.put (plato.nombre || '  ' || plato.precio*(1 + plato.comisi�n/100));
					dbms_output.put_line ('  ' || '�' );
				END IF;
			
			END LOOP;
			
			--Mostramos la cuenta final de platos
			IF (contPlatosCat = 0) THEN 
				BEGIN
					dbms_output.put_line (' Ning�n Plato ');
				END;
			ELSE
				BEGIN
					dbms_output.put_line ('-----------------------------------------');
					dbms_output.put_line ('Total en categor�a: ' || contPlatosCat);
					dbms_output.put_line ('-----------------------------------------');
				END;
			END IF;
			
			--Actualizamos el numero de platos totales
			contPlatosTotales := contPlatosTotales + contPlatosCat;
		
		END LOOP;
		
		--Escribimos el final del conteo con los platos totales
		dbms_output.put_line ('----------------------------------------------------');
		dbms_output.put_line ('#   Total Platos: ' || contPlatosTotales || '   #');

		--Excepciones
		EXCEPTION
			WHEN NO_DATA_FOUND THEN 
				dbms_output.put_line ('ERROR: El restaurante con ese nombre no tiene platos');
			WHEN nombreResNoValido THEN 
				dbms_output.put_line ('ERROR: Recuperaci�n de datos incorrecta. Nombre NO V�LIDO.');
			WHEN PROGRAM_ERROR THEN 
				dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
			WHEN TOO_MANY_ROWS THEN 
				dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
			WHEN OTHERS THEN 
				dbms_output.put_line ('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
				dbms_output.put_line ('ERROR: Problema no esperado. Por favor, int�ntelo de nuevo');
				codigoError := SQLCODE;
				mensajeError := SQLERRM;
				dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
				dbms_output.put_line (mensajeError);
		
	END MENU;
	
	
	----------------------------------------------
	--PROCEDIMIENTO REVISA_PEDIDOS DEL APARTADO 3
	----------------------------------------------

	PROCEDURE REVISA_PEDIDOS
	IS
	--Declaracion de variables
	comisionRestaurante Restaurantes.comisi�n%TYPE;
	precioPlato Platos.precio%TYPE;
	contCambiosContiene NUMBER;
	contCambiosPedidos NUMBER;
	sumaPreciosFinales NUMBER;
	codigoError NUMBER;
	mensajeError VARCHAR2 (255);

	CURSOR contenido IS SELECT restaurante, plato, pedido, unidades,
							   NVL ("precio con comisi�n", 0) AS "precio con comisi�n"
						FROM Contiene;
						
	CURSOR pedido IS SELECT c�digo, "importe total"
					 FROM Pedidos;


	--Bloque del PROCEDURE
	BEGIN

		--Inicializamos el contador de cambios en 'Contiene' y el de 'Pedidos'
		contCambiosContiene := 0;
		contCambiosPedidos := 0;

		--Procesamos fila a fila, la informaci�n de la tabla 'Contiene'
		--Es necesario tener almacenado el precio con comision del plato, teniendo en cuenta el 
		--n�mero de unidades pedidas. Para ello, simplemente calculamos el precio del plato en
		--concreto y lo multiplicamos por la cantidad.
		FOR conte IN contenido LOOP
			
			--Conseguimos la comisi�n a aplicar, seg�n el restaurante
			SELECT comisi�n INTO comisionRestaurante
			FROM Restaurantes r
			WHERE r.c�digo = conte.restaurante;
			
			--Conseguimos el precio del plato de la fila que estamos tratando
			SELECT precio INTO precioPlato
			FROM Platos p
			WHERE p.nombre = conte.plato;
			
			--Comprobamos que no se cumpla la condici�n. Realizamos los redondeos porque aunque la
			--cantidad obtenida se trunca sola por el tipo de finido (NUMBER (8,2)), 
			--lo que comparamos son el valor almacenado y el calculado.
			IF (conte."precio con comisi�n") <> 
				round(conte.unidades*round ((precioPlato*(1 + comisionRestaurante/100)), 2), 2) THEN
			 
				--Actualizamos el contenido de la tabla 'Contiene'
				UPDATE Contiene 
				SET "precio con comisi�n" = 
					round (conte.unidades*round ((precioPlato*(1 + comisionRestaurante/100)), 2), 2)
				WHERE conte.plato = plato
				AND conte.pedido = pedido;
			
				--Actualizamos el contador
				contCambiosContiene := contCambiosContiene + 1;
			
			END IF;

		END LOOP;
		
		--Procesamos fila a fila, la informaci�n de la tabla Pedidos
		FOR ped IN pedido LOOP
		
			--Conseguimos la suma de los precios con comision de los platos del pedido actual
			SELECT SUM("precio con comisi�n") INTO sumaPreciosFinales
			FROM Contiene c
			WHERE c.pedido = ped.c�digo;
			
			IF ((ped."importe total") <> sumaPreciosFinales) THEN
				
				--Actualizamos el importe total con la suma de los precios finales del pedido actual
				UPDATE Pedidos p SET p."importe total" = sumaPreciosFinales
				WHERE c�digo = ped.c�digo;
			
			
				--Actualizamos el contador
				contCambiosPedidos := contCambiosPedidos + 1;
			
			END IF;
			
		END LOOP;
		
		--Mostramos por pantalla el n�mero de cambios realizados
		IF (contCambiosContiene = 0) AND (contCambiosPedidos = 0) THEN
			dbms_output.put_line ('Ning�n cambio en los datos');
		ELSE
			dbms_output.put_line('Filas modificadas en la tabla Contiene: '||contCambiosContiene );
			dbms_output.put_line('Filas modificadas en la tabla Pedidos: '||contCambiosPedidos );
		END IF;
		
		--Excepciones
		EXCEPTION
			WHEN NO_DATA_FOUND THEN 
				dbms_output.put_line ('ERROR: Se trat� de recuperar valores inexistentes');
			WHEN PROGRAM_ERROR THEN 
				dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
			WHEN TOO_MANY_ROWS THEN 
				dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
			WHEN VALUE_ERROR THEN
				dbms_output.put_line ('ERROR: Se detect� un fallo aritm�tico');
			WHEN ZERO_DIVIDE THEN
				dbms_output.put_line ('ERROR: Se intent� realizar una division por cero');
			WHEN OTHERS THEN 
				dbms_output.put_line ('ERROR: Problema no esperado.');
				codigoError := SQLCODE;
				mensajeError := SQLERRM;
				dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
				dbms_output.put_line (mensajeError);
			
	END REVISA_PEDIDOS;
	
END PRACTICA3;


------------------------------
--BLOQUE An�nimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	dbms_output.put_line ('A continuaci�n se muestran los pedidos de un cliente');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	PRACTICA3.PEDIDOS_CLIENTE ('12345678M');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('A continuaci�n se muestra el menu de un restaurante');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	PRACTICA3.MENU ('pizzahud');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('A continuaci�n se actualiza la informaci�n de los precios e importes');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	PRACTICA3.REVISA_PEDIDOS;
END;