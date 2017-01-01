CREATE OR REPLACE TRIGGER control_pedidos_restaurantes
	BEFORE INSERT OR UPDATE OF Restaurante ON Contiene
	FOR EACH ROW
DECLARE
	numRestaurantes INTEGER;
	rest Contiene.Restaurante%TYPE;
	CURSOR contenido IS SELECT (COUNT (DISTINCT Restaurante)) AS numRestaurantes, Restaurante
						FROM Contiene c
						WHERE c.pedido = :NEW.pedido
						GROUP BY Restaurante;	
BEGIN
	IF INSERTING THEN
		FOR conte IN contenido LOOP
			IF (conte.numRestaurantes > 1) OR (conte.Restaurante <> :NEW.Restaurante) THEN
				RAISE_APPLICATION_ERROR 
						(-20000, 'ERROR: UN PEDIDO SOLO PUEDE CONTENER PLATOS DE UN MISMO RESTAURANTE');			
			END IF;			
		END LOOP;	
	ELSE --UPDATING		
		RAISE_APPLICATION_ERROR 
					(-20000, 'ERROR: UN PEDIDO SOLO PUEDE CONTENER PLATOS DE UN MISMO RESTAURANTE');		
	END IF;
END control_pedidos_restaurantes;