// by claude (Sonnet 4)

/**
 * @name Resource Leak Detection
 * @description Rileva potenziali memory/resource leak per risorse non chiuse
 * @kind problem
 * @id java/resource-leak-detection
 * @problem.severity warning
 */

import java

from MethodCall ma, Method m, Variable v
where 
  // Trova creazioni di risorse che dovrebbero essere chiuse
  ma.getMethod() = m and
  (m.getDeclaringType().hasQualifiedName("java.io", "FileInputStream") or
   m.getDeclaringType().hasQualifiedName("java.io", "FileOutputStream") or
   m.getDeclaringType().hasQualifiedName("java.sql", "Connection") or
   m.getDeclaringType().hasQualifiedName("java.net", "Socket")) and
  m.getName() = ["<init>", "createStatement", "prepareStatement"] and
  
  // La risorsa è assegnata a una variabile
exists(LocalVariableDeclExpr decl | 
  decl.getInit() = ma and
  decl.getVariable() = v) and
  
  // Non esiste una chiamata a close() per questa variabile
  not exists(MethodCall close |
    close.getQualifier() = v.getAnAccess() and
    close.getMethod().getName() = "close") and
    
  // E non è usata in un try-with-resources
not exists(TryStmt try | 
  try.getAResourceVariable() = v)
    
select ma, "Risorsa " + m.getDeclaringType().getName() + " potenzialmente non chiusa correttamente"
