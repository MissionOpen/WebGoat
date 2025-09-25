/**
 * @name Insecure TrustManager that accepts all certificates
 * @description Detects custom TrustManager implementations that accept all certificates without validation.
 * @kind problem
 * @id java/insecure-trustmanager
 * @problem.severity error
 * @tags security
 *       certificates
 */

import java
import java.Class
import java.Method
import java.Expr
import java.DataFlow::PathGraph

class InsecureTrustManager extends Class {
  InsecureTrustManager() {
    this.getASupertype*().hasQualifiedName("javax.net.ssl", "X509TrustManager")
  }
}

from InsecureTrustManager tm, Method m
where
  m.getDeclaringType() = tm and
  m.getName() = "checkServerTrusted" and
  m.getNumberOfParameters() = 2 and
  m.getBody() instanceof Block and
  m.getBody().getNumStmt() = 0 // Empty method body (accepts all certs)
select m, "This TrustManager accepts all certificates without validation. This is insecure."