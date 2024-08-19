import express from 'express'
import cors from 'cors'
import morgan from 'morgan'
import dotenv from 'dotenv'

dotenv.config()


import mainContractRouter from './router/main.route'


const app = express()

app.use(cors({ origin: '*' }))
app.use(express.json())
app.use(morgan('tiny'))



app.use('/api/v1/main', mainContractRouter)




const port = process.env.PORT || 3000
app.listen(port, () => {
    console.log(`Server PORT -> ${port}`)
})