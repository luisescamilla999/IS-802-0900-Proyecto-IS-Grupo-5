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

-- Producto Almacenado 
delimiter //
create  procedure vistaProduc(id int)
BEGIN
update PRODUCT set int_views=(PRODUCT.int_views)+1 where id_product=id; 
end//

## LISTAR COMENTARIOS
DELIMITER &&
CREATE PROCEDURE obtenerComentarios(IN id int)
BEGIN
     SELECT user.var_name, user.var_lastname, commentary.text_contents, date_format(tim_date,'%d/%m/%Y') as dateComment,time_format(tim_date,'%H:%i')  as hourComment
		FROM commentary 
		INNER JOIN user ON user.id_user=commentary.fk_id_user
		WHERE commentary.fk_id_product = id ORDER BY commentary.tim_date DESC;
END&&
##PROMEDIO DE CALIFICACION
DELIMITER &&
CREATE PROCEDURE prom(IN id int)
BEGIN
    SELECT CAST(AVG(tin_score)  AS DECIMAL(10,1)) AS PROMEDIO FROM qualification WHERE fk_id_user_qualified=id;
END&&


-- Producto Almacenado Lista de mensajes
drop procedure if exists listMessage;
delimiter //
create  procedure listMessage(id int,idUser int)
BEGIN
 UPDATE MESSAGE SET bit_status=1 WHERE fk_id_chat = id AND fk_id_user=idUser;
 SELECT date_format(tim_date,'%d/%m/%Y') as dateMessenge,time_format(tim_date,'%H:%i') as hourMessenge, if(bit_status=0,0,1) as bit_status, text_contents, fk_id_user FROM MESSAGE where fk_id_chat=id order by tim_date asc; 
end//

-- call listMessage(4,1);

-- Otra forma de listar mensajes
/*
delimiter //
create  procedure listMessage2(id int,id2 int)
BEGIN
 SELECT*FROM MESSAGE where fk_id_chat=id and fk_id_user=id2  order by tim_date asc; 
end//

call listMessage2(4,3);
*/


-- Funcion para crear un chat vacio
drop procedure if exists sp_newChat;
delimiter $$
create procedure sp_newChat(id_product BIGINT UNSIGNED, id_user_buyer BIGINT UNSIGNED, id_user_seller BIGINT UNSIGNED)
BEGIN
	DECLARE id BIGINT UNSIGNED;
    DECLARE status TINYINT UNSIGNED;

	SELECT id_chat INTO id FROM CHAT WHERE fk_id_product = id_product AND fk_id_user_buyer = id_user_buyer AND fk_id_user_seller = id_user_seller;
	
    IF id THEN
		SELECT 202 INTO status; 
		SELECT id AS id_chat, status;
    ELSE
		INSERT INTO CHAT (modification_date, fk_id_product, fk_id_user_buyer, fk_id_user_seller) 
			VALUES(CURRENT_TIMESTAMP(),id_product,id_user_buyer,id_user_seller);
		
        SELECT 200 INTO status;
		SELECT last_insert_id() AS id_chat, status;
    END IF;
	
end$$

-- CALL sp_newChat(101, 1, 3);

-- Mensaje nuevo
drop procedure if exists sp_sendMessage;
delimiter $$
create procedure sp_sendMessage(contents TEXT, id_chat BIGINT UNSIGNED, id_user BIGINT UNSIGNED)
BEGIN
	INSERT INTO MESSAGE(tim_date, bit_status, text_contents, fk_id_chat, fk_id_user) 
		VALUES(CURRENT_TIMESTAMP() ,0 , contents, id_chat, id_user);
	UPDATE CHAT SET modification_date = CURRENT_TIMESTAMP() WHERE CHAT.id_chat = id_chat;
	SELECT date_format(tim_date,'%d/%m/%Y') as dateMessenge,time_format(tim_date,'%H:%i') as hourMessenge,if(bit_status=0,0,1) as bit_status, text_contents, fk_id_user FROM MESSAGE where fk_id_chat=id_chat order by tim_date asc;

end$$

DROP FUNCTION IF EXISTS fn_evaluateName;
delimiter $$
CREATE FUNCTION fn_evaluateName(user_id BIGINT UNSIGNED, buyer_id BIGINT UNSIGNED, seller_id BIGINT UNSIGNED)
	RETURNS VARCHAR(50)
BEGIN
	DECLARE user_name VARCHAR(50);
	IF user_id = buyer_id THEN
		SELECT CONCAT(var_name,' ',var_lastname) INTO user_name FROM USER WHERE id_user = seller_id;
		RETURN user_name;
    ELSE
		SELECT CONCAT(var_name,' ',var_lastname) INTO user_name FROM USER WHERE id_user = buyer_id;
		RETURN user_name;
	END IF;
END$$

DROP FUNCTION IF EXISTS fn_unread_messages;
delimiter $$
CREATE FUNCTION fn_unread_messages(id_chat BIGINT UNSIGNED, id_user BIGINT UNSIGNED)
	RETURNS INTEGER
BEGIN
	DECLARE unread_messages INTEGER;
	SELECT COUNT(*) INTO unread_messages FROM MESSAGE WHERE fk_id_chat = id_chat AND bit_status = 0 AND fk_id_user != id_user;
    RETURN unread_messages;
END$$

DROP FUNCTION IF EXISTS fn_last_message;
delimiter $$
CREATE FUNCTION fn_last_message(id_chat BIGINT UNSIGNED)
	RETURNS TEXT
BEGIN
	DECLARE last_message TEXT;
    SELECT text_contents INTO last_message FROM MESSAGE WHERE fk_id_chat=id_chat ORDER BY MESSAGE.id_message DESC LIMIT 1;
    RETURN last_message;

END$$

DROP FUNCTION IF EXISTS fn_determineRole;
delimiter $$
CREATE FUNCTION fn_determineRole(user_id BIGINT UNSIGNED, buyer_id BIGINT UNSIGNED, seller_id BIGINT UNSIGNED)
	RETURNS VARCHAR(10)
BEGIN
	DECLARE user_rol VARCHAR(10);
	IF user_id = buyer_id THEN
		SELECT "Vendedor" INTO user_rol;
		RETURN user_rol;
    ELSE
		SELECT "Cliente" INTO user_rol;
		RETURN user_rol;
	END IF;
END$$

-- Traer datos de los chats
drop procedure if exists sp_chatData;
delimiter $$
create procedure sp_chatData(id BIGINT UNSIGNED)
BEGIN
	SELECT CHAT.id_chat,(SELECT user.var_name FROM USER where id_user = CHAT.fk_id_user_buyer) AS fk_id_user_buyer,
    (SELECT user.var_name FROM USER where id_user = CHAT.fk_id_user_seller) AS fk_id_user_seller, fn_unread_messages(CHAT.id_chat, USER.id_user) AS no_leidos, fn_last_message(CHAT.id_chat) AS ultimo_mensaje, fn_determineRole(USER.id_user, CHAT.fk_id_user_seller, CHAT.fk_id_user_buyer) AS Rol ,
	fn_evaluateName(USER.id_user, CHAT.fk_id_user_seller, CHAT.fk_id_user_buyer) AS Nombre, CHAT.fk_id_user_buyer AS id_comprador, CHAT.fk_id_user_seller AS id_vendedor,
	CHAT.fk_id_product, PRODUCT.var_name AS Producto, PHOTOGRAPHS.var_name AS Foto
	FROM USER
    INNER JOIN CHAT ON USER.id_user = CHAT.fk_id_user_seller OR USER.id_user = CHAT.fk_id_user_buyer
    INNER JOIN PRODUCT ON PRODUCT.id_product = CHAT.fk_id_product
    INNER JOIN PHOTOGRAPHS ON PHOTOGRAPHS.fk_id_product = PRODUCT.id_product
    where USER.id_user = id
    GROUP BY product.id_product order by CHAT.modification_date DESC;
end$$

-- Obtener tiempo de expiración de anuncios
DROP FUNCTION IF EXISTS fn_getExpiryTime;
delimiter $$
CREATE FUNCTION fn_getExpiryTime()
		RETURNS SMALLINT
	BEGIN
		RETURN (SELECT expiration_period FROM INFORMATION LIMIT 1);
END$$


-- Actualizar el tiempo de expiración de anuncios
DROP PROCEDURE IF EXISTS sp_updateExpiryTime;
delimiter $$
CREATE PROCEDURE sp_updateExpiryTime(days SMALLINT)
BEGIN
	UPDATE PRODUCT SET expiration_date = DATE_ADD(publication_date, interval days day);
	UPDATE INFORMATION SET expiration_period=days;
END$$

SET SQL_SAFE_UPDATES = 1;

--

-- SELECT COUNT(*) FROM QUALIFICATION WHERE (fk_id_user_review = 4 AND fk_id_user_qualified = 5);
DROP PROCEDURE IF EXISTS sp_rateUser;
delimiter $$
CREATE PROCEDURE sp_rateUser(customer BIGINT UNSIGNED, seller BIGINT UNSIGNED, score TINYINT)
BEGIN
	DECLARE existQualification TINYINT;
    SELECT COUNT(*) INTO existQualification FROM QUALIFICATION WHERE fk_id_user_review = customer AND fk_id_user_qualified = seller;
    
	IF existQualification = 0 THEN
		INSERT INTO QUALIFICATION(fk_id_user_review,fk_id_user_qualified,tin_score) VALUES(customer, seller, score);
        SELECT "Nueva calificación agregada" AS msg;
    ELSE
        UPDATE QUALIFICATION SET tin_score = score WHERE fk_id_user_review = customer AND fk_id_user_qualified = seller;
        SELECT "Calificación actualizada" AS msg;
    END IF;
END$$

-- Procedimiento para obtener si un chat cumple los requisitos de mostrar las calificaciones
DROP FUNCTION IF EXISTS fn_isQualifying;
DELIMITER $$
CREATE FUNCTION fn_isQualifying(chat BIGINT UNSIGNED)
	RETURNS TINYINT
BEGIN
	DECLARE customer INT UNSIGNED;
    DECLARE seller INT UNSIGNED;
    DECLARE countCustomer INT UNSIGNED;
    DECLARE countSeller INT UNSIGNED;

	SELECT fk_id_user_buyer, fk_id_user_seller INTO customer,seller FROM CHAT WHERE id_chat = chat;
    
	SELECT COUNT(*) INTO countCustomer FROM MESSAGE WHERE fk_id_user = customer AND fk_id_chat = chat;
    SELECT COUNT(*) INTO countSeller FROM MESSAGE WHERE fk_id_user = seller AND fk_id_chat = chat;
    IF countCustomer > 2 AND countSeller > 2 THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
END $$

##BORRAR IMAGENES EN EDICION DE PRODUCTO

DELIMITER //
CREATE PROCEDURE deletePhotos(IN nombre VARCHAR(200))
BEGIN
	DELETE p.* FROM photographs p WHERE id_photographs IN
		(SELECT id_photographs FROM 
				(SELECT id_photographs FROM photographs WHERE var_name=nombre)x);
END //


delimiter //
create  procedure listDenuncias12(id int)
BEGIN
 SELECT*FROM COMPLAINT where fk_id_user_complaining=id order by tim_date asc;
end//

#Actualizar Cat. de los productos a indefinida 
DELIMITER //
CREATE PROCEDURE UpdateCategory(IN id bigint)
BEGIN
	UPDATE product SET fk_id_product_category=
			(SELECT id_product_category FROM 
					(SELECT  id_product_category FROM product_category WHERE var_name="Indefinida")x) 
	WHERE fk_id_product_category= id;
END//

/*
--Listado de denuncias por usuario por id
delimiter //
create  procedure ListadoUsuarios(id int)
BEGIN
select * from user
where exists (select * from complaint
where fk_id_user=id_user)
and id_user= id;
end//
*/
/*
DROP PROCEDURE IF EXISTS eliminarDenuncia;
delimiter //
create  procedure eliminarDenuncia(id int)
BEGIN
 DELETE FROM complaint where id_COMPLAINT=id; 
end//
*/

delimiter //
create  procedure verifiacionVisitas()
BEGIN
    DECLARE amount tinyint;
    DECLARE amountViews bigint;
	select count(*) into amount from VIEWS
		where date_views=current_date();
    select amount_views into amountViews from VIEWS
		where date_views=current_date();
    IF amount = 0 THEN
		INSERT INTO VIEWS VALUES(1,current_date());
	ELSE 
		UPDATE VIEWS SET amount_views=amountViews+1 WHERE date_views=current_date() ;
	END IF;
end//


delimiter //
CREATE FUNCTION Estado_usuario(user_id BIGINT UNSIGNED)
	RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE estado int;
	select bit_status into estado from user 
    where id_user=user_id;
    return estado;
END//



delimiter &&
CREATE FUNCTION fn_Denuncia(id_user BIGINT UNSIGNED)
	RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE NumeroDenuncias int;
	select count(fk_id_user_complaining) into NumeroDenuncias  from complaint
     where exists (select * from user
     where id_user=fk_id_user_complaining
     group by id_user);
	return NumeroDenuncias;
END &&




delimiter //
create  procedure listUsuarioDenuncia(id int)
BEGIN
select COMPLAINT.id_COMPLAINT,complaint_category.var_name as NombreCategoria , user.var_name as NombreUsuario,USER.var_lastname as SegundoNombre ,COMPLAINT.text_description as Descripcion,
COMPLAINT.tim_date ,date_format(tim_date,'%d/%m/%Y') as dateComplaint ,time_format(tim_date,'%H:%i') 
as hourComplaint, user.bit_status from COMPLAINT inner join user on 
 COMPLAINT.fk_id_user_complaining=user.id_user inner join complaint_category on
 complaint_category.id_complaint_category=COMPLAINT.fk_id_complaint_category
 where COMPLAINT.fk_id_user_complaining=id;
end//

-- call listUsuarioDenuncia(5)
select * from user;
select user.bit_status from user inner join COMPLAINT;
select * from COMPLAINT

-- call listUsuarioDenuncia()


delimiter //
create  procedure ListadoUsuarioNumDenu1()
BEGIN
select fk_id_user,count(fk_id_user) As NumeroDenuncias from complaint
group by fk_id_user;
end//

-- call ListadoUsuarioNumDenu1();


-- Eliminar Denuncias
DROP PROCEDURE IF EXISTS eliminarDenuncia;
delimiter //
create  procedure eliminarDenuncia(id int)
BEGIN
 DELETE FROM complaint where id_COMPLAINT=id; 
end//


delimiter //
create  procedure modificarEstado(id int)
BEGIN
update user set bit_status=0 where id_user=id; 
end//

-- call modificarEstado(6);
-- select*from user;
-- select *from 


create  procedure ListadoUsuarios()
BEGIN
select id_user,var_name,var_lastname, fn_Denuncia(id_user) AS Denuncias1 from user as U
where  fn_Denuncia(id_user)>0 and Estado_usuario( U.id_user)=1 and U.bit_rol=1;
end//

