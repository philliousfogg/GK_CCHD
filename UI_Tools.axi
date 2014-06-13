PROGRAM_NAME='UI_Tools'


DEFINE_TYPE

STRUCTURE _ListData
{
    INTEGER ID		//Index of Data
    CHAR Label[255]	//Label of the Button
    INTEGER DataID	//Data Slot This relates to another structures ID
}

STRUCTURE _UIList 
{
    INTEGER ID			//UI List Index ID
    INTEGER startBtn    	//The UI Button the Lists Starts From
    INTEGER Position		//The Position on the List Loupe
    INTEGER displaySize 	//Maximum display size
    dev UIDevice		//Which User Interface to use
    INTEGER Selected		//Which Button was selected
    INTEGER SLOT[20]		//List Slot to index current displayed data
    Char ref[6]		//6 Character Ref
    _ListData DataSet[255]	//Data set for the list 
    INTEGER ShowList		//Tells List Loop to rewrite List every 2secs
    INTEGER btns[255]		//List of buttons
    INTEGER incBtn		//Increment List Button
    INTEGER decBtn		//decrement List Button
}



DEFINE_VARIABLE
 

VOLATILE _UIList UIList[LISTS_LENGTH]


DEFINE_FUNCTION integer NewList( dev UIDevice, integer startBtn, integer displaySize, char ref[6], integer incBtn, integer decBtn )
{
    STACK_VAR INTEGER i,x 
    
    //Search for a spare slot in the list
    FOR ( i=1; i<=LISTS_LENGTH; i++ )
    {
	IF ( !UIList[i].ID )
	{
	    x = i
	    break
	}
    }
    
    UIList[x].ID = x
    UIList[x].UIDevice = UIDevice
    UIList[x].startBtn = startBtn
    UIList[x].displaySize = displaySize
    UIList[x].Position = 1
    UIList[x].ref = ref
    UIList[x].incBtn = incBtn
    UIList[x].decBtn = decBtn
    
    FOR ( i=1; i<=255; i++ )
    {
	UIList[x].DataSet[i].ID = 0
	UIList[x].DataSet[i].Label = ''
	UIList[x].DataSet[i].DataID = 0 
    }
    
    return x
}

DEFINE_FUNCTION addListElement( integer List, char Label[255], integer slot, integer DataID )
{
    UIList[List].DataSet[slot].ID = Slot
    UIList[List].DataSet[slot].Label = Label
    UIList[List].DataSet[slot].DataID = DataID  
}



DEFINE_FUNCTION integer GetDataIDFromDataSet ( integer List, Integer slotNum )
{
    if ( UIList[List].SLOT[slotNum] )
    {
	return UIList[List].DataSet[UIList[List].SLOT[slotNum]].DataID
    }
    ELSE
    {
	return 0
    }
}

//Returns the slot number from a data Index
DEFINE_FUNCTION integer GetSlotFromDataIndex ( integer List, integer index )
{
    STACK_VAR INTEGER i 

    FOR (i=1; i<=UIList[List].displaySize; i++ )
    {
	if ( UIList[List].Slot[i] == index )
	{
	    return i
	}
    }
    return 0
}


DEFINE_FUNCTION clearDisplayedData( integer List, INTEGER UIButtonSet[], Integer HideBtns )
{
    STACK_VAR integer i
    FOR (i=1; i<=UIList[List].displaySize; i++)
    {
	SEND_COMMAND UIList[List].UIDevice, "'TEXT',ITOA( UIButtonSet[i + UIList[List].startBtn ] ),'-'"
	
	//If buttons need to be hidden then Hide the buttons
	IF ( HideBtns )
	    SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA( UIButtonSet[i + UIList[List].startBtn ] ),',0'"
	
	//This must be declared in the code <list#>,<listRef>,<data>,<button>,<TP.Port>
	UI_TOOLS_DisplayListElement( List, UIList[List].ref,0,i,UIList[List].UIDevice.PORT )
	//SEND_STRING vdvSystem, "'DisplayListData-id=',ITOA ( List ),'&ref=',UIList[List].ref,'&button=',ITOA ( i ),'&uiport=',ITOA( UIList[List].UIDevice.PORT )"
	
	UIList[List].SLOT[i] = 0
    }
}

DEFINE_FUNCTION clearListElements(integer List)
{
    STACK_VAR integer i
    FOR (i=1; i<=128; i++)
    {
	If ( UIList[List].DataSet[i].ID )
	{
	    UIList[List].DataSet[i].ID = 0
	    UIList[List].DataSet[i].Label = ''
	    UIList[List].DataSet[i].DataID = 0
	}
	ELSE {
	    break
	}
    }
}



DEFINE_FUNCTION displayListData( integer List, integer start, INTEGER UIButtonSet[], INTEGER HideBtns )
{
    STACK_VAR INTEGER i, x
    STACK_VAR sINTEGER difference

    difference = TYPE_CAST ( ( start + UIList[list].displaySize - 1 ) ) - TYPE_CAST ( getListDataSetLength(List) )
    
    // if they is a difference and make sure that we are not just at the top of the list
    if ( difference > 0 AND ( getListDataSetLength(List) > UIList[List].displaySize ) )
    {
	// create new start position
	start = start - TYPE_CAST ( difference )
    }

    x = start
    
    FOR ( i = 1; i <=UIList[List].displaySize; i++ )
    {
	If ( UIList[List].DataSet[x].ID )
	{
	    UIList[List].Slot[i] = x
	    SEND_COMMAND UIList[List].UIDevice, "'TEXT',ITOA ( UIButtonSet[i + UIList[List].startBtn] ),'-',UIList[List].DataSet[x].Label"
	    SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA ( UIButtonSet[i + UIList[List].startBtn] ),',1'"
	    
	    //This must be declared in the code <list#>,<listRef>,<data>,<button>,<TP.Port>
	    UI_TOOLS_DisplayListElement( List, UIList[List].ref, UIList[List].DataSet[x].DataID, i,UIList[List].UIDevice.PORT )
	    //SEND_STRING vdvSystem, "'DisplayListData-id=',ITOA ( List ),'&ref=',UIList[List].ref,'&data=',ITOA ( UIList[List].DataSet[x].DataID ),'&button=',ITOA ( i ),'&uiport=',ITOA( UIList[List].UIDevice.PORT )"
	    x++
	}
	ELSE
	{
	    SEND_COMMAND UIList[List].UIDevice, "'TEXT',ITOA( UIButtonSet[i + UIList[List].startBtn ] ),'-'"
	    
	    //If buttons need to be hidden then Hide the buttons
	    IF ( HideBtns )
		SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA( UIButtonSet[i + UIList[List].startBtn ] ),',0'"
	    
	    //This must be declared in the code <list#>,<listRef>,<data>,<button>,<TP.Port>
	    UI_TOOLS_DisplayListElement( List, UIList[List].ref,0,i,UIList[List].UIDevice.PORT )
	    //SEND_STRING vdvSystem, "'DisplayListData-id=',ITOA ( List ),'&ref=',UIList[List].ref,'&button=',ITOA ( i ),'&uiport=',ITOA( UIList[List].UIDevice.PORT )"
	    
	    UIList[List].SLOT[i] = 0
	}
    }
    
    // Handle increment button
    if ( start == 1 )
    {
	// Hide up button
	SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA( UIList[List].incBtn ),',0'"
    }
    ELSE
    {
	// Hide up button
	SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA( UIList[List].incBtn ),',1'"
    }
    
    // Handle decrement button
    if ( getListDataSetLength(List) <= ( start + UIList[List].displaySize - 1 ) OR getListDataSetLength(List) <= UIList[List].displaySize )
    {
	// Hide down button
	SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA( UIList[List].decBtn ),',0'"
    }
    ELSE
    {
	// Hide down button
	SEND_COMMAND UIList[List].UIDevice, "'^SHO-',ITOA( UIList[List].decBtn ),',1'"
    }
    
    UIList[List].Position = Start
}

DEFINE_FUNCTION setElementSelectedbyButton( integer List, integer ButtonIndex )
{
    UIList[List].Selected = UIList[List].SLOT[ButtonIndex - UIList[List].startBtn ]
}

DEFINE_FUNCTION setElementSelectedbySlot( integer List, integer SlotIndex )
{
    UIList[List].Selected = UIList[List].SLOT[SlotIndex]
}

DEFINE_FUNCTION integer getListDataSetLength( integer List )
{
    STACK_VAR INTEGER i
    STACK_VAR INTEGER x
    FOR ( i=1; i<=128; i++ )
    {
	IF ( UIList[List].DataSet[i].ID )
	{
	    x++
	}
	ELSE
	{
	    break
	}
    }
    return x
}

DEFINE_FUNCTION incrementList(integer List, integer step, INTEGER UIButtonSet[] )
{
    //Increment by step
    if ( step == 1 )
    {
	IF ( ( UIList[List].Position - Step ) > 0 ) 
	{
	    displayListData(List, ( UIList[List].Position - Step ), UIButtonSet, 0 )  
	}
	ELSE
	{
	    displayListData(List, 1, UIButtonSet, 0 ) 
	}
    }
    
    //Increment by Page
    ELSE
    {
	STACK_VAR INTEGER newPosition
	newPosition = UIList[List].Position - UIList[List].displaySize 
	
	if ( newPosition > 0 )
	{
	    displayListData(List, newPosition, UIButtonSet, 1 )
	}	
    }
}

DEFINE_FUNCTION decrementList( integer List, integer step, INTEGER UIButtonSet[] )
{
    //Decrement by step
    if ( step == 1 )
    {
	IF ( UIList[List].DisplaySize < getListDataSetLength(List) )
	{
	    //Not at the botton of the data set
	    IF ( UIList[List].Position <= ( getListDataSetLength(List) - UIList[List].displaySize ) ) 
	    {
		displayListData(List, ( UIList[list].Position + Step ), UIButtonSet, 0 )  
	    }
	    //reaches bottom of data set
	    (*ELSE
	    {
		displayListData(getListDataSetLength() - UIList.displaySize, UIButtonSet ) 
	    }*)
	}
    }
    
    //Decrement by Page
    ELSE
    {
	STACK_VAR INTEGER newPosition
	newPosition = UIList[List].Position + UIList[List].displaySize
	
	if ( newPosition <= getListDataSetLength(List)  )
	{
	    displayListData(List, newPosition, UIButtonSet, 1 )
	}
    }
}


DEFINE_PROGRAM

