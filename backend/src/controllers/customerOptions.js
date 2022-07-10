const conection = require('../config/connection')//requerimos la conexion a la BD 
const controller = {} //definicion de controller que guardara las rutas
const fs= require('fs')
const path = require('path')

const multer = require('multer')

const diskstorage = multer.diskStorage({
    destination: path.join(__dirname, './images'),
    filename: (req, file, cb) => {
        cb(null, Date.now() + '-plazitanet-' + file.originalname)
    }
})

const fileUpload = multer({
    storage: diskstorage
}).single('image')

controller.postImage = (req,res) =>{
    req.getConnection((err, conn) => {
        if(err) return res.status(500).send('server error')

        const type = req.file.mimetype
        const name = req.file.originalname
        const extension = req.file.type
        const data = fs.readFileSync(path.join(__dirname, '../images/' + req.file.filename))

        let sql= `INSERT INTO photographs(blob_file, var_name, var_extension, fk_id_product)
            VALUES(${data},${name},${extension},1)`

        conection.query(sql, (err, rows) => {
            if(err) return res.status(500).send('server error')

            res.send('200')
        })
    })


}

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

//funcion para insertar un producto /// Sin las imagenes
controller.postProduct = (req,res) =>{
    const {fk_id_user, fk_id_department, fk_id_product_category, fk_id_product_status, var_name, text_description, dou_price, bit_availability} = req.body
    let sql=`insert into PRODUCT(fk_id_user, fk_id_department, fk_id_product_category, fk_id_product_status, var_name,
        int_views, text_description, dou_price, bit_availability, publication_date, expiration_date) 
        values(${fk_id_user},${fk_id_department}, ${fk_id_product_category}, ${fk_id_product_status}, '${var_name}',
        0,'${text_description}',${dou_price},${bit_availability},CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`
    
        console.log(sql)
    conection.query(sql,(err,rows,fields)=>{
        if(err){ res.send({status: '0', id:""})
            console.log(err)
        } //error en consulta
        else{
            res.json({status: '200'}) // Consulta correcta retorna el id del producto
        }
    })    
}

controller.productFiltering = (req,res) =>{
    const{fk_id_department,fk_id_product_category,dou_price}=req.body
    let sql1 = `SELECT DISTINCT(product.id_product),photographs.id_photographs,photographs.blob_file,fk_id_user,fk_id_department,var_name,text_description,dou_price,publication_date`
        + ` from product, photographs where `
    if(fk_id_department!="") sql1 += `fk_id_department = ${fk_id_department} AND `
    if(fk_id_product_category!="")  sql1 += `fk_id_product_category=${fk_id_product_category} AND `
    if(dou_price!="") sql1 +=  `dou_price <= ${dou_price} AND `
    sql1 += `photographs.fk_id_product=product.id_product AND bit_availability = 1 ORDER BY publication_date DESC`

    conection.query(sql1,(err,rows,fields)=>{
        if(err) res.json(err);//posible error en consulta
        else{
            const imgdirDelete = fs.readdirSync(path.join(__dirname,'../dbimagesProducts/'))//trae las imagenes guardadas en el servidor
            imgdirDelete.map(img=>{
                fs.unlinkSync(path.join(__dirname,'../dbimagesProducts/'+img))//las elimina, si es que hay imagenes
            })
            rows.map(images=>{
                fs.writeFileSync(path.join(__dirname,'../dbimagesProducts/'+images.id_product+"-"+"image.jpeg"),images.blob_file)//trae las imagenes de la base de datos
                images.blob_file = images.id_product+"-"+"image.jpeg"
            })
            //const imgdir = fs.readdirSync(path.join(__dirname,'../dbimagesProducts/'))//crea un arreglo con el  nombre de las mismas
            res.json(rows)//todo salio bien
            }
        })
}

/*
{
    "fk_id_department":"",
    "fk_id_product_category":"",
    "dou_price":""
}
*/
module.exports = controller