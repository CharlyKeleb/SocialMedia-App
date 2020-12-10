const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreateFollower
    (async (snapshot, context) => {
        console.log("Follower Created", snapshot.data());
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        //create followed user posts reference
        const followedUserPostsRef = admin.firestore()
            .collection('posts').doc(userId)
            .collection('userPosts');

        //create following user feeds reference
        const feedsPostsRef = admin.firestore()
            .collection('feeds')
            .doc(followerId)
            .collection('feedsPost');

        //get the followed user feeds posts
        const querySnapshot = await followedUserPostsRef.get();

        //add user posts to following user feeds
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                feedsPostsRef.doc(postId).set(postData);
            }
        })
    });
