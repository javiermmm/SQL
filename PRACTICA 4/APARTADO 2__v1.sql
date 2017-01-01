CREATE OR REPLACE TRIGGER control_pedidos_restaurantes
	BEFORE INSERT OR UPDATE OF Restaurante ON Contiene
	FOR EACH ROW
DECLARE
	rest Contiene.Restaurante%TYPE;
BEGIN
	SELECT Restaurante INTO REST
	FROM Contiene c
	WHERE c.pedido = :NEW.pedido
	GROUP BY PEDIDO, Restaurante;		
	
	IF (rest <> :NEW.Restaurante) THEN		
			RAISE_APPLICATION_ERROR 
					(-20000, 'ERROR: UN PEDIDO SOLO PUEDE CONTENER PLATOS DE UN MISMO RESTAURANTE');		
	END IF;	
END control_pedidos_restaurantes;