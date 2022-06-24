/**
 * @name mongodb driver used in this project
 * @id driverDetection
 * @kind problem
 * @description Checks if the project uses mongodb native driver or mongoose
 */
predicate testFile(File f) {
    //Jasmine test files
    f.getAbsolutePath().matches("%.spec.%") or 
    f.getAbsolutePath().matches("%test%")
}

import javascript
import drivers
from Import i
where 
    not(testFile(i.getFile())) and
    mongoDriver(i.getImportedPath().getValue())
select i, i.getImportedPath().toString()