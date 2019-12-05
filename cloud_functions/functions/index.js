const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

const drunkVal = 0.03;
const delayTime = 1000*60;


exports.processNoti = functions.database.ref('driver/{dID}/notiInfo/alcoholVal').onUpdate((change, context) => {
    const dID = context.params.dID;
    const alcoVal = change.after.val();
    const curTime = new Date();

    admin.database().ref("/driver/" + dID).once('value').then((snapshot) => {
            var lastNotiTime = snapshot.child('notiInfo/lastNotiTime').val();
            if(lastNotiTime==null) {
                lastNotiTime = 0;
            }
            var curTripID = snapshot.child('tID').val();
            console.log(curTime.getTime() - lastNotiTime);

            if(alcoVal >= drunkVal && (curTime.getTime() - lastNotiTime)>= delayTime) {
                    var msg = {
                            notification: {
                                title: 'Vượt mức chỉ số cồn',
                                body: 'Tài xế ' + dID + ' có dấu hiệu vượt mức nồng độ cồn',
                            },
                            data : {
                                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                'dID' : dID.toString(),
                                'tripID' : curTripID.toString()
                            }
                        }
                    //send noti
                    lastNotiTime = curTime.getTime();
                    admin.messaging().sendToTopic('alcoholTracking', msg).then((response) => {
                        console.log("Success", response);
                        admin.database().ref("/driver/" + dID).update({lastNotiTime});
                    })
                    .catch((error) => {
                        console.log("Error", error);
                        return false;
                    });

                    //log noti
                    var notiID = dID+lastNotiTime;
                    admin.database().ref("/bnotification/" + notiID).set({
                        body: "Tài xế " + dID + " có dấu hiệu vượt mức nồng độ cồn",
                        dID : dID,
                        isSolved: false,
                        timeCreated: lastNotiTime,
                        tripID: curTripID
                    })
                }
                else{
                    console.log('still in delay')
                }
        });

    return true;
});