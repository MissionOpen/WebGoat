// by copilot (GPT 5 mini)

/**
 * @name Company documentation template adherence (Javadoc)
 * @description Find public classes and public methods that do not follow required company Javadoc template (missing required tags/sections).
 * @kind problem
 * @id java/doc-template-adherence
 * @problem.severity warning
 * @tags documentation
 *       style
 *
 * Notes:
 * - Configure requiredDocFragments with the strings (or regex fragments) that must appear in the Javadoc header according to your company template
 *   (for example: "Component:", "Owner:", "API:", "@since", "@deprecated", etc).
 * - This query heuristically checks Javadoc text exposed by the CodeQL model. If your template is maintained as Markdown files,
 *   consider adding a separate query that inspects repository Markdown files under docs/ or the template repository.
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
select element, "Public element does not conform to company Javadoc template."