// by claude (Sonnet 4)

/**
 * @name Company Documentation Template Adherence
 * @description Verifica che classi e metodi pubblici seguano il template Javadoc aziendale
 * @id java/javadoc-template-adherence  
 * @kind problem
 * @tags documentation
 *       style
 *       compliance
 * @precision high
 * @problem.severity warning
 */

import java

// Predicate per verificare se il Javadoc contiene tutti i frammenti richiesti
predicate satisfiesTemplate(Javadoc jd) {
  // Verifica presenza di tutti i componenti richiesti del template aziendale
  jd.toString().regexpMatch(".*Component:.*") and
  jd.toString().regexpMatch(".*Owner:.*") and
  jd.toString().regexpMatch(".*@since:.*") and
  jd.toString().regexpMatch(".*@author:.*")
}

// Predicate per identificare elementi che dovrebbero avere documentazione
predicate requiresDocumentation(Element element) {
  (
    // Classi pubbliche (esclude classi di test e inner classes anonime)
    element instanceof Class and
    element.(Class).isPublic() and
    
    not element.(Class).getPackage().getName().matches("%test%") and
    not element.(Class).isAnonymous()
  ) or (
    // Metodi pubblici (esclude getter/setter, costruttori, override)
    element instanceof Method and
    element.(Method).isPublic() and
    element.(Method).getName() != element.(Method).getDeclaringType().getName() and
    not element.(Method).getName().matches("%(get|set|is|has)%") and
    not exists(element.(Method).getAnAnnotation()) and
    not element.(Method).getDeclaringType().getPackage().getName().matches("%test%")
  )
}

from Element element
where 
  requiresDocumentation(element) and
  (
    // Nessuna documentazione
    not exists(Javadoc jd | jd.getCommentedElement() = element) or
    // Documentazione che non rispetta il template
    not exists(Javadoc jd | jd.getCommentedElement() = element and satisfiesTemplate(jd))
  )
select element, "Missing or incomplete company Javadoc template. Required: Component, Owner, @since, @author"
