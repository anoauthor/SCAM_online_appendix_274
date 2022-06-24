# Use of relational collections

## Description 

<p>A <i>relational table</i> is commonly used to model N-N relationships in relational databases. A <i>relational collection</i> can be used similarly in MongoDB; however, querying such collections requires multiple <code>lookup</code> operators, which is slow and resource-intensive. 
Read more <a href="https://www.tutorialfor.com/blog-198278.htm" target="_blank">here</a>.</p>

## Example 

<p>Let's assume the following collections:</p>

```json

{
  "cars": [
    {
      "_id": 1,
      "brand": "Tesla",
      "model": "S",
      "registration": "2ret879"
    },
    {
      "_id": 2,
      "brand": "BMW",
      "model": "I3",
      "registration": "1set194"
    }
  ],
  "crashes": [
    {
      "_id": 1,
      "date": "11-02-2010",
      "localisation": "50.465744021238685, 4.857857747978128"
    },
    {
      "_id": 2,
      "date": "03-10-2000",
      "localisation": "-13.718087457969677, 29.16153083534761"
    }
  ],
  "carcrashes": [
    {
      "_id": 1,
      "crash_id": 1,
      "car_id": 2
    },
    {
      "_id": 2,
      "crash_id": 1,
      "car_id": 1
    },
    {
      "_id": 3,
      "crash_id": 2,
      "car_id": 2
    },
  ]
}

```

<p>To retrieve the crashes' information, one needs to do two <code>$lookup</code> operations as follows:</p>

```js

db.carcrashes.aggregate([
  {
    "$lookup": {
      "from": "cars",
      "localField": "car_id",
      "foreignField": "_id",
      "as": "cars"
    }
  },
  {
    "$lookup": {
      "from": "crashes",
      "localField": "crash_id",
      "foreignField": "_id",
      "as": "crashes"
    }
  }
])

```

## Solution

The M-N relationship can be represented to one of the collections as such:
```json
{
  "cars": [
    {
      "_id": 1,
      "brand": "Tesla",
      "model": "S",
      "registration": "2ret879"
    },
    {
      "_id": 2,
      "brand": "BMW",
      "model": "I3",
      "registration": "1set194"
    }
  ],
  "crashes": [
    {
      "_id": 1,
      "date": "11-02-2010",
      "localisation": "50.465744021238685, 4.857857747978128",
      "cars_implicated": ["1", "2"]
    },
    {
      "_id": 2,
      "date": "03-10-2000",
      "localisation": "-13.718087457969677, 29.16153083534761",
      "cars_implicated": ["2"]
    }
  ]
}

```