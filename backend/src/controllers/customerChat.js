const conection = require('../config/connection')//requerimos la conexion a la BD
const controller = {} //definicion de controller que guardara las rutas

let userList = new Map();

controller.newChat = (req,res) => {
    const {fk_id_product, fk_id_user_buyer, fk_id_user_seller} = req.body

    let sql1 = `SELECT * FROM PRODUCT WHERE id_product = ${fk_id_product}`
    let sql2 = `SELECT * FROM USER WHERE id_user = ${fk_id_user_buyer}`
    let sql3 = `SELECT * FROM USER WHERE id_user = ${fk_id_user_seller}`
    let sql4 = `SELECT * FROM CHAT WHERE fk_id_product = ${fk_id_product} AND fk_id_user_buyer = ${fk_id_user_buyer} AND fk_id_user_seller = ${fk_id_user_seller};`
    let sql = `INSERT INTO CHAT (fk_id_product, fk_id_user_buyer, fk_id_user_seller) 
        VALUES(${fk_id_product},${fk_id_user_buyer},${fk_id_user_seller})`

    conection.query(sql1,(err,rows,fields)=>{ // Comprueba si existe el producto
        if(err){
            res.json({status:'1',msg: err.sqlMessage})
        }else{
            if(rows.length!=0){ 
                conection.query(sql2,(err,rows,fields)=>{ // Comprueba si existe el usuario comprador
                    if(err){
                        res.json({status:'2',msg: err.sqlMessage})
                    }else{
                        if(rows.length!=0){
                            if(rows.length!=0){
                                conection.query(sql3,(err,rows,fields)=>{ // Comprueba si existe el usuario vendedor
                                    if(err){
                                        res.json({status:'3',msg: err.sqlMessage})
                                    }else{
                                        if(rows.length!=0){

                                            conection.query(sql4,(err,rows,fields)=>{ // Comprueba si ya existe ese chat
                                                if(err){
                                                    res.json({status:'4',msg: err.sqlMessage})
                                                }else{
                                                    if(rows.length!=0){
                                                        res.json({status:'200',msg: "Ya existe este chat"})

                                                    }else{
                                                        conection.query(sql,(err,rows,fields)=>{
                                                            if(err){
                                                                res.json({status:'4',msg: err.sqlMessage})
                                                            }else{
                                                                res.json({status:'200',msg: "El nuevo chat vacio ha sido creado"})
                                                            }
                                                        })
                                                    }
                                                }

                                            })            
                            
                                        }else{
                                            res.json({status:'0',msg:'El usuario vendedor no se encuentra'})
                                        }
                            
                                    }
                            
                                })
            
                            }else{
                                res.json({status:'0',msg:'El usuario comprador no se encuentra'})
                            }
            
                        }
            
                    }
                })

            }else{
                res.json({status:'0',msg:'El producto no se encuetra'})
            }

        }

    })

}

controller.getChats = (req,res) => {
    const{id_user}=req.params

    let sql = `SELECT * FROM USER WHERE id_user = ${id_user}`
    let sql1 = `SELECT USER.var_name AS Vendedor, PRODUCT.id_product, PRODUCT.var_name AS Producto, CHAT.id_chat, PHOTOGRAPHS.var_name AS Foto
        FROM (((CHAT INNER JOIN PRODUCT ON PRODUCT.id_product = CHAT.fk_id_product)
        INNER JOIN PHOTOGRAPHS ON PHOTOGRAPHS.fk_id_product = PRODUCT.id_product)
        INNER JOIN USER ON USER.id_user = CHAT.fk_id_user_seller)
        WHERE CHAT.fk_id_user_buyer = ${id_user}
        GROUP BY product.id_product`

    conection.query(sql,(err,rows,fields)=>{ // Comprueba si existe el usuario
        if(err){
            res.json({status:'1',msg: err.sqlMessage})
        }else{
            if(rows.length!=0){
                conection.query(sql1,(err,rows,fields)=>{ // Trae el nombre del vendedor, id del producto, nombre del producto, id del chat, 
                 
                    res.json({status:'200',msg: rows})

                })
              
            }else{
                res.json({status:'0',msg:'No se encontro el usuario'})
            }

        }

    })

}

// Traer el ultimo mensaje y cantidad de no leidos
controller.getlastMessage = (req,res) => {
    const{id_chat}=req.params
    let sql = `SELECT text_contents AS ultimo_mensaje FROM MESSAGE WHERE fk_id_chat=${id_chat} ORDER BY MESSAGE.id_message DESC LIMIT 1;`
    let sql1 = `SELECT COUNT(*) no_leidos FROM MESSAGE WHERE MESSAGE.fk_id_chat = ${id_chat} AND MESSAGE.bit_status = 0`
    conection.query(sql,(err,rows,fields)=>{
        if(err){
            res.json({status:'2',msg: err.sqlMessage})
        }else{
            if(rows.length!=0){
                conection.query(sql1,(err,rows2,fields)=>{
                    if(err){
                        res.json({status:'3',msg: err.sqlMessage})
                    }else{
                        console.log(rows2[0].no_leidos)
                        res.json({"ultimo_mensaje":rows[0].ultimo_mensaje, "no_leidos":rows2[0].no_leidos})
                    }
                })
            }else{
                res.json({status:'0',msg: "No hay mensajes en este chat"})
            }
            
        }
    })
    
}


//exportacion de controler
module.exports = controller