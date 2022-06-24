# Separating data accessed together

## Description

Normalizing and splitting data into separate tables is natural in relational databases. 
However, MongoDB allows embedding documents to represent 1-1 or 1-N relationships. 
This allows better performances by avoiding the `$lookup` operator (like a join in SQL), which is slow and resource-intensive. 
Read more [here](https://www.mongodb.com/developer/article/schema-design-anti-pattern-separating-data/).

## Example

<p>Suppose the following collections:</p>

```json


{
  "countries": [
    {
      "_id": 1,
      "name": "Switzerland"
    },
    {
      "_id": 2,
      "name": "Austria"
    },
    {
      "_id": 3,
      "name": "Belgium"
    }
  ],
  "cities": [
    {
      "_id": 1,
      "name": "Bruxelles",
      "country": 3
    },
    {
      "_id": 2,
      "name": "Namur",
      "country": 3
    },
    {
      "_id": 3,
      "name": "Zurich",
      "country": 1
    },
    {
      "_id": 4,
      "name": "Vienna",
      "country": 2
    }
  ]
}

```

<p>To query the countries' cities, one needs to do a <code>$lookup</code> that would become inefficient with more data:</p>

```js

db.countries.aggregate([
  {
    "$lookup": {
      "from": "cities",
      "localField": "_id",
      "foreignField": "country",
      "as": "country_cities"
    }
  }
])

```

## Solution

The cities could be stored together with the countries as follows:

```json


[
  {
    "_id": 1,
    "name": "Switzerland",
    "cities": [
      {
        "_id": 3,
        "name": "Zurich"
      }
    ]
  },
  {
    "_id": 2,
    "name": "Austria"
    "cities": [
      {
        "_id": 4,
        "name": "Vienna"
      }
    ]
  },
  {
    "_id": 3,
    "name": "Belgium",
    "cities": [
      {
        "_id": 1,
        "name": "Bruxelles"
      },
      {
        "_id": 2,
        "name": "Namur"
      }
    ]
  }
]

```