
/**
 * @name GDPR Data Processing Detection
 * @description Rileva possibili violazioni GDPR nel processing di dati personali
 * @kind problem
 * @id java/find-sql-queries
 * @problem.severity recommendation
 * @tags security
 */

import java

// Rileva metodi che processano dati personali senza controlli di consenso

from Call call, Method m
where call.getCallee() = m
  and (
    m.getName().toLowerCase().matches("%email%") or
    m.getName().toLowerCase().matches("%phone%") or
  
    m.getName().toLowerCase().matches("%personal%") or
    m.getName().toLowerCase().matches("%user%") or
    m.getName().toLowerCase().matches("%customer%")
  )
  and not exists(Call consent |
    consent.getEnclosingStmt().getBasicBlock() = call.getEnclosingStmt().getBasicBlock() and
    consent.getCallee().getName().toLowerCase().matches("%consent%")
  )
select call, "Possibile processing di dati personali senza controllo consenso GDPR"


// Obiettivo:
    // Cerca chiamate a metodi che, dal nome, sembrano trattare dati personali (es. email, phone, user).
    // Controlla che nello stesso blocco non ci sia una chiamata a un metodo che gestisce il consenso.
    // Segnala queste chiamate come potenziali violazioni GDPR.

// Limitazioni:
    // Falsi positivi?: metodi con nomi simili ma che non processano realmente dati personali.
    // Falsi negativi?: metodi che processano dati personali ma non seguono le convenzioni di naming.
    // Strumento di screening iniziale che richiede revisione manuale.

