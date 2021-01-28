/*Text Overlay library v1.11a for AutoHotkey_L (15th of June, 2011).

Description: The functions of this library can be used to capture strings and coordinates of on-screen text, to overlay graphical effects on the on-screen text and to navigate within the on-screen text.

Thanks to tic (Tariq Porter) for his GDI+ Library
http://www.autohotkey.com/forum/viewtopic.php?t=32238

Thanks to Lexikos for AutoHotkey_L (especially the object support)

Distributed under the Simplified BSD License.

Copyright 2011 Tommi Nieminen. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY TOMMI NIEMINEN ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOMMI NIEMINEN OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Tommi Nieminen. 

*/

/*Instructions

This library works by converting a group of characters belonging to a font into
a binary search tree, where every level represents a pixel. On-screen text can
be recognized by traversing the search tree according to the pixels of the
on-screen text. The coordinates of the strings can be simultaneously captured.

Step 1: Find out what fonts and font sizes are used in the on-screen text you wish to capture
(by copying the text into Word, for instance).

Step 2:  Generate search trees for each required font, font size and font style.
This is done using the TO_GenerateTree function. The function takes as arguments
a string of characters to be included in the search tree (generally alphanumeric
characters plus common punctuation), a font style string (of the form
"Arial|10|Regular") and a hashmap of search trees, with line heights as keys
(initialize this hashmap first as an empty object).

Step 3: Capture a bitmap of the on-screen text to be recognized. The bitmap should
contain only characters and background of the same colour as the global variable
backgroundcolour.

Step 4: Find the rows of the bitmap which only contain pixels of the background
colour by using the TO_FindGaps function. The arguments are the bitmap from step 3,
background colour as an ARGB value and an array of rows which are known to not be
empty (if no such array exists, just pass an empty object as the argument).

Step 5: Identify the lines of text within the bitmap. This is done with the
TO_FindLines function. The arguments are the bitmap from step 3, the
hashmap of search trees, array of rows which are known to not be empty and can be
skipped, an array of gaps returned by step 4 and background colour as an ARGB value. 

Step 6: Parse the bitmap using the TO_DivideAndParse function. The arguments are the
bitmap from step 3, the hashmap of search trees, an array of lines returned in step 5,
the width of a space in pixels and an array of rows which are known to not be empty
and can be skipped.

TO_DivideAndParse returns an array of the words the bitmap contains and their
coordinates.

Optional steps:

Step 7: Create a navigation net of the word boxes with the TO_GenerateMatchnet
function, which takes a word coordinate array as an argument (this is usually
the processed output of the TO_DivideAndParse function). The generated net
is an hashmap where each element of the word coordinate array has a key. Each key
has as its value another hashmap, which contains four keys (up, down, right, left).
These keys have as their values the key of the nearest word box in each direction.
This way it's easy to implement a navigation system for the words.

Step 8: Overlay boxes on the retrieved text by using TO_DrawWords function. The
arguments are an array of word coordinates, the coordinates of the window from
which the text was captured and the key of the selected word box (this is used with
the navigation net).

*/

TO_GenerateTree(charstring,fontinfo,forest)
{
    ;Initialize the pixeltree
    fontlines := TO_GetFontlines(fontinfo)
    pixeltree := Object()
    Loop,parse,charstring
    {
        ;Create a character bitmap for each character
        pBitmap := TO_CreateCharBitmap(A_LoopField,fontinfo)
        ;Crop the character bitmap to fit the line height of the font
        pCroppedBitmap := TO_CropCharBitmap(pBitmap,fontlines)
        ;Remove the uncropped bitmap
        Gdip_DisposeImage(pBitmap)
        ;Get the pixelpath of the cropped bitmap
        pixelpath := TO_GetPixelpath(pCroppedBitmap)
        ;Add the pixelpath to the pixeltree
        pixeltree := TO_AddToPaths(pixelpath,pixeltree,A_LoopField)
        ;test the addition by trying to parse the cropped bitmap
        ;test := TO_ParseBitmap(pCroppedBitmap,pixeltree,10,Object())
        ;TO_RecursiveDebug(test)
        ;if (test[1]["word"] != A_LoopField)
        ;msgbox %A_LoopField% parsed as %test%
        ;Remove the cropped bitmap
        Gdip_DisposeImage(pCroppedBitmap)
         
    }
    ;add the empty path
    emptypath := TO_EmptyColumnPath(fontlines["descent"]+1)
    pixeltree := TO_AddToPaths(emptypath,pixeltree,"empty")
    key := fontlines["descent"]+1
    forest.Insert(key,pixeltree)
    /*
    ;Add fused characters to the pixeltree
    ;make a compact tree for parsing
    compacttree := TO_CompactPixeltree(pixeltree)
    Loop,parse,charstring
    {
        firstchar := A_LoopField
        Loop,parse,charstring
        {
            fused := firstchar . A_LoopField
            pBitmap := TO_CreateCharBitmap(fused,fontinfo)
            pBitmap := TO_CropCharBitmap(pBitmap,fontlines)
            test := TO_ParseBitmap(pBitmap,pixeltree)
            if (test[1]["word"] != fused)
            {
                pixelpath := TO_GetPixelpath(pBitmap)
                pixeltree := TO_AddToPaths(pixelpath,pixeltree,fused)
            }
            
        }
    }
    */
    return forest
}

TO_FindColHorizontal(pBitmap,x,y,findcol)
{
    Loop
    {
        col := Gdip_GetPixel(pBitmap,x,y)
        if (col = 0)
        {
            return
        }
        if (col = findcol)
        {
            return Object("x",x,"y",y)
        }
        x += 1
    }
}

TO_FindNotColHorizontal(pBitmap,x,y,findcol)
{
    Loop
    {
        col := Gdip_GetPixel(pBitmap,x,y)
        if (col = 0)
        {
            return
        }
        if (col != findcol)
        {
            return Object("x",x,"y",y)
        }
        x += 1
    }
}

TO_FindColVertical(pBitmap,x,y,findcol)
{
    Loop
    {
        col := Gdip_GetPixel(pBitmap,x,y)
        if (col = 0)
        {
            return
        }
        if (col = findcol)
        {
            return Object("x",x,"y",y)
        }
        y += 1
    }
}

TO_FindNotColVertical(pBitmap,x,y,findcol,limit=0)
{
    Loop
    {
        if (limit > 0)
        {
            if (y > limit)
            {
                return ""
            }
        }
        col := Gdip_GetPixel(pBitmap,x,y)
        if (col = 0)
        {
            return ""
        }
        if (col != findcol)
        {
            return Object("x",x,"y",y)
        }
        y += 1
    }
}

;Finds lines of text by attempting to parse parts of a bitmap. A list of empty lines (gaplist) is used to refine the search.
;First find a non-background colour pixel on the first non-empty line. If that pixel is in the skiplist, skip it over and
;continue search on the same line. If no non-skiplist pixels are found, move down a line. When a non-background colour, non-skiplist
;pixel is found, find an empty column on its left side. Then try to parse a bitmap with x as empty column + 1. Adjust the y
;until parse is found.
TO_FindLines(pBitmap,forest,skiplist,gaplist,backgroundcolour)
{
    
    linecoords := Object()
    loopy := 0
    Loop
    {
        ;TO_RecursiveDebug(gaplist)
        ;if only two gaps remain, return linecoords
        if (TO_ObjectHaskeys(gaplist,1))
        {
            return linecoords
        }
        ;Retrieve the top and bottom coords of the space between the two topmost gaps in the list
        for k,v in gaplist
        {
            ;only two first gaps are required, so break on second pass
            if (A_Index = 2)
            {
                linebottom := v["top"]-1
                break
            }
            
            if (v["top"] <= loopy)
            {
                linetop := v["bottom"] + 1
                loopy := linetop
                spentkey := k
            }
            else
            {
                loopy += 1
                continue 2
            }
            
        }
        
        gaplist.Remove(spentkey)
        lineheight := (linebottom - linetop) + 1
        ;Find the first non-background colour pixel on the line
        Loop
        {
            colcoords := TO_FindNotColHorizontal(pBitmap,loopx,loopy,backgroundcolour)
            ;if outside bitmap, skip a line
            if (colcoords = "")
            {
                loopx := 0
                loopy += 1
                continue
            }
            ;if pixel is within a skip area, move over the area
            for k,v in skiplist
            {
                if (TO_WithinBox(colcoords["x"],colcoords["y"],v))
                {
                    loopx := v["x2"] + 1
                    continue 2
                }
            }
            ;if the previous conditions have not fired, find an empty column on the left and try to parse
            columnx := colcoords["x"]-1
            Loop
            {
                
                columncoords := TO_FindNotColVertical(pBitmap,columnx,colcoords["y"],backgroundcolour,linebottom)
                
                ;the loop breaks when an column of background colour is found or bitmap ends
                if (columncoords = "")
                {
                    break
                }
                else
                {
                    columnx -= 1
                }
            }
            
            ;clone the forest for filtering purposes
            rowforest := forest.Clone()
            ;select the first trie to try out
            ;arbitrary large number
            Loop
            {
                closest := 100
                ;TO_RecursiveDebug(rowforest)
                for k in rowforest
                {
                    difference := Abs(lineheight - k)
                    if (difference < closest)
                    {
                        trytriesize := k
                        closest := difference
                    }
                }
                parsetop := colcoords["y"]
                
                Loop
                {
                    ;trytriesize is used for both width and height, there might be a character wider than higher, which
                    ;would cause this to fail
                    pTestBitmap := Gdip_CloneBitmapArea(pBitmap, columnx+1, parsetop, trytriesize, trytriesize)
                    test := TO_ParseBitmap(pTestBitmap,rowforest[trytriesize],10,Object())
                    ;TO_RecursiveDebug()
                    ;TO_DebugBitmap(pTestBitmap)
                    ;pause
                    Gdip_DisposeImage(pTestBitmap)
                    if (TO_ObjectHaskeys(test,0) = False)
                    {
                        line := Object("top",parsetop,"height",trytriesize)
                        linecoords.Insert(line)
                        continue 4
                    }
                    parsetop -= 1
                    ;if no parse is found, remove this pixeltree from the forest and run the loop again
                    if (parsetop < 0)
                    {
                        if (TO_ObjectHaskeys(rowforest,0) = False)
                        {
                            rowforest.Remove(trytriesize,"")
                            break
                        }
                        ;if no parse found and no pixeltrees left, continue main loop
                        else
                        {
                            continue 4
                        }
                        
                    }
                }
            }
            
            
        }
        
       
        
        
        
    }
}

;Auxiliary function for checking whether a pixel is within a box
TO_WithinBox(x,y,box)
{
    if (x >= box["x1"]) and (x <= box["x2"]) and (y >= box["y1"]) and (y <= box["y2"])
    {
        return True
    }
    else
    {
        return False
    }
}


;Returns an array of the rows which only contain the background colour
TO_FindGaps(pBitmap,backgroundcolour,skiplist)
{
    ;This loop finds blank lines by checking every pixel.
    
    gaps := Object()
    loopx := 0
    loopy := 0
    inblankblock := True
    ;the first row is assumed to be empty
    currentgap := Object("top",0)
    
    Loop
    {
        ;check first, whether loopx is at the level of a skip area
        
        if (loopx = 0)
        {
            skipfound := False
            for k,v in skiplist
            {
                if (v["y1"] = loopy)
                {
                    skipfound := True
                    if (inblankblock = True)
                    {
                        currentgap.Insert("bottom",loopy-1)
                        gaps.Insert(currentgap)
                        inblankblock := False
                    }
                    loopy := v["y2"] + 1
                    skiplist.Remove(k)
                }
                
            }
            if (skipfound = True)
            {
                continue
            }
        }
        
        col := Gdip_GetPixel(pBitmap, loopx, loopy)
        
        ;if the loop reaches the end of the line, an empty line has been found
        if (col = 0) and (loopx != 0)
        {
            if (inblankblock = True)
            {
                loopx := 0
                loopy += 1
                continue
            }
            else
            {
                currentgap := Object("top",loopy)
                loopx := 0
                loopy += 1
                inblankblock := True
                continue
            }
        }
        
        ;if pixel is of background colour, increment loopx
        if (col = backgroundcolour)
        {
            loopx += 1
            continue
        }
        
        ;if the pixel is not of background colour and not 0, move to next line
        if (col != backgroundcolour) and (col != 0)
        {
            if (inblankblock = True)
            {
                ;this prevents spaces between the dot and the main part of an i from registering as gaps 
                if ((loopy - currentgap["top"]) > 2)
                {
                    currentgap.Insert("bottom",loopy-1)
                    gaps.Insert(currentgap)
                }
                inblankblock := False
            }
            loopx := 0
            loopy += 1
            continue
        }
        
        ;if end of bitmap is reached (colour is 0 at loopx 0), break
        if (col = 0) and (loopx = 0)
        {
            currentgap.Insert("bottom",loopy-1)
            gaps.Insert(currentgap)
            break
        }
        
    }
    
    return gaps
}

;This function takes as arguments a character and a format string (e.g. "Arial|10|Regular"). The function opens a
;borderless, marginless GUI and outputs the specified character in the specified format in the GUI. The GUI is then
;captured as a bitmap for further processing
TO_CreateCharBitmap(char,format)
{
    global backgroundcolour
    StringSplit, FormatArray, format, |
    ;destroy the gui from previous run, if any
    Gui, Destroy    
    ;create a borderless, marginless gui window containing the character
    Gui, Margin,0,0
    Gui, Color, %backgroundcolour%
    Gui, -Caption
    gui, font, s%FormatArray2% %FormatArray3%, %FormatArray1%
    Gui, Add, Text,,%char%
    Gui, Show, x0 y0,TO.ahk
    WinGetPos,,,Width,Height,TO.ahk
    coords := "0|0|" . Width . "|" . Height
    pBitmap := Gdip_BitmapFromScreen(coords)
    return pBitmap
}

;This function gets the coordinates (from top left of screen) for the specified control in the specified window
TO_GetControlCoords(control,window)
{
    WinGetPos, WposX,WposY,,,%window%
    ControlGetPos, CposX,CposY,Width,Height,%control%,%window%
    RealCposX := WposX + CposX
    RealCposY := WposY + CposY
    coords := RealCposX . "|" . RealCposY . "|" . Width . "|" . Height
    return coords
}

TO_GetFontlines(format)
{
    fontlines := Object() 
    ;First get the top and bottom lines of the font in a GUI
    pBitmap := TO_CreateCharBitmap("yl",format)
    ascentdescent := TO_GetLineHeight(pBitmap)
    ;Dispose the bitmap
    Gdip_DisposeImage(pBitmap)
    ;ascent from the top of GUI
    fontlines.Insert("toptoascent",ascentdescent["top"])
    ;descent is calculated from ascentdescent
    fontlines.Insert("descent",ascentdescent["bottom"]-ascentdescent["top"])
    
    return fontlines
}

;This function is used to calculate the height of a line
TO_GetLineHeight(pBitmap)
{
    ;the loop moves left to right
    loopx := 0
    loopy := 0
    topfound := False
    Loop
    {
        col := Gdip_GetPixel(pBitmap, loopx, loopy)
        belowthreshold := TO_BelowThresholdBrightness(col)
        
        if (belowthreshold) and (topfound = False)
        {   
            ;check if the loop coords are outside bitmap
            if (col = 0)
            {
                loopx := 0
                loopy += 1
                continue
            }
            ;if not, save the toppixel
            else
            {
                topfound := True
                toppixel := loopy
                loopx := 0
                loopy += 1
                continue
            }
        }
        
        if (belowthreshold) and (topfound = True)
        {
            if (col = 0)
            {
                bottompixel := loopy-1
                Break
            }
            else
            {
                loopx := 0
                loopy += 1
                continue
            }
        }
        
        loopx +=1
        
        
    }
    return Object("top",toppixel,"bottom",bottompixel)
}


;This function divides a bitmap to strips which have the same height as a line. The strips are then passed to TO_ParseBitmap
;and parsed. Result of individual lines are combined (with TO_AddToResults) and returned.
TO_DivideAndParse(pBitmap,forest,lines,spaceinpixels,skiplist)
{
    results := Object()
    width := Gdip_GetImageWidth(pBitmap)
    for k,v in lines
    {
        linetop := v["top"]
        lineheight := v["height"]
        ;filter the skip list for the line
        lineskiplist := Object()
        for k,v in skiplist
        {
            if (linetop > v["y1"]) and (linetop < v["y2"])
            {
                lineskiplist.Insert(v)
            }
        }
        pCBitmap := Gdip_CloneBitmapArea(pBitmap, 0, linetop, width, lineheight)
        lineresults := TO_ParseBitmap(pCBitmap,forest[lineheight],spaceinpixels,lineskiplist)
        Gdip_DisposeImage(pCBitmap)
        results := TO_AddToResults(results,lineresults,linetop,linetop+lineheight)
    }
    return results
}

;This function crops a character bitmap to fit the height of the line (fontlines)
TO_CropCharBitmap(pBitmap,fontlines)
{
    loopx := 0
    loopy := fontlines["toptoascent"]
    frontedgefound := False
    backedgefound := False
    ;this finds the x1 and x2 coordinates of the bitmap, rest are known (toptoascent and descent in fontlines)
    Loop
    {
        goright := False
        goup := False
        ;get the color of the pixel
        col := Gdip_GetPixel(pBitmap, loopx, loopy)
        belowthreshold := TO_BelowThresholdBrightness(col)
        ;break at the end of the bitmap
        if (col = 0) and (loopy = 0)
        {
            if (backedgefound = False)
            {
                backedge := loopx - 1
            }
            Break
        }
        
        ;if the color is nonblack, increase y
        if (belowthreshold = False)
        {
            godown := True
        }
        
        if (belowthreshold)
        {
            if (frontedgefound = False)
            {    
                frontedge := loopx
                frontedgefound := True
                goup := True
            }
            if (backedgefound = True)
            {
                backedgefound := False
                
            }
            goup := True
        }
        ;if outside bitmap and frontedge not found, move to next column
        if (loopy = (fontlines["toptoascent"]+fontlines["descent"])) and (frontedgefound = False)
        {
            goup := True
            
        }
        
        ;after finding the first empty column, assign the edge x coordinate
        if (loopy = (fontlines["toptoascent"]+fontlines["descent"])) and (frontedgefound = True)
        {
            if (backedgefound = False)
            {
                backedgefound := True
                backedge := loopx-1
            }
            
            goup := True
        }
        
        
        
        if (godown = True)
        {
            loopy += 1
        }
        
        if (goup = True)
        {
            loopy := 0
            loopx += 1
        }
    }
    x := frontedge
    y := fontlines["toptoascent"]
    w := (backedge-frontedge)+1
    h := (fontlines["descent"])+1
    pCBitmap := Gdip_CloneBitmapArea(pBitmap, x, y, w, h)
    return pCBitmap
}

;This function converts a bitmap to a pixelpath
TO_GetPixelpath(pBitmap)
{
    
    x := 0
    y := 0
    pixelpath := Object()
    
    Loop
    {
        col := Gdip_GetPixel(pBitmap,x,y)
        belowthreshold := TO_BelowThresholdBrightness(col)
        
        ;if outside bitmap at start of new column, break loop
        if (y = 0) and (col = 0)
        {
            Break
        }
        
        ;if outside bitmap, change to new column
        if (col = 0)
        {
            x += 1
            y := 0
            Continue
        }
        
        ;if inside bitmap, insert pixel
        if (belowthreshold)
        {
            pixelpath.Insert(A_Index,"True")
            y += 1
        }
        else
        {
            pixelpath.Insert(A_Index,"False")
            y += 1
        }
        
    }
    return pixelpath
}

;This function adds a pixelpath to a pixeltree
TO_AddToPaths(pixelpath,pixeltree,char)
{
    ;if pixelpath is empty, just return pixeltree
    if (TO_ObjectHaskeys(pixelpath,0) = True)
    {
        msgbox Pixelpath is empty
        return pixeltree
    }
    
    
    
    ;The pixelpath is traversed, and the relevant pixeltree branch is flattened at the same time.
    ;When the existing pixeltree nodes run out, building of a new branch begins (also in flattened format)
    ;When the pixelpath is entirely parsed, the new and old branches are deflattened and joined.
    
    flatbranch := Object()
    
    ;this is used to reverse the indexing for rebuilding
    maxpixels := 100000
    
    for k,v in pixelpath
    {        
        ;insert the pixels into the flatbranch in reverse order
        lastindex := Abs((A_Index)-maxpixels)
        
        ;if pixeltree contains a key for the pixel, insert the relevant part of the pixeltree into the flatbranch
        ;also insert the pixel into the "key" key of the flatbranch
        
        if pixeltree[v]
        {
            ;insert the pixeltree to the flatbranch
            
            flatbranch.Insert(lastindex,pixeltree.Clone())
            ;move to the next level of the pixeltree
            pixeltree := pixeltree[v].Clone()
            ;inserts a key for rebuilding tree
            flatbranch[lastindex].Insert("key",v)
            
        }
        ;if pixeltree does not contain a key for the pixel, insert the pixel into the flatbranch
        else
        {
            haskeys := False
            ;this for loop will fire if there's a key in the pixeltree
            for k in pixeltree
            {
                haskeys := True
            }
            if haskeys
            {
                flatbranch.Insert(lastindex,pixeltree.Clone())
                flatbranch[lastindex].Insert("key",v)
                
            }
            else
            {
                
                flatbranch[lastindex] := Object("key",v)
                
            }
            ;there's no lower level, so empty the pixeltree
            pixeltree := Object()
        }
        
    }
    
    
    ;initialize the tree to be rebuilt
    newbranch := Object()
    newbranch.SetCapacity(1000)
    ;boolean for being the first key in the flat tree
    firstkey := True
    for k,v in flatbranch
    {
        
        
        ;save the branch from previous iteration, for adding
        prevbranch := newbranch.Clone()
        prevbranch.SetCapacity(1000)
        ;copy the current flatbranch object
        newbranch := v.Clone()
        ;for first key, the one preceding char
        if firstkey
        {
            
            ;check whether a key exists for last pixel, if not create it
            if newbranch[newbranch["key"]]
            {
                
                newbranch[newbranch["key"]].Insert("char",char)
                newbranch.Remove("key")

            }
            else
            {
               
                newbranch[newbranch["key"]] := Object("char",char)
                newbranch.Remove("key")
            }
        }
        else
        {   
            
            ;if the newbranch contains the key, insert prevbranch into it
            if newbranch[newbranch["key"]]
            {
             
                newbranch.Insert(newbranch["key"],prevbranch.Clone())
                newbranch.Remove("key")

            }
            
            else
            {
              
                newbranch[newbranch["key"]] := prevbranch.Clone()
                newbranch.Remove("key")
                
            }

            
        }
        
    firstkey := False    
    }
    
    return newbranch
    
}

;This function compacts a pixeltree to speed up processing (recursive, but should not have enough levels to cause a crash)
TO_CompactPixeltree(pixeltree)
{
    ;!The problem: characters along the path are not copied to the compacted tree (only the "char" key is copied)
    ;They must be copied also when there are several keys. Also change ParseBitmap to handle "char" keys with other keys!
    
    ;Initialize the shortcut value and the compactedtree to be constructed
    shortcut := 0
    compacttree := Object()
    Loop
    {
        ;If the object has several keys, insert the compacted versions of the trees into the compacttree
        if (TO_ObjectHasKeys(pixeltree,1) = False)
        {
            for k,v in pixeltree
            {
                if (k = "char")
                {
                    compacttree.Insert(k,v)
                }
                else
                {
                    compacttree.Insert(k,TO_CompactPixeltree(v.Clone()))
                }
            }
            ;if shortcut value is greater than zero (i.e. previous levels have been compacted, add the shortcut value to tree
            if (shortcut > 0)
            {
                compacttree.Insert("shortcut",shortcut)
            }
            return compacttree.Clone()
        }
        else
        {
            ;Object has only one key in this else branch 
            for k,v in pixeltree
            {
                ;If the single key has an object as value, remove the redundant levels
                if (IsObject(v))
                {
                    pixeltree := v.Clone()
                    shortcut += 1
                }
                ;if the single key does not have an object as a value, return an object containing the char and the shortcut
                else
                {
                    return Object("char",v,"shortcut",shortcut)
                }
            }
        }
        
    }
}

;This function adds a result to an array or results
TO_AddToResults(results,lineresults,y1,y2)
{
    for k,v in lineresults
    {
        v.Insert("y1",y1)
        v.Insert("y2",y2)
        results.Insert(v.Clone())
    }
    return results
}

TO_EmptyColumnPath(lineheight)
{
    emptypath := Object()
    Loop,%lineheight%
    {
        emptypath.Insert(A_Index,"False")
    }
    return emptypath
}

TO_ParseBitmap(pBitmap,pixeltree,spaceinpixels,skiplist)
{
    resultarray := Object()
    origpixeltree := pixeltree.Clone()
    lineheight := Gdip_GetImageHeight(pBitmap)
    loopx := 0
    loopy := 0
    wordstarted := False
    blankcolumns := 0
    ;the x coordinate of the column the parsing of a word started in
    parsestartx := 0
    ;x coord to go back to if parse fails
    backtrack := 0
    Loop
    {
        
        ;Right at the start, check if the x is within a skip block
        for k,v in skiplist
        {
            if (loopx = v["x1"])
            {
                
                if (wordstarted = True) and (returnstring != "")
                {
                    result := Object("x1",wordx1,"x2",loopx-spaceinpixels,"word",returnstring)
                    resultarray.Insert(result)
                    wordstarted := False
                    returnstring := ""
                    blankcolumns := 0
                }
                loopx := v["x2"]+1
                skiplist.Remove(k)
            }
            
        }
        ;Add word if spaceinpixels is same as blankcolumns
        if (blankcolumns = spaceinpixels) and (wordstarted = True) and (returnstring != "")
        {
            result := Object("x1",wordx1,"x2",loopx-spaceinpixels,"word",returnstring)
            resultarray.Insert(result)
            wordstarted := False
            returnstring := ""
            blankcolumns := 0
        }
        ;check if there's a character on the current level
        if (pixeltree["char"])
        {
            if (pixeltree["char"] = "empty")
            {
                
                pixeltree := origpixeltree.Clone()
                blankcolumns += 1
                parsestartx := loopx
                continue
            }
            ;if path continues, save the char to buffer
            if (TO_ObjectHasKeys(pixeltree,1) = False)
            {
                charbuffer := pixeltree["char"]
                ;return to this if no other char found
                backtrack := loopx
            }
            ;else add a char to word or start a word
            else
            {
                
                if (wordstarted = False)
                {
                    wordstarted := True
                    wordx1 := parsestartx
                }
                blankcolumns := 0
                returnstring := returnstring . pixeltree["char"]
                pixeltree := origpixeltree.Clone()
                parsestartx := loopx
                charbuffer := ""
                continue
            }
        }
        
        ;Get the color of the pixel
        col := Gdip_GetPixel(pBitmap, loopx, loopy)
        
        ;Check whether end of bitmap has been reached
        if (col = 0)
        {
            ;Check if there's a char on the current level of the tree
            if (pixeltree["char"]) and (pixeltree["char"] != "empty")
            {
                returnstring := returnstring . pixeltree["char"]
            }
            ;Add the return string (if any) to results
            if (returnstring !="")
            {
                result := Object("x1",wordx1,"x2",loopx-1,"word",returnstring)
                resultarray.Insert(result)
            }
            break
            
        }
        
        ;check whether pixel color qualifies as font colour
        belowthresholdbool := TO_BelowThresholdBrightness(col)
        ;Booleans have to be converted to strings, since number indexes cause problems in objects
        belowthreshold := belowthresholdbool = 0 ? "False" : "True"
        
        ;If there's a path, increment y and continue the loop 
        if (pixeltree[belowthreshold])
        {    
            pixeltree := pixeltree[belowthreshold].Clone()
            loopy += 1
            if (loopy = lineheight)
            {
                loopx += 1
                loopy := 0
            }
            continue
        }
        ;If no path, process the charbuffer
        else
        {
            if (charbuffer != "")
            {
                if (wordstarted = False)
                {
                    wordstarted := True
                    wordx1 := parsestartx
                }
                blankcolumns := 0
                returnstring := returnstring . charbuffer
                pixeltree := origpixeltree.Clone()
                loopx := backtrack
                loopy := 0
                charbuffer := ""
                continue
            }
            ;if nothing in the charbuffer, just restore pixeltree
            else
            {
                pixeltree := origpixeltree.Clone()
                loopx += 1
                loopy := 0
                parsestartx := loopx
                continue
            }
        }
        
    }
    return resultarray
}

;This function calculates the brightness of an ARGB value
TO_BelowThresholdBrightness(argb)
{
    ;global boolean indicating whether text is darker than background
    global textdarker
    ;global indicating the threshold brightness
    global thresholdbrightness
    ;Set integer format to hex
    SetFormat, IntegerFast, H
    red := "0x" . SubStr(argb,5,2)
    green := "0x" . SubStr(argb,7,2)
    blue := "0x" . SubStr(argb,9,2)
    brightness := red + green + blue
    ;Revert integer format to decimal
    SetFormat, IntegerFast, D
    if (brightness < thresholdbrightness)
    {
        belowthreshold := True
    }
    else
    {
        belowthreshold := False
    }
    if (textdarker)
    {
        return belowthreshold
    }
    else
    {
        return not(belowthreshold)
    }
}


;This function adds up coordinates (of the format x|y|w|h)
TO_CoordAddition(controlcoords,wareacoords)
{
    StringSplit, control, controlcoords, |
    StringSplit, warea, wareacoords, |
    x := control1+warea1, y := control2+warea2, w := control3+warea3, h := control4+warea4
    return x . "|" . y . "|" . w . "|" . h
}

;This function draws boxes around the selected strings
TO_DrawWords(matches,realcoords,selection)
{
    ;ADAPTED FROM GDIP EXAMPLES, thanks to TIC
    
    StringSplit, real, realcoords, |
    ; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
    Width := real3
    Height := real4

    ; Get a handle to this window we have created in order to update it later
    hwnd1 := WinExist()

    ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
    hbm := CreateDIBSection(Width, Height)

    ; Get a device context compatible with the screen
    hdc := CreateCompatibleDC()

    ; Select the bitmap into the device context
    obm := SelectObject(hdc, hbm)

    ; Get a pointer to the graphics of the bitmap, for use with drawing functions
    G := Gdip_GraphicsFromHDC(hdc)

    ; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
    Gdip_SetSmoothingMode(G, 4)

    ; Create a transparent brush
    pBrush := Gdip_BrushCreateSolid(0000000000)

    ; Fill the graphics of the bitmap with a rounded rectangle using the brush created
    ; Filling the entire graphics - from coordinates (0, 0) the entire width and height
    ; The last parameter (20) is the radius of the circles used for the rounded corners
    Gdip_FillRoundedRectangle(G, pBrush, 0, 0, Width, Height, 20)

    ; Delete the brush as it is no longer needed and wastes memory
    Gdip_DeleteBrush(pBrush)
    
    pPen := Gdip_CreatePen(0xffff0000, 2)
    currentPen := Gdip_CreatePen(0xffff00ff, 2)
    
    for matchkey,matchvalue in matches
    {
        if (matchkey = selection)
        {       
            Pen := currentPen
        }
        else
        {
            Pen := pPen
        }
        
        for k,v in matchvalue["boxes"]
        {
            Point1 := v["x1"] . "," . v["y1"]
            Point2 := v["x1"] . "," . v["y2"]
            Point3 := v["x2"] . "," . v["y2"]
            Point4 := v["x2"] . "," . v["y1"]
            if (A_Index = 1)
            {
                Points := Point3 . "|" . Point2 . "|" . Point1 . "|" . Point4
                Gdip_DrawLines(G, Pen, Points)
            }
            else
            {
                UpperPoints := Point1 . "|" . Point4
                LowerPoints := Point2 . "|" . Point3
                Gdip_DrawLines(G, Pen, UpperPoints)
                Gdip_DrawLines(G, Pen, LowerPoints)
            }
        }
        Points := Point1 . "|" . Point4 . "|" . Point3 . "|" . Point2
        Gdip_DrawLines(G, Pen, Points)
    }
    
    ; Delete the brush as it is no longer needed and wastes memory
    Gdip_DeletePen(pPen)
    Gdip_DeletePen(currentPen)

    ; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
    ; With some simple maths we can place the gui in the centre of our primary monitor horizontally and vertically at the specified heigth and width
    UpdateLayeredWindow(hwnd1, hdc, real1, real2, Width, Height)

    ; Select the object back into the hdc
    SelectObject(hdc, obm)

    ; Now the bitmap may be deleted
    DeleteObject(hbm)

    ; Also the device context related to the bitmap may be deleted
    DeleteDC(hdc)

    ; The graphics may now be deleted
    Gdip_DeleteGraphics(G)
    Return
}

;This function generates a navigation net for the matches, based on their coordinates
TO_GenerateMatchnet(matches)
{
    
    results := Object()
    ;Generate a coordinates list from the matches
    for matchkey,matchvalue in matches
    {
        
        for boxkey,boxvalue in matchvalue["boxes"]
        {
            box := boxvalue.Clone()
            ;insert the matchkey to the box array
            box.Insert("matchkey",matchkey)
            results.Insert(box)
        }
    }
    matchnet := Object()
    for k,v in results
    {
        
        up := ""
        down := ""
        left := ""
        right := ""
        sourcex := v["x1"]
        sourcey := v["y1"]
        
        up := TO_FindClosestUp(sourcex,sourcey,results)
        if (up = "")
        {
            up := TO_FindClosestUp(sourcex,5000,results)
        }
        
        down := TO_FindClosestDown(sourcex,sourcey,results)
        if (down = "")
        {
            down := TO_FindClosestDown(sourcex,0,results)
        }
        
        left := TO_FindClosestLeft(sourcex,sourcey,results)
        if (left = "")
        {
            left := TO_FindFarRight(results[up]["x1"],results[up]["y1"],results)
            if (left = "")
            {
                left := up
            }
        }
        
        right := TO_FindClosestRight(sourcex,sourcey,results)
        if (right = "")
        {
            right := TO_FindFarLeft(results[down]["x1"],results[down]["y1"],results)
            if (right = "")
            {
                right := down
            }
        }
        net := Object()
        net.Insert("up",up)
        net.Insert("down",down)
        net.Insert("left",left)
        net.Insert("right",right)
        net.Insert("matchkey",v["matchkey"])
        matchnet.Insert(k,net)
    }
    
    return matchnet

}

;The Find functions are used in the TO_GenerateMatchnet function
TO_FindClosestUp(sourcex,sourcey,results)
{
    
    destinationy := 0
    for k,v in results
    {
        if (v["y1"] < sourcey) and (v["y1"] > destinationy)
        {
            destinationy := v["y1"]
        }
    }
    xdistance := 10000
    for k,v in results
    {
        if (v["y1"] = destinationy) and (Abs(sourcex - v["x1"]) < xdistance)
        {
            xdistance := Abs(sourcex - v["x1"])
            destination := k
        }
    }
     
    return destination
}

TO_FindClosestDown(sourcex,sourcey,results)
{
    
    destinationy := 5000
    for k,v in results
    {
        
        if (v["y1"] > sourcey) and (v["y1"] < destinationy)
        {
            
            destinationy := v["y1"]
        }
    }
    
    xdistance := 10000
    for k,v in results
    {
        if (v["y1"] = destinationy) and (Abs(sourcex - v["x1"]) < xdistance)
        {
            xdistance := Abs(sourcex - v["x1"])
            destination := k
        }
    }
     
    return destination
}

TO_FindClosestLeft(sourcex,sourcey,results)
{
    destination := ""
    for k,v in results
    {
        if (destination != "")
        {
            currentchoice := results[destination]["x1"]
        }
        else
        {
            currentchoice := 0
        }
        if (v["y1"] = sourcey) and (v["x1"] < sourcex) and (currentchoice < v["x1"])
        {
            destination := k
        }
    }
     
    return destination
}

TO_FindFarLeft(sourcex,sourcey,results)
{
    destination := ""
    for k,v in results
    {
        if (destination != "")
        {
            currentchoice := results[destination]["x1"]
        }
        else
        {
            currentchoice := 5000
        }
        if (v["y1"] = sourcey) and (v["x1"] < sourcex) and (currentchoice > v["x1"])
        {
            destination := k
        }
    }
     
    return destination
}

TO_FindClosestRight(sourcex,sourcey,results)
{
    destination := ""
    for k,v in results
    {
        if (destination != "")
        {
            currentchoice := results[destination]["x1"]
        }
        else
        {
            ;any large number
            currentchoice := 5000
        }
        if (v["y1"] = sourcey) and (v["x1"] > sourcex) and (currentchoice > v["x1"])
        {
            destination := k
        }
    }
     
    return destination
}

TO_FindFarRight(sourcex,sourcey,results)
{
    destination := ""
    for k,v in results
    {
        if (destination != "")
        {
            currentchoice := results[destination]["x1"]
        }
        else
        {
            ;any large number
            currentchoice := 0
        }
        if (v["y1"] = sourcey) and (v["x1"] > sourcex) and (currentchoice < v["x1"])
        {
            destination := k
        }
    }
     
    return destination
}

TO_SkipToNextTerm(matches,matchnet,selection,direction)
{
    Loop
    {
        if !(TO_ObjectHaskeys(matches,1)) and !(TO_ObjectHaskeys(matches,0))
        {
            ;if the matchkey is same (boxes belong to same term, skip to next in same direction
            if (matchnet[oldselection]["matchkey"] = matchnet[selection]["matchkey"])
            {
                oldselection := selection
                selection := matchnet[selection][direction]
            }
            ;if there's no match for the matchkey, skip to next in same direction
            else if (matches[selection]="")
            {
                oldselection := selection
                selection := matchnet[selection][direction]
            }
            else
            {
                break
            }
        }
        else
        {
            break
        }
    }
    return selection
}

;This function checks whether an object has the specified amount of keys
TO_ObjectHaskeys(object,number)
{
    keynumber := 0 
    for k in object
    {
        keynumber += 1
    }
    if (keynumber = number)
    {
        return True
    }
    else
    {
        return False
    }
}

;Debugging functions
TO_RecursiveDebug(pixeltree)
{
    haskeys := False
    for k,v in pixeltree
    {
        haskeys := True
        keys := keys . " " . k . " " . "'" . v . "'"
    }
    if haskeys := False
    {
        msgbox "no keys"
    }
    Loop
    {
        InputBox, keyno,,%keys%
        if (keyno = "q")
        return
        TO_RecursiveDebug(pixeltree[keyno])
    }
    
    
    
}

TO_DebugBitmap(pBitmap)
{
    Gdip_SaveBitmapToFile(pBitmap, "debug.BMP")
    return
}