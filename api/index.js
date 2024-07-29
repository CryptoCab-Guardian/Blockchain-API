const express = require('express')
const cors = require('cors')
const morgan = require('morgan')

require('dotenv').config()


const { router: mainContractRouter } = require('../router/main.route')


const app = express()

app.use(cors({ origin: '*' }))
app.use(express.json())
app.use(morgan('tiny'))



app.use('/api/v1/main', mainContractRouter)




const port = process.env.PORT || 3000
app.listen(port, () => {
    console.log(`Server PORT -> ${port}`)
})