const express = require('express')
const app = express()
const port=8080
const socket = require('socket.io-client')('https://ws-api.iextrading.com/1.0/last')
var price = 0

// Listen to the channel's messages
socket.on('message', message => price=message)

// Connect to the channel
socket.on('connect', () => {

  // Subscribe to topics (i.e. appl,fb,aig+)
  socket.emit('subscribe', 'aapl')

})

// Disconnect from the channel
socket.on('disconnect', () => console.log('Disconnected.'))

app.get('/', (req, res) => res.send(price))

app.listen(port, () => console.log(`App listening on port ${port}!`))