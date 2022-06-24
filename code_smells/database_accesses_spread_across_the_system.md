# Database accesses spread across the system

## Description

<p>Implementing database communication with the DAO or Repository pattern is a good practice. When the implementation does not follow a proper design and database accesses are spread across the system, it can significantly degrade maintainability. A change to a collection must be propagated to the source code, which becomes even riskier when multiple files have to be modified.</p>

## Example

<p>Suppose a project with a few collections where the queries are spread across various files in the project.</p>


## Solution

<p>Implement a DAO for each collection and move the queries to the DAO classes.</p>