// by claude (Sonnet 4)

/**
 * @name Empty Catch Block Detection
 * @description Rileva blocchi catch vuoti che potrebbero nascondere errori importanti
 * @kind problem
 * @id java/empty-catch-block
 * @problem.severity warning
 * @tags maintainability
 *       error-handling
 */

import java

from CatchClause cc
where 
  // Il blocco catch è vuoto (non contiene statement)
  cc.getBlock().getNumStmt() = 0 and
  
  // Oppure contiene solo commenti (blocco con solo whitespace/commenti)
  not exists(Stmt s | s.getParent() = cc.getBlock()) and
  
  // Esclude catch di InterruptedException (spesso legittimo lasciarli vuoti)
  not cc.getVariable().getType().(RefType).hasQualifiedName("java.lang", "InterruptedException")

select cc, "Blocco catch vuoto - potrebbe nascondere errori importanti"

