const express = require('express')
const path = require('path')
const OSC = require('osc-js')

// Instantiate express app
const app = express()

app.use(express.static('public'))

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, '/public/index.html'))
})

// OSC framework
const options = { send: { port: 12345 } }
const osc = new OSC({ plugin: new OSC.DatagramPlugin(options) })
osc.open({ port: 9001 }) // bind socket to localhost:9000

// Import and intialize ws server instance on express
const wsServer = require('express-ws')(app)

// Callback function that get's executed when a new socket is intialized/connects
function handleWs(ws){
    console.log('New user connected: ' + ws)
    
    // When a user disconnects, remove it from the users array and inform all the clients in the network
    function endUser() {
        
    }
    // This callback is triggered everytime a new message is received
    function messageReceived(m){ 
        // Parse de data to json
        const data = JSON.parse(m)
        console.log(data)
        const message = new OSC.Message(data.address, data.args.toString())
        osc.send(message)
    }
    // Attach callbacks to the socket as soon it gets connected
    ws.on('message', messageReceived)
    ws.on('close', endUser)
}

// Server init
const port = process.env.PORT || 3000
app.listen(port, function(){
    console.log('Server listening on port ' + port)
})

// Sockets init
app.ws('/', handleWs)