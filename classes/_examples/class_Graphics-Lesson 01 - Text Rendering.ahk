; Lesson 01 - Text Rendering
; -----------
; Shows how to display text on the screen using an interactive version of TextRender().

#include <Graphics>

text := "There are so many different notions of “space” that one might despair of finding any common thread tying them together. However, one property shared by many notions of space is that they can be “background” structure. For instance, many kinds of algebraic objects, such as groups, rings, lattices, Boolean algebras, etc., often come with “extra space structure” that is respected by all their operations. In the case of groups, we have topological groups, Lie groups, sheaves of groups, ∞-groups, and so on."

text2 := "
(LTrim
There are so many different notions of “space” that one might despair of finding
any common thread tying them together. However, one property shared by many
notions of space is that they can be “background” structure. For instance, many
kinds of algebraic objects, such as groups, rings, lattices, Boolean algebras, etc.,
often come with “extra space structure” that is respected by all their operations.
In the case of groups, we have topological groups, Lie groups, sheaves of groups,
∞-groups, and so on.
)"

;RenderTextI(text, "time:5seconds width:700px", "justify:center")

; Long version.
g := RenderText(text, "time:15seconds width:700px", "justify:center")
g := new Graphics.Interactive(g)

; Fully customizable version.
g := new Graphics.TextRenderer
g := new Graphics.Interactive(g)
g.Render(text, "time:15seconds width:700px", "justify:center")


+F1:: Reload
Esc:: ExitApp
