const conection = require('../config/connection')//requerimos la conexion a la BD 
const controller = {} //definicion de controller que guardara las rutas

//funcion de prueba
controller.test = (req,res) => {
    res.send('get routes')
}


controller.getDepartament = (req,res) =>{
    let sql =`select * from DEPARTMENT`
    conection.query(sql,(err,rows,fields) =>{
        if(err) res.send(err.sqlMessage);
        else{
            res.json(rows)
        }
    })
}

//funcion para insertar un producto
controller.postProduct = (req,res) =>{
    const {fk_id_user, fk_id_department, fk_id_product_category, fk_id_product_status, var_name, int_views, text_description, dou_price, bit_availability, publication_date, expiration_date} = req.body
    let sql=`insert into PRODUCT(fk_id_user, fk_id_department, fk_id_product_category, fk_id_product_status, var_name,
        int_views, text_description, dou_price, bit_availability, publication_date, expiration_date) 
        values(${fk_id_user},'${fk_id_department}', '${fk_id_product_category}', '${fk_id_product_status}', '${var_name}',
        '${int_views}','${text_description}',${dou_price},${bit_availability},'${publication_date}','${expiration_date}')`

    conection.query(sql,(err,rows,fields)=>{
        if(err) res.send({status: '0', id:""}); //error en consulta
    })    
        
  
      
    
}

module.exports = controller