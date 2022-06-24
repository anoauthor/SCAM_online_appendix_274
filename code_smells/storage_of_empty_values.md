# Storage of empty values

## Description

<p>One of the main advantages of MongoDB is schema flexibility. As there is no fixed structure for a document inside a collection, it is not necessary to store an empty value (null, undefined, "") if a document does not possess this attribute. It could take unnecessary disk space as there are <code>exists</code> operators checking the existence of a field
Read more <a href="https://stackoverflow.com/questions/12403240/storing-null-vs-not-storing-the-key-at-all-in-mongodb" target="_blank">here</a>, <a href="https://www.mongodb.com/community/forums/t/not-including-fields-vs-storing-fields-with-a-null-value/8028" target="_blank">here</a> and <a href="https://www.linkedin.com/pulse/big-data-anti-patterns-marc-kenig/" target="_blank">here</a>.</p>

## Example

```js

db.users.insert({"firstname": "John", "surname": "Doe", "age": null})
```

## Solution

The empty age field can be omitted:
```js
db.users.insert({"firstname": "John", "surname": "Doe"})
```