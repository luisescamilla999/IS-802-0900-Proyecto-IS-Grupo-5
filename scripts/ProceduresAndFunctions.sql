use plazitanet;
SET GLOBAL log_bin_trust_function_creators = 1; #Para la creacion de finciones deterministas

#funcion que crea un codigo aleatorio dato un tamaño 
DELIMITER $$
CREATE FUNCTION `RandString`(length SMALLINT(3)) RETURNS varchar(100) CHARSET UTF8MB4
begin
    SET @returnStr = '';
    SET @allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopkrstuwxyz';
    SET @i = 0;

    WHILE (@i < length) DO
        SET @returnStr = CONCAT(@returnStr, substring(@allowedChars, FLOOR(Rand() * LENGTH(@allowedChars) + 1), 1));
        SET @i = @i + 1;
    END WHILE;

    RETURN @returnStr;
END$$

#Procedimiento almacenado que actualiza el codigo en la tabla User
DELIMITER $$
create procedure createCode (email_user VARCHAR(100))
BEGIN
    UPDATE user SET var_code = (SELECT RandString(7)) where  var_email = email_user;
	select * from user where var_email = email_user;
END$$

#ejemplo de uso del procedimiento
#Call createCode("joseK@gmail.com");

--Producto Almacenado 
delimiter //
create  procedure vistaProduc(id int)
BEGIN
update PRODUCT set int_views=(PRODUCT.int_views)+1 where id_product=id; 
end//

#DROP PROCEDURE IF EXISTS vistaProduc; 
#call vistaProduc(9); 

--Producto Almacenado Lista de mensajes
delimiter //
create  procedure listMessage(id int)
BEGIN
 SELECT*FROM MESSAGE where fk_id_chat=id order by tim_date asc; 
end//

call listMessage(4);

--Otra forma de listar mensajes
/*
delimiter //
create  procedure listMessage2(id int,id2 int)
BEGIN
 SELECT*FROM MESSAGE where fk_id_chat=id and fk_id_user=id2  order by tim_date asc; 
end//

call listMessage2(4,3);
*/