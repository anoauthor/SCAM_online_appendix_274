# Abusive use of indexes

## Description

<p>Indexes in MongoDB are powerful and necessary to improve query performance, but their maintenance requires resources. Too many unnecessary indexes can take too much storage and increase CPU usage.

Read more <a href="https://www.mongodb.com/developer/article/schema-design-anti-pattern-unnecessary-indexes/" target="_blank">here</a>.</p>

## Example

<p>Suppose a collection with several attributes where each attribute has an index; however, the collection is searched through only a few attributes.</p>

## Solution

<p>Remove the indices of the attributes which are not used to search for documents in the collection.</p>