#include <Subtitle>

a := new Subtitle()

white := {"x":150, "y":225, "w":"800px", "h":"88px", "color":"White"}
black := {"x":275, "y":0, "w":"10px", "h":"100%", "color":"Black"}
red := {"x":100, "y":275, "w":600, "h":60, "color":"DC2A1C"}
yellow := {"x":250, "y":150, "w":"150px", "h":"150px", "radius":"75px", "color":"F9C72A"}
blue := {"anchor":"bottomleft", "x":475, "y":275, "w":"20px", "h":"60px", "color":"012D96"}


a.Draw("", white)
a.Draw("", black)
a.Draw("", red)
a.Draw("", yellow)
a.Draw("", blue)
a.Draw("bauhaus","aTopleft x575 y275 h200 cGreen", "ybottom f(Bahnschrift Light) size75 colorBlack")
a.Render()
a.Save()