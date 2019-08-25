const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

const drunkVal = 400;
const delayTime = 1000*60;

//exports.senNoti= functions.database.ref('driver/{dID}/alcoholVal').onUpdate((change, context) => {
//    const dID = context.params.dID;
//    const alcoVal = change.after.val();
//    const curTime = new Date();
//
//    admin.database().ref("/driver/" + dID).once('value').then((snapshot) => {
//        var lastNotiTime = snapshot.child('lastNotiTime').val();
//        var tripID = snapshot.child('tripCode').val();
//        console.log(curTime.getTime() - lastNotiTime);
//
//        if(alcoVal >= drunkVal && (curTime.getTime() - lastNotiTime)>= delayTime) {
//                var msg = {
//                        notification: {
//                            title: 'Vượt mức chỉ số cồn',
//                            body: 'Tài xế ' + dID + ' có dấu hiệu vượt mức nồng độ cồn',
//                        },
//                        data : {
//                            'lastNotiTime' : lastNotiTime.toString(),
//                            'dID' : dID.toString(),
//                            'tripID' : tripID.toString()
//                        }
//                    }
//                admin.messaging().sendToTopic('alcoholTracking', msg).then((response) => {
//                    console.log("Success", response);
//                    lastNotiTime = curTime.getTime();
//                    admin.database().ref("/driver/" + dID).update({lastNotiTime});
//                })
//                .catch((error) => {
//                    console.log("Error", error);
//                    return false;
//                });
//            }
//            else{
//                console.log('still in delay')
//            }
////        console.log(snapshot.child('tripCode').val());
//    });
//
//    return true;
//
//});

const db = admin.firestore();

exports.sendNoti = functions.database.ref('driver/{dID}/alcoholVal').onUpdate((change, context) => {
    const dID = context.params.dID;
    const alcoVal = change.after.val();
    const curTime = new Date();

    admin.database().ref("/driver/" + dID).once('value').then((snapshot) => {
            var lastNotiTime = snapshot.child('lastNotiTime').val();
            var tripID = snapshot.child('tripCode').val();
            console.log(curTime.getTime() - lastNotiTime);

            if(alcoVal >= drunkVal && (curTime.getTime() - lastNotiTime)>= delayTime) {
                    var msg = {
                            notification: {
                                title: 'Vượt mức chỉ số cồn',
                                body: 'Tài xế ' + dID + ' có dấu hiệu vượt mức nồng độ cồn',
                            },
                            data : {
                                'lastNotiTime' : lastNotiTime.toString(),
                                'dID' : dID.toString(),
                                'tripID' : tripID.toString()
                            }
                        }
                    admin.messaging().sendToTopic('alcoholTracking', msg).then((response) => {
                        console.log("Success", response);
                        lastNotiTime = curTime.getTime();
                        admin.database().ref("/driver/" + dID).update({lastNotiTime});

                    })
                    .catch((error) => {
                        console.log("Error", error);
                        return false;
                    });
                }
                else{
                    console.log('still in delay')
                }
    //        console.log(snapshot.child('tripCode').val());
        });

    return true;
});


exports.logNoti = functions.database.ref('driver/{dID}/lastNotiTime').onUpdate((change, context) => {
//    console.log('?????');
    const dID = context.params.dID;
    const lastNotiTime = change.after.val();
//    const child = change.after.val()['lastNotiTime'];



    var doc = db.collection('bnotification').doc(dID+lastNotiTime);
    return doc
          .set({
            body: "Tài xế " + dID + " có dấu hiệu vượt mức nồng độ cồn",
            dID : dID,
            isTapped: false,
            timeCreated: lastNotiTime.toString(),
//            tripID: "HT0003"
          })
          .then(() => {
            return { result: 'document updated' };
          })
          .catch(function(error) {
            console.error("Error writing document: ", error);
           });
    }
);