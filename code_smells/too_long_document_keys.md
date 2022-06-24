# Too long document keys

## Description


<p>MongoDB automatically indexes document keys (ids). Unnecessarily long ids take space in index files in addition to the space they take in each document. A typical example is the use of UUIDs. While convenient, they can generate large index files inducing performance & space issues.
Read more <a href="https://www.tutorialfor.com/blog-198278.htm" target="_blank">here</a>.</p>


## Example


<p>Suppose the following collection:</p>

```json

{
  "users": [
    {
      "_id": "a644be96-c4a3-11ec-9d64-0242ac120002",
      "firstname": "John",
      "surname": "Doe",
      "job": "Farmer"
    },
    {
      "_id": "bef9d016-c4a3-11ec-9d64-0242ac120002",
      "firstname": "Alan",
      "surname": "Turing",
      "job": "Postdoctoral assistant"
    }
  ]
}

```

<p>One can insert a new document into this collection as follows:</p>

```js

db.users.insert({"_id": new UUID(), "firstname": "Ada", "surname": "Lovelace", "job": "Programmer"})

```


## Solution


<p>Use the native MongoDB ObjectId as a shorter alternative of UUID (see <a href="https://www.mongodb.com/docs/manual/reference/method/ObjectId/">here</a>):</p>

```json

{
  "users": [
    {
      "_id": "3ca3913d1a647164c521c033",
      "firstname": "John",
      "surname": "Doe",
      "job": "Farmer"
    },
    {
      "_id": "50a8da644a0d2e94f6e1e319",
      "firstname": "Alan",
      "surname": "Turing",
      "job": "Postdoctoral assistant"
    }
  ]
}

```

<p>One can insert a new document into this collection as follows:</p>
<pre><code>db.users.insert({"firstname": "Ada", "surname": "Lovelace", "job": "Programmer"})</code></pre>