// by claude (Sonnet 4)

/**
 * @name Empty Catch Block Detection
 * @description Rileva blocchi catch vuoti che potrebbero nascondere errori importanti
 * @kind problem
 * @id java/empty-catch-block
 * @problem.severity warning
 * @tags maintainability
 *       error-handling
 * @autofix
 */

import java

import semmle.code.java.Autofix

from CatchClause cc
where 
  cc.getBlock().getNumStmt() = 0 and
  not exists(Stmt s | s.getParent() = cc.getBlock()) and
  not cc.getVariable().getType().(RefType).hasQualifiedName("java.lang", "InterruptedException")
select cc, "Blocco catch vuoto - potrebbe nascondere errori importanti",
  Autofix::insertAfter(cc.getBlock(), "System.err.println(\"Exception caught: \" + " + cc.getVariable().getName() + ");")

