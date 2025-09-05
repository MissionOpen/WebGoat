// by claude (Sonnet 4)

/**
 * @name Missing Tests for Critical Business Methods  
 * @description Identifica metodi business-critical senza adeguata copertura di test
 * @id java/missing-critical-method-tests
 * @kind problem
 * @tags testing
 *       coverage
 *       business-critical
 *       quality-assurance
 * @precision high
 * @problem.severity error
 */

import java

/** ————— Heuristics ————— **/

// Tipi/classi tipicamente "business"
predicate isBusinessType(RefType t) {
  t.getName().matches("%Service%") or
  t.getName().matches("%Controller%") or
  t.getName().matches("%Manager%") or
  t.getName().matches("%Handler%") or
  t.getName().matches("%Processor%") or
  t.getName().matches("%Engine%") or
  t.getName().matches("%Calculator%") or
  t.getName().matches("%Validator%") or
  t.getName().matches("%Authenticator%") or
  t.getPackage().getName().matches("%service%") or
  t.getPackage().getName().matches("%controller%") or
  t.getPackage().getName().matches("%business%") or
  t.getPackage().getName().matches("%core%") or
  t.getPackage().getName().matches("%domain%")
}

// Nomi di metodi “critici”
predicate hasCriticalVerb(Method m) {
  m.getName().matches("%process%") or
  m.getName().matches("%execute%") or
  m.getName().matches("%calculate%") or
  m.getName().matches("%validate%") or
  m.getName().matches("%authenticate%") or
  m.getName().matches("%authorize%") or
  m.getName().matches("%pay%") or
  m.getName().matches("%transfer%") or
  m.getName().matches("%order%") or
  m.getName().matches("%create%") or
  m.getName().matches("%update%") or
  m.getName().matches("%delete%") or
  m.getName().matches("%save%") or
  m.getName().matches("%send%") or
  m.getName().matches("%notify%") or
  m.getName().matches("%approve%") or
  m.getName().matches("%reject%") or
  m.getName().matches("%cancel%") or
  m.getName().matches("%confirm%")
}

// Getter/setter e simili da escludere
predicate isTrivialName(Method m) {
  m.getName().matches("get%") or
  m.getName().matches("set%") or
  m.getName().matches("is%") or
  m.getName().matches("has%") or
  m.getName().matches("to%") or
  m.getName().matches("from%")
}

// Metodo business-critical (versione robusta)
predicate isCriticalBusinessMethod(Method m) {
  m.isPublic() and
  m.fromSource() and
  isBusinessType(m.getDeclaringType()) and
  ( hasCriticalVerb(m) or m.getNumberOfParameters() >= 3 ) and
  not isTrivialName(m) and
  not m.getDeclaringType().getPackage().getName().matches("%test%") and
  not m.isPrivate()
}

/** ————— Copertura ————— **/

// Un "test" (per euristica: package o nome, o annotazione che finisce con Test)
predicate isTestMethod(Method t) {
  t.getDeclaringType().getPackage().getName().matches("%test%") or
  t.getName().matches("test%") or
  exists(Annotation a |
    a = t.getAnAnnotation() and a.getType().getName().matches("%Test")
  )
}

// Invocazioni al metodo target all'interno del test
predicate testCalls(Method test, Method target) {
  exists(MethodCall call |
    call.getEnclosingCallable() = test and
    call.getMethod() = target
  )
}

// In alternativa, un test che cita il nome del metodo e contiene un assert
predicate nameRefAndAssert(Method test, Method target) {
  test.getName().matches("%" + target.getName() + "%") and
  exists(MethodCall ac |
    ac.getEnclosingCallable() = test and
    ac.getMethod().getName().matches("assert%")
  )
}

predicate hasAdequateTestCoverage(Method critical) {
  exists(Method t | isTestMethod(t) and (testCalls(t, critical) or nameRefAndAssert(t, critical)))
}


from Method m
where isCriticalBusinessMethod(m) and not hasAdequateTestCoverage(m)
select m,
  "Critical business method '" + m.getName() +
  "' lacks adequate test coverage (in " + m.getDeclaringType().getName() + ")."
