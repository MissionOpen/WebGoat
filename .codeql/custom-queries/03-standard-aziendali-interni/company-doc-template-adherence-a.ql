// by copilot (GPT 5 mini)

/**
 * @name Company documentation template adherence (Javadoc)
 * @description Find public classes and public methods that do not follow required company Javadoc template (missing required tags/sections).
 * @kind problem
 * @id java/doc-template-adherence
 * @problem.severity warning
 * @tags documentation
 *       style
 */

import java

from Documentable element
where (
    // Classi pubbliche
    (element instanceof Class and 
     element.(Class).isPublic() and 
     element.(Class).fromSource()) 
    or 
    // Metodi pubblici (non costruttori)
    (element instanceof Method and 
     element.(Method).isPublic() and 
     element.(Method).getName() != element.(Method).getDeclaringType().getName() and
     element.(Method).fromSource())
  )
  and not exists(Javadoc jd | 
    jd.getCommentedElement() = element and
    jd.toString().regexpMatch(".*@companytemplate.*")and 
    jd.toString().regexpMatch(".*@companytemplate.*") and 
    jd.toString().regexpMatch(".*Component:.*")and 
    jd.toString().regexpMatch(".*Owner:.*")
  )
select element, "Public element does not conform to company Javadoc template.",
"Location: " + element.getLocation().toString(),
"File: " + element.getFile().toString(),
"Riga: " +element.getLocation().getStartLine().toString()
