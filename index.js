///const express = require('express')
//const app = express()
const port = 8080
const socket = require('socket.io-client')('https://ws-api.iextrading.com/1.0/last')
var admin = require('./FirebaseFunctions/node_modules/firebase-admin');

var symbols = []

var serviceAccount = require("//home/niclas_joswig/Stock-Alarm/stock-alarm-27fd9-firebase-adminsdk-ckcdi-05ef23eac1.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://stock-alarm-27fd9.firebaseio.com"
});

//var registrationToken = 'cXa_Yqmcp3I:APA91bFfTY6jsxbeZ-C9eClN4JOPQSsxPKxJn5iPPSR2A1HcJ-hXVjoB2TVnI0rsFvPUJS_rYMKtafYAKyn1cpZm3AhGk4TdeXqd01dATZgUuaoiwSWRg3-ixKKfN3QCv6H8eG9nUv0W';

//dummy data
//Alarms = [new Alarm('AAPL', 260.0, "John", "id1"), new Alarm('GOOGL', 150, "Sarah","id2")]
symbols = 'AAPL'
last_prices = { 'AAPL': 259, 'GOOGL': 210, 'IBM': 120 }

class Alarm {
    constructor(symbol, level, owner, alarmId, creationDate) {
        this.symbol = symbol;
        this.level = level;
        this.owner = owner;  //needed for push notification
        this.id = alarmId;
        this.creationDate=creationDate;
    }
    toString() {
        return "  Symbol: " + this.symbol + ", Price of Alarm: " + this.level;
    }
    toJSON() {
        return {
            "symbol": this.symbol,
            "level": this.level,
            "owner": this.owner,
            "id": this.id,
            "creationDate": this.creationDate,
        }
    }
}



function notifyUser(symbol, owner, alarmId_) {
    var token

    var db = admin.database();
    var ref = db.ref("Users").child(owner).child("token").once("value", (snapshot) => {
        token = snapshot.val()
    }).then((_) => {
        var message = {  //TODO look into firebase messaging options
            notification: { title: symbol},
            data: {
                alarmId: alarmId_,
            },
            token: token
        };
        admin.messaging().send(message)
            .then((response) => {
                // Response is a message ID string.
                console.log('Successfully sent message:', response);
            })
            .catch((error) => {
                console.log('Error sending message:', error);
            });
    }).catch((error)=> console.log("notify error"))
}

var db = admin.database();
function moveAlarm(alarm) { //TODO Debug
    promise1= db.ref("Alarms").child(alarm.symbol).child(alarm.id).remove()
    promise2= db.ref("Users").child(alarm.owner).child("Alarms").child(alarm.id).remove()
    promise3= db.ref("Users").child(alarm.owner).child("PastAlarms").child(alarm.id).set(
        alarm.toJSON())
        promise4= db.ref("Users").child(alarm.owner).child("PastAlarms").child(alarm.id).update(
        {"triggerDate":(new Date).getTime()})
        Promise.all([promise1,promise2,promise3]).catch((error)=>{
            console.log("set error")
            console.log(error)
        })
}

async function checkAlarms(data) {
    noAlarms=false
    Alarms = []
    updateSymbol = data['symbol']
    price = data['price']
    console.log("price start:     " + price + ", symbol: " + updateSymbol)
    //console.log("last price start:   " + last_prices[updateSymbol])

    await db.ref("Alarms").child(updateSymbol).once("value").then((snapshot) => {
        console.log("snapshot val")
        console.log(snapshot.val())
        if (snapshot.val() == null) { throw 'No Alarms'}
        //here catch all promises and return them to outer promise (promise.all)
        snapshot.forEach(function(childSnapshot) {
            console.log(childSnapshot.val().creationDate)
            var alarm = childSnapshot.val()
            Alarms.push(new Alarm(alarm.symbol, alarm.level, alarm.owner, alarm.id,alarm.creationDate))
        })
        console.log(Alarms[0].creationDate)
    }).catch((reason) => {
        console.log("No Alarms for symbol:" + updateSymbol)
        noAlarms=true
    })

if(!noAlarms){
    console.log(Alarms.length)

    for (i = 0; i < Alarms.length;) {
        console.log(Alarms[i].creationDate)
        console.log("past for schleife")
        if (Alarms[i].level < last_prices[updateSymbol]) {
            if (Alarms[i].level >= price) {
                console.log("ALARM")
                console.log(updateSymbol)
                console.log("price:  " + price)
                console.log("last price:   " + last_prices[updateSymbol])
                console.log("Alarm level:    " + Alarms[i].level)
                notifyUser(updateSymbol, Alarms[i].owner, Alarms[i].id)
                moveAlarm(Alarms[i])
                Alarms.splice(i, 1)
            }
            else {
                i++
            }
        }
        else {
            if (Alarms[i].level <= data['price']) {
               
                console.log("ALARM")
                console.log(updateSymbol)
                console.log("price:  " + price)
                console.log("last price:   " + last_prices[updateSymbol])
                console.log("Alarm level:    " + Alarms[i].level)
                notifyUser(updateSymbol, Alarms[i].owner, Alarms[i].id)
                moveAlarm(Alarms[i])
                Alarms.splice(i, 1)
            }
            else {
                i++
            }
        }

    }
}
    last_prices[updateSymbol] = price

}

//todo: http get function for receiving alarm from the user

function addAlarm(symbol, level, direction, owner, alarmId, creationDate) {
    Alarms.push(new Alarm(symbol, level, owner, alarmId, creationDate))
}

socket.on('message', message => {
    decoded = JSON.parse(message);
    checkAlarms(decoded);
})

socket.on('connect', () => {
    socket.emit('subscribe', symbols = symbols)
})

socket.on('disconnect', () => console.log('Disconnected.'))
