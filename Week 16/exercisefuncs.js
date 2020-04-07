db.tweet.aggregate([
    {
        $group: {
            _id: { lang: "$user.lang" },
            count: { $sum: 1 }
        }
    },
    {
        $sort: {
            count: -1
        }
    },
    { $limit: 10 }
]);


db.tweets.aggregate([
    { $unwind: '$entities.hashtags' },

    {
        $group: {
            _id: '$entities.hashtags.text',
            tagCount: { $sum: 1 }
        }
    },

    {
        $sort: {
            tagCount: -1
        }
    },

    { $limit: 5 }
]);
