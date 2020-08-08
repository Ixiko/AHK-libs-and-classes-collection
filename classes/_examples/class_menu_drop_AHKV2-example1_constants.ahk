; Constants:
global DROPEFFECT_NONE := 0 			; Drop target cannot accept the data.
global DROPEFFECT_COPY := 1 			; Drop results in a copy. The original data is untouched by the drag source.
global DROPEFFECT_MOVE := 2				; Drag source should remove the data.
global DROPEFFECT_LINK := 4 			; Drag source should create a link to the original data.
global DROPEFFECT_SCROLL := 0x80000000

global S_OK := 0