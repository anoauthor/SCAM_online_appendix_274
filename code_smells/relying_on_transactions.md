# Relying on transactions

## Description

<p>Transactions ensure data integrity in relational databases.
MongoDB has transactions too, but relying on them is a bad design smell.
Their usage is a sign of breaking up data between multiple collections, which is against the fundamental MongoDB principle:<i> data that is accessed together should be stored together</i>.
Read more <a href="https://www.mongodb.com/developer/article/3-things-to-know-switch-from-sql-mongodb/#sql-tread-carefully-transactions" target="_blank">here</a>.</p>

## Example

<p>The following code snippet with a transaction indicates that users and their jobs are unnecessary broken to separate collections.</p>

```js


try {
  await session.withTransaction(async () => {
      const users = db.users;
      const jobs = db.jobs;
      const doc_id = await users.insertOne({"firstname": "Ada", "surname": "Lovelace"}, { session }).insertedId;
      await jobs.insertOne({"user_id": doc_id, "entitled": "Programmer"}, { session });
  });
} finally {
    await session.endSession();
    await client.close();
}

```

## Solution

<p>The job collection should be embedded into the user:</p>

```json

{
  "users": [
    {
      "_id": 1,
      "firstname": "John",
      "surname": "Doe",
      "job": "Farmer"
    },
    {
      "_id": 2,
      "firstname": "Alan",
      "surname": "Turing",
      "job": "Postdoctoral assistant"
    },
    {
      "_id": 3,
      "firstname": "Charles",
      "surname": "Babbage",
      "job": "Professor"
    }
  ]
}
```

<p>Inserting a new user can be achieved with a single operation:</p>

```js
db.users.insert({"firstname": "Ada", "surname": "Lovelace", "job": "Programmer"})
```