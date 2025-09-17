
/**
 * @name Find SQL queries
 * @description Find all SQL query strings in Java code
 * @kind problem
 * @id java/find-sql-queries
 * @problem.severity recommendation
 * @tags security
 *       database
 */

import java

from StringLiteral sql
where sql.getValue().regexpMatch("(?i).*\\b(SELECT|INSERT|UPDATE|DELETE)\\b.*")
select sql, "Found SQL query: " + sql.getValue()

