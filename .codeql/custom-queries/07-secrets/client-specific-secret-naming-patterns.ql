// by chat-gpt (GPT 5)

/**
 * @name Client-specific secret naming patterns
 * @description Rileva variabili o campi in Java che hanno nomi sospetti (keyword, passphrase, pin, ecc.)
 * @kind problem
 * @id java/client-secret-variants
 * @problem.severity warning
 * @tags security
 *       secret
 */

import java

// Predicato: definisce i pattern che identificano potenziali segreti
predicate isSecretName(Variable v) {
  v.getName().toLowerCase().matches("%password%") or
  v.getName().toLowerCase().matches("%keyword%") or
  v.getName().toLowerCase().matches("%passphrase%") or
  v.getName().toLowerCase().matches("%pin%") or
  v.getName().toLowerCase().matches("%secret%") or
  v.getName().toLowerCase().matches("%token%") or
  v.getName().toLowerCase().matches("%auth%") or
  v.getName().toLowerCase().matches("%signature%") or
  v.getName().toLowerCase().matches("%credential%") or
  v.getName().toLowerCase().matches("%private%") or
  v.getName().toLowerCase().matches("%personal%") or
  v.getName().toLowerCase().matches("%pwd%")
}

// Predicato per ottenere un messaggio diverso a seconda del tipo di variabile
string secretMessage(Variable v) {
  result = "Possibile secret hardcoded in campo: " + v.getName()
    and v instanceof Field
  or
  result = "Possibile secret hardcoded in variabile locale: " + v.getName()
    and v instanceof LocalVariableDecl
  or
  result = "Possibile secret hardcoded in parametro: " + v.getName()
    and v instanceof Parameter
}

// Query principale
from Variable v
where isSecretName(v)
  and v.getType() instanceof RefType
  and v.getType().(RefType).hasQualifiedName("java.lang", "String")
select v, secretMessage(v)
