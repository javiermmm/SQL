/*
ENUNCIADO APARTADO 1
-------------------------------
1. Procedimiento almacenado llamado PEDIDOS_CLIENTE que reciba como parámetro el DNI de un
cliente y muestre por pantalla sus datos personales, junto con un listado con los datos de los pedidos
que ha realizado (código de pedido, fecha, fecha de entrega, estado e importe del pedido), ordenados
crecientemente por fecha. En caso de error (DNI no existe, no hay pedidos para ese cliente, etc..), deberá
mostrarse por pantalla un mensaje de advertencia explicando el error. Al finalizar el listado se deberá
mostrar la suma de los importes de todos los pedidos del cliente. Incluye un bloque de código anónimo
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
--Datos Personales e información sobre los pedidos de un cliente, dado su DNI
-----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE PEDIDOS_CLIENTE (dni_cliente IN Clientes.DNI%TYPE)
IS
--Declaracion de variables
dniCliente Clientes.DNI%TYPE;
nombreCliente Clientes.nombre%TYPE;
apellidosCliente Clientes.apellidos%TYPE;
calleCliente Clientes.calle%TYPE;
numeroCliente Clientes.número%TYPE;
pisoCliente Clientes.piso%TYPE;
localidadCliente Clientes.localidad%TYPE;
cod_postalCliente Clientes."código postal"%TYPE;
telfCliente Clientes.teléfono%TYPE;
usuarioCliente Clientes.usuario%TYPE;
contraseñaCliente Clientes.contraseña%TYPE;
numPedidos NUMBER;
sumaImportes NUMBER;
DNINoValido EXCEPTION;
codigoError NUMBER;
mensajeError VARCHAR2 (255);

--Con este cursor tratamos de almacenar una tabla con los pedidos del cliente,
--para ir procesandola fila a fila
CURSOR pedClientes IS  SELECT p.código, p.estado, p.fecha_hora_pedido, p.fecha_hora_entrega, 
							  p."importe total"
					   FROM Pedidos p, Clientes c
					   WHERE p.cliente = c.DNI
					   AND c.DNI = dni_cliente
					   ORDER BY p.fecha_hora_pedido;

BEGIN
	--Cargamos los datos personales del cliente en sendas variables
	SELECT * INTO dniCliente, nombreCliente, apellidosCliente, calleCliente, numeroCliente, 
				  pisoCliente, localidadCliente, cod_postalCliente, telfCliente, 
				  usuarioCliente, contraseñaCliente
	FROM Clientes
	WHERE DNI = dni_cliente;

	--Mostramos los datos por pantalla
	dbms_output.put_line ('----------DATOS DEl CLIENTE----------');
	dbms_output.put_line ('DNI: ' || dniCliente);
	dbms_output.put_line ('Nombre: ' || nombreCliente);
	dbms_output.put_line ('Apellidos: ' || apellidosCliente);
	dbms_output.put_line ('Calle: ' || calleCliente);
	dbms_output.put_line ('Número: ' || numeroCliente);
	dbms_output.put_line ('Piso: ' || pisoCliente);
	dbms_output.put_line ('Localidad: ' || localidadCliente);
	dbms_output.put_line ('Código Postal: ' || cod_postalCliente);
	dbms_output.put_line ('Teléfono: ' || telfCliente);
	dbms_output.put_line ('-------------------------------------');
	dbms_output.put_line ('');
	dbms_output.put_line ('---------------PEDIDOS---------------');
		
	--Con pedido tratamos de identificar una fila de la tabla
	--Para cada fila (pedido), mostramos por pantalla sus datos
	--NOTA: Al hacer un bucle FOR...LOOP se ejecutan autoamticamente las instruciones
	--      OPEN, FETCH y CLOSE
	FOR pedido IN pedClientes LOOP
		
		dbms_output.put_line ('Código: ' || pedido.código);
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
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
			codigoError := SQLCODE;
			mensajeError := SQLERRM;
			dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
			dbms_output.put_line (mensajeError);
	
END PEDIDOS_CLIENTE;


------------------------------
--BLOQUE Anónimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	PEDIDOS_CLIENTE ('12345678M');
END;


/*
ENUNCIADO APARTADO 2
-------------------------------
2. Procedimiento almacenado con el nombre MENU que reciba el nombre (no el código) de un
restaurante y muestre, para cada categoría de productos almacenada en la base de datos (ordenadas
alfabéticamente), un listado con el nombre de sus platos y precio de venta, comisión incluida. El
listado para cada categoría estará ordenado por nombre de producto e incluirá el número de platos
para cada categoría. Al final del listado se mostrará también el total de platos en el restaurante.
[...]
Incluye un bloque de código anónimo para probar el procedimiento. Se debe implementar también un
control de errores análogo a los descritos en los apartados anteriores.
*/


-----------------------------------------------------------------------------
--APARTADO 2
--Platos por categoria a partir del nombre (no código) de un restaurante dado
-----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE MENU (nombre_res IN Restaurantes.nombre%TYPE)
IS
--Declaracion de variables
codigoRes Restaurantes.código%TYPE;
contPlatosTotales NUMBER;
contPlatosCat NUMBER;
nombreResNoValido EXCEPTION;
codigoError NUMBER;
mensajeError VARCHAR2 (255);

--Con este cursor conseguimos una tabla con todas las categorías que deberemos procesar despues
CURSOR categorias IS SELECT DISTINCT p.categoría
					 FROM Platos p
					 ORDER BY p.categoría;


--Con este cursor tratamos de almacenar una tabla con los platos de un restaurante, 
--ordenados por categoria, para ir procesandola fila a fila
CURSOR platosCategorias (codRes IN Restaurantes.código%TYPE)
IS 
	SELECT p.nombre, p.categoría, p.precio, r.comisión
	FROM Restaurantes r, Platos p
	WHERE r.código = p.restaurante
	AND p.restaurante = codRes
	ORDER BY p.nombre;

--Bloque del PROCEDURE
BEGIN

	--Obtenemos el código del restaurante pedido en la variable codigoRes
	SELECT r.código INTO codigoRes
	FROM Restaurantes r
	WHERE r.nombre = nombre_res;
	
	--Inicio de la impresion por pantalla
	dbms_output.put_line ('#   Restaurante: ' || nombre_res || '   #');
	dbms_output.put_line ('----------------------------------------------------');
	
	--Inicializamos un contador para llevar el numero total de platos del restaurante
	contPlatosTotales := 0;
	
	--Empezamos el procesamiento. Para cada categoría almacenada en la Base de Datos...
	FOR cat IN categorias LOOP
		
		--Escribimos el nombre de la categoría
		dbms_output.put ('--   Categoría: ' || cat.categoría || '   --');
		
		--Inicializamos un contador de platos a cero para poder mostrar el total posteriormente
		contPlatosCat := 0;
		
		--...Para cada plato asociado con el restaurante introducido...
		FOR plato IN platosCategorias (codigoRes) LOOP
		
			--Si la categoría del plato coincide con la categoría que estoy mostrando...
			IF (cat.categoría = plato.categoría) THEN
				
				--Salto de línea para que tenga el formato correcto
				dbms_output.new_line;
				
				--Actualizamos el contador
				contPlatosCat := contPlatosCat + 1;
				
				--Mostramos la informacion. La comisión es un porcentaje, y hacemos el cálculo
				dbms_output.put (plato.nombre || '  ' || plato.precio*(1 + plato.comisión/100));
				dbms_output.put_line ('  ' || '€' );
			END IF;
		
		END LOOP;
		
		--Mostramos la cuenta final de platos
		IF (contPlatosCat = 0) THEN 
			BEGIN
				dbms_output.put_line (' Ningún Plato ');
			END;
		ELSE
			BEGIN
				dbms_output.put_line ('-----------------------------------------');
				dbms_output.put_line ('Total en categoría: ' || contPlatosCat);
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
			dbms_output.put_line ('ERROR: Recuperación de datos incorrecta. Nombre NO VÁLIDO.');
		WHEN PROGRAM_ERROR THEN 
			dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
		WHEN TOO_MANY_ROWS THEN 
			dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
		WHEN OTHERS THEN 
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
			dbms_output.put_line ('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
			codigoError := SQLCODE;
			mensajeError := SQLERRM;
			dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
			dbms_output.put_line (mensajeError);
	
END MENU;


------------------------------
--BLOQUE Anónimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	MENU ('pizzahud');
END;

/*
ENUNCIADO APARTADO 3
-------------------------------
3. Procedimiento almacenado llamado REVISA_PEDIDOS (sin argumentos) cuya misión es
comprobar la consistencia de los datos de todos los pedidos. El campo “precio con comisión” de la
tabla “Contiene” debe almacenar el precio del plato, comisión incluida. El campo “importe total” de
la tabla “Pedidos” debe almacenar la suma de los “precio con comisión” de los platos del pedido. El
procedimiento debe verificar y actualizar estos datos para todos los pedidos, de modo que resulten
consistentes. Si todos los datos son correctos, se mostrará un mensaje indicando “Ningún cambio en
los datos”. En caso contrario se indicará el número de filas modificadas en cada tabla. Incluye un
bloque anónimo de prueba.
*/

-----------------------------------------------------------------------------
--APARTADO 3
--Revisión de datos y modificacion, en su caso, para asegurar la consistencia
-----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE REVISA_PEDIDOS
IS
--Declaracion de variables
comisionRestaurante Restaurantes.comisión%TYPE;
precioPlato Platos.precio%TYPE;
contCambiosContiene NUMBER;
contCambiosPedidos NUMBER;
sumaPreciosFinales NUMBER;
codigoError NUMBER;
mensajeError VARCHAR2 (255);

CURSOR contenido IS SELECT restaurante, plato, pedido, unidades,
						   NVL ("precio con comisión", 0) AS "precio con comisión"
					FROM Contiene;
					
CURSOR pedido IS SELECT código, "importe total"
				 FROM Pedidos;


--Bloque del PROCEDURE
BEGIN

	--Inicializamos el contador de cambios en 'Contiene' y el de 'Pedidos'
	contCambiosContiene := 0;
	contCambiosPedidos := 0;

	--Procesamos fila a fila, la información de la tabla 'Contiene'
	--Es necesario tener almacenado el precio con comision del plato, teniendo en cuenta el número
	--de unidades pedidas. Para ello, simplemente calculamos el precio del plato en concreto
	--y lo multiplicamos por la cantidad.
	FOR conte IN contenido LOOP
		
		--Conseguimos la comisión a aplicar, según el restaurante
		SELECT comisión INTO comisionRestaurante
		FROM Restaurantes r
		WHERE r.código = conte.restaurante;
		
		--Conseguimos el precio del plato de la fila que estamos tratando
		SELECT precio INTO precioPlato
		FROM Platos p
		WHERE p.nombre = conte.plato;
		
		--Comprobamos que no se cumpla la condición. Realizamos los redondeos porque aunque la
		--cantidad obtenida se trunca sola por el tipo de finido (NUMBER (8,2)), lo que comparamos
		--son el valor almacenado y el calculado.
		IF (conte."precio con comisión") <> 
		   round (conte.unidades * round ((precioPlato * (1 + comisionRestaurante/100)), 2), 2) THEN
		 
			--Actualizamos el contenido de la tabla 'Contiene'
			UPDATE Contiene 
			SET "precio con comisión" = 
			    round (conte.unidades * round ((precioPlato * (1 + comisionRestaurante/100)), 2), 2)
			WHERE conte.plato = plato
			AND conte.pedido = pedido;
		
			--Actualizamos el contador
			contCambiosContiene := contCambiosContiene + 1;
		
		END IF;

	END LOOP;
	
	--Procesamos fila a fila, la información de la tabla Pedidos
	FOR ped IN pedido LOOP
	
		--Conseguimos la suma de los precios con comision de los platos del pedido actual
		SELECT SUM("precio con comisión") INTO sumaPreciosFinales
		FROM Contiene c
		WHERE c.pedido = ped.código;
		
		IF ((ped."importe total") <> sumaPreciosFinales) THEN
			
			--Actualizamos el importe total con la suma de los precios finales del pedido actual
			UPDATE Pedidos p SET p."importe total" = sumaPreciosFinales
			WHERE código = ped.código;
		
		
			--Actualizamos el contador
			contCambiosPedidos := contCambiosPedidos + 1;
		
		END IF;
		
	END LOOP;
	
	--Mostramos por pantalla el número de cambios realizados
	IF (contCambiosContiene = 0) AND (contCambiosPedidos = 0) THEN
		dbms_output.put_line ('Ningún cambio en los datos');
	ELSE
		dbms_output.put_line('Filas modificadas en la tabla Contiene: '||contCambiosContiene );
		dbms_output.put_line('Filas modificadas en la tabla Pedidos: '||contCambiosPedidos );
	END IF;
	
	--Excepciones
	EXCEPTION
		WHEN NO_DATA_FOUND THEN 
			dbms_output.put_line ('ERROR: Se trató de recuperar valores inexistentes');
		WHEN PROGRAM_ERROR THEN 
			dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
		WHEN TOO_MANY_ROWS THEN 
			dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
		WHEN VALUE_ERROR THEN
			dbms_output.put_line ('ERROR: Se detectó un fallo aritmético');
		WHEN ZERO_DIVIDE THEN
			dbms_output.put_line ('ERROR: Se intentó realizar una division por cero');
		WHEN OTHERS THEN 
			dbms_output.put_line ('ERROR: Problema no esperado.');
			codigoError := SQLCODE;
			mensajeError := SQLERRM;
			dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
			dbms_output.put_line (mensajeError);
		
END REVISA_PEDIDOS;


------------------------------
--BLOQUE Anónimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	REVISA_PEDIDOS;
END;

/*
ENUNCIADO APARTADO 3
-------------------------------
4. Construye un paquete llamado PRACTICA3 que incluya los subprogramas creados en los apartados
anteriores. Para probar su funcionamiento crea un bloque anónimo que unifique las pruebas de los
apartados anteriores “retocadas” para utilizar los subprogramas del paquete.
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

	--Declaración de los procedimientos públicos
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
	numeroCliente Clientes.número%TYPE;
	pisoCliente Clientes.piso%TYPE;
	localidadCliente Clientes.localidad%TYPE;
	cod_postalCliente Clientes."código postal"%TYPE;
	telfCliente Clientes.teléfono%TYPE;
	usuarioCliente Clientes.usuario%TYPE;
	contraseñaCliente Clientes.contraseña%TYPE;
	numPedidos NUMBER;
	sumaImportes NUMBER;
	DNINoValido EXCEPTION;
	codigoError NUMBER;
	mensajeError VARCHAR2 (255);

	--Con este cursor tratamos de almacenar una tabla con los pedidos del cliente,
	--para ir procesandola fila a fila
	CURSOR pedClientes IS  SELECT p.código, p.estado, p.fecha_hora_pedido, p.fecha_hora_entrega, 
								  p."importe total"
						   FROM Pedidos p, Clientes c
						   WHERE p.cliente = c.DNI
						   AND c.DNI = dni_cliente
						   ORDER BY p.fecha_hora_pedido;

	BEGIN
		--Cargamos los datos personales del cliente en sendas variables
		SELECT * INTO dniCliente, nombreCliente, apellidosCliente, calleCliente, numeroCliente, 
					  pisoCliente, localidadCliente, cod_postalCliente, telfCliente, 
					  usuarioCliente, contraseñaCliente
		FROM Clientes
		WHERE DNI = dni_cliente;

		--Mostramos los datos por pantalla
		dbms_output.put_line ('----------DATOS DEl CLIENTE----------');
		dbms_output.put_line ('DNI: ' || dniCliente);
		dbms_output.put_line ('Nombre: ' || nombreCliente);
		dbms_output.put_line ('Apellidos: ' || apellidosCliente);
		dbms_output.put_line ('Calle: ' || calleCliente);
		dbms_output.put_line ('Número: ' || numeroCliente);
		dbms_output.put_line ('Piso: ' || pisoCliente);
		dbms_output.put_line ('Localidad: ' || localidadCliente);
		dbms_output.put_line ('Código Postal: ' || cod_postalCliente);
		dbms_output.put_line ('Teléfono: ' || telfCliente);
		dbms_output.put_line ('-------------------------------------');
		dbms_output.put_line ('');
		dbms_output.put_line ('---------------PEDIDOS---------------');
			
		--Con pedido tratamos de identificar una fila de la tabla
		--Para cada fila (pedido), mostramos por pantalla sus datos
		--NOTA: Al hacer un bucle FOR...LOOP se ejecutan autoamticamente las instruciones
		--      OPEN, FETCH y CLOSE
		FOR pedido IN pedClientes LOOP
			
			dbms_output.put_line('Código: ' || pedido.código);
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
				dbms_output.put_line('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
				dbms_output.put_line('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
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
	codigoRes Restaurantes.código%TYPE;
	contPlatosTotales NUMBER;
	contPlatosCat NUMBER;
	nombreResNoValido EXCEPTION;
	codigoError NUMBER;
	mensajeError VARCHAR2 (255);

	--Con este cursor conseguimos una tabla con todas las categorías que deberemos procesar despues
	CURSOR categorias IS SELECT DISTINCT p.categoría
						 FROM Platos p
						 ORDER BY p.categoría;


	--Con este cursor tratamos de almacenar una tabla con los platos de un restaurante, 
	--ordenados por categoria, para ir procesandola fila a fila
	CURSOR platosCategorias (codRes IN Restaurantes.código%TYPE)
	IS 
		SELECT p.nombre, p.categoría, p.precio, r.comisión
		FROM Restaurantes r, Platos p
		WHERE r.código = p.restaurante
		AND p.restaurante = codRes
		ORDER BY p.nombre;

	--Bloque del PROCEDURE
	BEGIN

		--Obtenemos el código del restaurante pedido en la variable codigoRes
		SELECT r.código INTO codigoRes
		FROM Restaurantes r
		WHERE r.nombre = nombre_res;
		
		--Inicio de la impresion por pantalla
		dbms_output.put_line ('#   Restaurante: ' || nombre_res || '   #');
		dbms_output.put_line ('----------------------------------------------------');
		
		--Inicializamos un contador para llevar el numero total de platos del restaurante
		contPlatosTotales := 0;
		
		--Empezamos el procesamiento. Para cada categoría almacenada en la Base de Datos...
		FOR cat IN categorias LOOP
			
			--Escribimos el nombre de la categoría
			dbms_output.put ('--   Categoría: ' || cat.categoría || '   --');
			
			--Inicializamos un contador de platos a cero para poder mostrar el total posteriormente
			contPlatosCat := 0;
			
			--...Para cada plato asociado con el restaurante introducido...
			FOR plato IN platosCategorias (codigoRes) LOOP
			
				--Si la categoría del plato coincide con la categoría que estoy mostrando...
				IF (cat.categoría = plato.categoría) THEN
					
					--Salto de línea para que tenga el formato correcto
					dbms_output.new_line;
					
					--Actualizamos el contador
					contPlatosCat := contPlatosCat + 1;
					
					--Mostramos la informacion. La comisión es un porcentaje, y hacemos el cálculo
					dbms_output.put (plato.nombre || '  ' || plato.precio*(1 + plato.comisión/100));
					dbms_output.put_line ('  ' || '€' );
				END IF;
			
			END LOOP;
			
			--Mostramos la cuenta final de platos
			IF (contPlatosCat = 0) THEN 
				BEGIN
					dbms_output.put_line (' Ningún Plato ');
				END;
			ELSE
				BEGIN
					dbms_output.put_line ('-----------------------------------------');
					dbms_output.put_line ('Total en categoría: ' || contPlatosCat);
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
				dbms_output.put_line ('ERROR: Recuperación de datos incorrecta. Nombre NO VÁLIDO.');
			WHEN PROGRAM_ERROR THEN 
				dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
			WHEN TOO_MANY_ROWS THEN 
				dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
			WHEN OTHERS THEN 
				dbms_output.put_line ('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
				dbms_output.put_line ('ERROR: Problema no esperado. Por favor, inténtelo de nuevo');
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
	comisionRestaurante Restaurantes.comisión%TYPE;
	precioPlato Platos.precio%TYPE;
	contCambiosContiene NUMBER;
	contCambiosPedidos NUMBER;
	sumaPreciosFinales NUMBER;
	codigoError NUMBER;
	mensajeError VARCHAR2 (255);

	CURSOR contenido IS SELECT restaurante, plato, pedido, unidades,
							   NVL ("precio con comisión", 0) AS "precio con comisión"
						FROM Contiene;
						
	CURSOR pedido IS SELECT código, "importe total"
					 FROM Pedidos;


	--Bloque del PROCEDURE
	BEGIN

		--Inicializamos el contador de cambios en 'Contiene' y el de 'Pedidos'
		contCambiosContiene := 0;
		contCambiosPedidos := 0;

		--Procesamos fila a fila, la información de la tabla 'Contiene'
		--Es necesario tener almacenado el precio con comision del plato, teniendo en cuenta el 
		--número de unidades pedidas. Para ello, simplemente calculamos el precio del plato en
		--concreto y lo multiplicamos por la cantidad.
		FOR conte IN contenido LOOP
			
			--Conseguimos la comisión a aplicar, según el restaurante
			SELECT comisión INTO comisionRestaurante
			FROM Restaurantes r
			WHERE r.código = conte.restaurante;
			
			--Conseguimos el precio del plato de la fila que estamos tratando
			SELECT precio INTO precioPlato
			FROM Platos p
			WHERE p.nombre = conte.plato;
			
			--Comprobamos que no se cumpla la condición. Realizamos los redondeos porque aunque la
			--cantidad obtenida se trunca sola por el tipo de finido (NUMBER (8,2)), 
			--lo que comparamos son el valor almacenado y el calculado.
			IF (conte."precio con comisión") <> 
				round(conte.unidades*round ((precioPlato*(1 + comisionRestaurante/100)), 2), 2) THEN
			 
				--Actualizamos el contenido de la tabla 'Contiene'
				UPDATE Contiene 
				SET "precio con comisión" = 
					round (conte.unidades*round ((precioPlato*(1 + comisionRestaurante/100)), 2), 2)
				WHERE conte.plato = plato
				AND conte.pedido = pedido;
			
				--Actualizamos el contador
				contCambiosContiene := contCambiosContiene + 1;
			
			END IF;

		END LOOP;
		
		--Procesamos fila a fila, la información de la tabla Pedidos
		FOR ped IN pedido LOOP
		
			--Conseguimos la suma de los precios con comision de los platos del pedido actual
			SELECT SUM("precio con comisión") INTO sumaPreciosFinales
			FROM Contiene c
			WHERE c.pedido = ped.código;
			
			IF ((ped."importe total") <> sumaPreciosFinales) THEN
				
				--Actualizamos el importe total con la suma de los precios finales del pedido actual
				UPDATE Pedidos p SET p."importe total" = sumaPreciosFinales
				WHERE código = ped.código;
			
			
				--Actualizamos el contador
				contCambiosPedidos := contCambiosPedidos + 1;
			
			END IF;
			
		END LOOP;
		
		--Mostramos por pantalla el número de cambios realizados
		IF (contCambiosContiene = 0) AND (contCambiosPedidos = 0) THEN
			dbms_output.put_line ('Ningún cambio en los datos');
		ELSE
			dbms_output.put_line('Filas modificadas en la tabla Contiene: '||contCambiosContiene );
			dbms_output.put_line('Filas modificadas en la tabla Pedidos: '||contCambiosPedidos );
		END IF;
		
		--Excepciones
		EXCEPTION
			WHEN NO_DATA_FOUND THEN 
				dbms_output.put_line ('ERROR: Se trató de recuperar valores inexistentes');
			WHEN PROGRAM_ERROR THEN 
				dbms_output.put_line ('ERROR: Se Produjo un fallo interno al ejecutar el programa');
			WHEN TOO_MANY_ROWS THEN 
				dbms_output.put_line ('ERROR: Hay un "SELECT...INTO que devuelve mas de una fila');
			WHEN VALUE_ERROR THEN
				dbms_output.put_line ('ERROR: Se detectó un fallo aritmético');
			WHEN ZERO_DIVIDE THEN
				dbms_output.put_line ('ERROR: Se intentó realizar una division por cero');
			WHEN OTHERS THEN 
				dbms_output.put_line ('ERROR: Problema no esperado.');
				codigoError := SQLCODE;
				mensajeError := SQLERRM;
				dbms_output.put_line ('Error: ' || TO_CHAR(codigoError));
				dbms_output.put_line (mensajeError);
			
	END REVISA_PEDIDOS;
	
END PRACTICA3;


------------------------------
--BLOQUE Anónimo para probarlo
------------------------------
SET SERVEROUTPUT ON;
BEGIN
	dbms_output.put_line ('A continuación se muestran los pedidos de un cliente');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	PRACTICA3.PEDIDOS_CLIENTE ('12345678M');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('A continuación se muestra el menu de un restaurante');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	PRACTICA3.MENU ('pizzahud');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('A continuación se actualiza la información de los precios e importes');
	dbms_output.put_line ('----------------------------------------------------------------------');
	dbms_output.put_line ('----------------------------------------------------------------------');
	PRACTICA3.REVISA_PEDIDOS;
END;