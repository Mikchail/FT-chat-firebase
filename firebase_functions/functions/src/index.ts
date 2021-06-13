import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const CONVERSATIONS = "Conversations";
const USERS = "Users";

export const onConversationCreated = functions.firestore
  .document(`${CONVERSATIONS}/{chatID}`)
  .onCreate((snapshot, context) => {
    const data = snapshot.data();
    const chatID = context.params.chatID;
    const usersColections = admin.firestore().collection(USERS);
    if (data) {
      const members = data.members;
      for (let i = 0; i < members.length; i++) {
        const currentUserID = members[i];
        const remainingUserIDs = members.filter((u: string) => u !== currentUserID);
        remainingUserIDs.forEach((m: string) => {
          return usersColections.doc(m).get().then((_doc) => {
            const userData = _doc.data();
            if (userData) {
              return usersColections.doc(currentUserID).collection(CONVERSATIONS).doc(m)
                .create({
                  "chatID": chatID,
                  "image": userData.image,
                  "name": userData.name,
                  "unseenCount": 1
                });
            }
            return null;
          }).catch(() => { return null; })
        });
      }
    }
    return null;
  });

export const onConversationUpdated = functions.firestore
  .document(`${CONVERSATIONS}/{chatID}`)
  .onUpdate((change, context) => {
    const data = change?.after.data();
    if (data) {
      const members = data.members;
      const lastMessage = data.messages[data.messages.length - 1];
      for (let i = 0; i < members.length; i++) {
        const currentUserID = members[i];
        const remainingUserIDs = members.filter((u: string) => u !== currentUserID);
        remainingUserIDs.forEach((m: string) => {
          return admin.firestore()
            .collection(USERS)
            .doc(currentUserID)
            .collection(CONVERSATIONS)
            .doc(m)
            .update({
              "lastMessage": lastMessage.message,
              "timestamp": lastMessage.timestamp,
              "unseenCount": admin.firestore.FieldValue.increment(1)
            });
        });
      }
    }
    return null;
  });