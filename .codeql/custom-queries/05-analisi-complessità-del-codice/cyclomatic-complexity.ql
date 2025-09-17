// by copilot (GPT 5 mini)

/**
 * @name Cyclomatic Complexity Too High
 * @description Find Java methods with cyclomatic complexity greater than 10
 * @kind problem
 * @id java/high-cyclomatic-complexity
 * @problem.severity warning
 * @tags maintainability
 *       complexity
 */

import java

// Predicate per identificare statement che contribuiscono alla complessità ciclomatica
predicate isDecisionPoint(Stmt s) {
  s instanceof IfStmt or
  s instanceof ForStmt or
  s instanceof WhileStmt or
  s instanceof DoStmt or
  s instanceof SwitchCase or
  s instanceof CatchClause
}

// Calcola la complessità ciclomatica di un metodo
int cyclomaticComplexity(Method m) {
  // Complessità ciclomatica = 1 + numero di punti di decisione
  result = 1 + count(Stmt s | s.getEnclosingCallable() = m and isDecisionPoint(s)) +
           count(ConditionalExpr ce | ce.getEnclosingCallable() = m)
}

from Method m
where m.fromSource() 
  and cyclomaticComplexity(m) > 10
select m, "Method has high cyclomatic complexity: " + cyclomaticComplexity(m) + 
          " (threshold: 10). Consider refactoring."


