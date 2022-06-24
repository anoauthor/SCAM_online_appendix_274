# Too long attribute name

## Description


<p>Meaningful names are important, but too long attribute names have storage overhead in BSON.
Read more <a href="https://www.linkedin.com/pulse/big-data-anti-patterns-marc-kenig/" target="_blank">here</a>.</p>


## Example


<p>Suppose the following collection:</p>

```json
{
  "books": [
    {
      "_id": 1,
      "international_standard_book_number": 9780140817744,
      "author": "George Orwell",
      "title": "1984",
    },
    {
      "_id": 2,
      "international_standard_book_number": 9780631120001,
      "author": "Ludwig Wittgenstein",
      "title": "On certainty",
    }    
  ]
}
```


## Solution


The <code>international_standard_book_number</code> attribute name can be shortened to <code>isbn</code>:

```json


{
  "books": [
    {
      "_id": 1,
      "isbn": 9780140817744,
      "author": "George Orwell",
      "title": "1984",
    },
    {
      "_id": 2,
      "isbn": 9780631120001,
      "author": "Ludwig Wittgenstein",
      "title": "On certainty",
    }
  ]
}

```