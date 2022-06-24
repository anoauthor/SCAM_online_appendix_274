# Human readable values

## Descriptions

<p>It can be tempting to store data in human readable formats, but when optimized alternatives exist, they are often more efficient and require less storage space.</p>

## Examples

<p>Suppose the following collection:</p>

```js

{
  "users": [
    {
      "_id": 1,
      "firstname": "John",
      "surname": "Doe",
      "birthdate": "January 01, 2000"
    },
    {
      "_id": 2,
      "firstname": "Alan",
      "surname": "Turing",
      "birthdate": "June 23, 1912"
    }
  ]
}

```

## Solutions

The <code>birthdate</code> could be replaced with a native date type of MongoDB:

```js

{
  "users": [
    {
      "_id": 1,
      "firstname": "John",
      "surname": "Doe",
      "birthdate": ISODate(“2000-01-01T00:00:00Z”)
    },
    {
      "_id": 2,
      "firstname": "Alan",
      "surname": "Turing",
      "birthdate": ISODate(“1912-06-23T00:00:00Z”)
    }
  ]
}

```