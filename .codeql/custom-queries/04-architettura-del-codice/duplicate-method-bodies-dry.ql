// by copilot (GPT 5 mini)

/**
 * @name Duplicate Method Bodies (DRY Violation Detection)
 * @description Find pairs of methods that have identical bodies and violate DRY principle
 * @kind problem
 * @id java/duplicate-method-bodies
 * @problem.severity warning
 * @tags maintainability
 *       duplication
 *       dry-principle
 */

import java

// Predicate per definire il numero minimo di statement
int minimalStatements() { result = 6 }

// Predicate per contare gli statement in un metodo
int stmtCount(Method m) {
  result = count(Stmt s | s.getEnclosingCallable() = m)
}

from Method m1, Method m2
where
  m1 != m2 and
  m1.fromSource() and m2.fromSource() and
  exists(m1.getBody()) and exists(m2.getBody()) and
  stmtCount(m1) >= minimalStatements() and 
  stmtCount(m2) >= minimalStatements() and
  m1.getBody().toString() = m2.getBody().toString() and
  (
    // Metodi in classi diverse o file diversi
    m1.getDeclaringType() != m2.getDeclaringType() or
    m1.getFile() != m2.getFile()
  ) and
  // Evita duplicati nella selezione (solo m1 < m2 lessicograficamente)
  m1.getQualifiedName() < m2.getQualifiedName()
select m1, "Duplicate method body detected. Method '" + m1.getName() + 
           "' in " + m1.getDeclaringType().getName() + 
           " has identical body to '" + m2.getName() + 
           "' in " + m2.getDeclaringType().getName()