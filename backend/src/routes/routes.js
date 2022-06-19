const routers = require('express').Router()
const customerU = require('../controllers/customerUser')
const customerA = require('../controllers/customerAdmin')

//we assign the routers
 
routers.get('/userTest', customerU.test)
routers.get('/adminTest', customerA.test)

module.exports = routers