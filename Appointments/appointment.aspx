
<%@ page language="C#" masterpagefile="~/RMS.master" autoeventwireup="true" inherits="scheduling_schedule_appointments, App_Web_appointment.aspx.9786cbe8" title="Add Appointments" enableeventvalidation="false" culture="auto" uiculture="auto" meta:resourcekey="PageResource1" %>
<%@ Register Src="~/controls/defaultnavtoolbar.ascx" TagName="defaultnavtoolbar" TagPrefix="uc1" %>
<%@ Register Assembly="ComponentArt.Web.UI" Namespace="ComponentArt.Web.UI" TagPrefix="ComponentArt" %>
<%@ Register Assembly="AMX.WebControls" Namespace="AMX.WebControls" TagPrefix="AMX" %>
<%@ Register Src="~/controls/appointmentrecurrence.ascx" TagName="AppointmentRecurrence" TagPrefix="uc1" %>
<%@ Register Src="~/controls/appointmentpresetconfiguration.ascx" TagName="AppointmentPresetConfiguration" TagPrefix="uc1" %>
<%@ Register Src="~/controls/schedulingview_roomselectiontree.ascx" TagName="roomselect" TagPrefix="uc4" %>

<asp:Content ID="Content1" ContentPlaceHolderID="placeholderMain" Runat="Server">
  
    <script language="JavaScript" type="text/javascript" src="../scripts/scheduling.js"></script>       
    <script language="JavaScript" type="text/javascript" src="../scripts/misc.js"></script>  
         
    <script type="text/javascript">
  
    //
    // Register event handlers
    //
    window.onload = PageLoad;
    window.onunload = PageUnload;
  
    //
    // Page load handler
    //
    function PageLoad() 
    {      
        // do we need the user to confirm forcing appointment conflicts?
        var tempCtrl = document.getElementById('<%= _needUserInput.ClientID %>');
        if(tempCtrl != null)
        { 
            if ( tempCtrl.value == "1") 
            {    
                var retCode = confirm(document.getElementById('<%= _conflictingUserQuery.ClientID %>').value);      
                if(retCode == true)
                {      
                    document.getElementById('<%= _overrideConflicting.ClientID %>').value = "1";
                
                    document.getElementById('<%= btnSave.ClientID %>').click();
                }
            }        
        
            // appointment conflicts are not allowed?
            if  ( tempCtrl.value == "2")
            {
                  alert(document.getElementById('<%= _conflictingUserQuery.ClientID %>').value);
            }
        }
        // call this AFTER conflict override confirmation.
        // UpdateSelectedRoom();
   
       //Disable/hide things that should not be displayed if an external scheduler is used.
        if(GetCookie("UsingExternalScheduler") == "1") 
        {   
            tempCtrl = document.getElementById('<%= pickerEnd.ClientObjectId %>' + "_picker");
            if (tempCtrl != null)
                tempCtrl.disabled = true;
            
            tempCtrl = document.getElementById('<%= pickerStart.ClientObjectId %>' + "_picker");
            if (tempCtrl != null)
                tempCtrl.disabled = true;
         
            var strTemp;
          
            //Hide the calendar button images.  Have to do it this way because making the image
            //buttons server controls gorfs the popup calendars associated with them.
            for(var nImageIndex = 0; nImageIndex < document.images.length; nImageIndex++) 
            {          
                strTemp = document.images[nImageIndex].id;
            
                if(strTemp.search(/imgCalendarStart/i) >= 0 || strTemp.search(/imgCalendarEnd/i) >= 0) 
                    document.images[nImageIndex].style.display = "none";
            } 
		}
        
        // load appointment recurrence page
        AppointmentRecurrence_PageLoad();   
        
        //Viju Hide all unused panels
        viju_hideUnusedPanels()
    }
  
    //
    // Page unload handler
    //
    function PageUnload() 
    {
    }
  
    //
    // Display the Upload Welcome Image UI
    //
    function DisplayUpload()
    {
        <%= multipageDisplayImage.ClientID %>.SetPageId('pageDisplayImageUpload');
    }

    //
    // Display the Welcome Image Preview UI
    //
    function DisplayImagePreview()
    {
        <%= multipageDisplayImage.ClientID %>.SetPageId('pageDisplayImagePreview');
    }
    
    //
    // Get updated Welcome Preview Image 
    //    
    function GetPreviewImage(name)
    {
        <%= callbackDisplayImage.ClientID %>.Callback(name);
        DisplayImagePreview();
    }
  
    //
    // Date Change On - START DATE 
    //
    function FromPicker_OnDateChange() 
    {        
        var fromDate = <%= pickerStart.ClientObjectId %>.GetSelectedDate();
        var toDate = <%= pickerEnd.ClientObjectId %>.GetSelectedDate();

        <%= calendarStart.ClientObjectId %>.SetSelectedDate(fromDate);

        if(fromDate > toDate) 
        {
            <%= pickerEnd.ClientObjectId %>.SetSelectedDate(fromDate);
            <%= calendarEnd.ClientObjectId %>.SetSelectedDate(fromDate);
        }    
    }

    //
    // Date Change On - END DATE 
    //
    function ToPicker_OnDateChange() 
    {
        var fromDate = <%= pickerStart.ClientObjectId %>.GetSelectedDate();
        var toDate = <%= pickerEnd.ClientObjectId %>.GetSelectedDate();

        <%= calendarEnd.ClientObjectId %>.SetSelectedDate(toDate);

        if(fromDate > toDate) 
        {
            <%= pickerStart.ClientObjectId %>.SetSelectedDate(toDate);
            <%= calendarStart.ClientObjectId %>.SetSelectedDate(toDate);
        }
    }

    //
    // Date Change On - START DATE 
    //
    function FromCalendar_OnDateChange() 
    {
        var fromDate = <%= calendarStart.ClientObjectId %>.GetSelectedDate();
        var toDate = <%= pickerEnd.ClientObjectId %>.GetSelectedDate();

        <%= pickerStart.ClientObjectId %>.SetSelectedDate(fromDate);

        if(fromDate > toDate) 
        {
            <%= pickerEnd.ClientObjectId %>.SetSelectedDate(fromDate);
            <%= calendarEnd.ClientObjectId %>.SetSelectedDate(fromDate);
        }
    }

    //
    // Date Change On - END DATE 
    //
    function ToCalendar_OnDateChange() 
    {
        var fromDate = <%= pickerStart.ClientObjectId %>.GetSelectedDate();
        var toDate = <%= calendarEnd.ClientObjectId %>.GetSelectedDate();

        <%= pickerEnd.ClientObjectId %>.SetSelectedDate(toDate);

        if(fromDate > toDate) 
        {
            <%= pickerStart.ClientObjectId %>.SetSelectedDate(toDate);
            <%= calendarStart.ClientObjectId %>.SetSelectedDate(toDate);
        }
    }

    //
    // START DATE Calendar Button
    //
    function FromButton_OnClick()
    {
        if(<%= calendarStart.ClientObjectId %>.PopUpObjectShowing) 
        {
            <%= calendarStart.ClientObjectId %>.Hide();
        }
        else 
        {
            <%= calendarStart.ClientObjectId %>.SetSelectedDate(<%= pickerStart.ClientObjectId %>.GetSelectedDate());      
            <%= calendarStart.ClientObjectId %>.Show();
        }
    }

    //
    // END DATE Calendar Button
    //
    function ToButton_OnClick() 
    {
        if(<%= calendarEnd.ClientObjectId %>.PopUpObjectShowing) 
        {
            <%= calendarEnd.ClientObjectId %>.Hide();
        }
        else 
        {
            <%= calendarEnd.ClientObjectId %>.SetSelectedDate(<%= pickerEnd.ClientObjectId %>.GetSelectedDate());
            <%= calendarEnd.ClientObjectId %>.Show();
        }
    }

    //
    // START DATE Calendar Button
    //
    function FromButton_OnMouseUp() 
    {
        if(<%= calendarStart.ClientObjectId %>.PopUpObjectShowing) 
        {
            event.cancelBubble = true;
            event.returnValue = false;
            return false;
        }
        else 
        {
            return true;
        }
    }

    //
    // END DATE Calendar Button
    //
    function ToButton_OnMouseUp() 
    {
        if(<%= calendarEnd.ClientObjectId %>.PopUpObjectShowing) 
        {
            event.cancelBubble = true;
            event.returnValue = false;
            return false;
        }
        else 
        {
            return true;
        }
    }

    //
    // Room selection changed
    //
    function RoomComboCallback_Complete()
    {
        // submit post back
        theForm.__EVENTTARGET.value = 'RoomChanged';
        theForm.__EVENTARGUMENT.value = null;
        theForm.submit();
    }

    //
    //Password enabled checkbox event handler
    //
    function EnablePassword(bEnabled) 
    {
        var passwordTextElement = document.getElementById('<%= txtPassword.ClientID %>');

        passwordTextElement.disabled = !bEnabled;

        if(bEnabled)
        {
            passwordTextElement.focus();
        }
    }
    
    function TimeCheck()
    {  
        var timeCtrl = null;
        var roomSelect = document.getElementById('<%= roomselectctrl.ClientID %>' + '_txtRooms');
        if (roomSelect == null || roomSelect.value.length == 0)
        {        
            alert(<%= AMX.RMS.Resources.Local.GetJavascriptString("roomError") %>);
            return false;
        }
     
        var startHour = document.getElementById('<%= ddlHourStart.ClientID %>').value;
        var startMinute = document.getElementById('<%= ddlMinuteStart.ClientID %>').value;
        //

        if (theForm.hourformat.value == "12")
        {
            startHour = startHour % 12; //mod by 12
            timeCtrl = document.getElementById('<%= ddlAMPMStart.ClientID %>');
            if (timeCtrl != null)
            {
                if (timeCtrl.value == theForm.pmdesignator.value)
                {
                    startHour += 12;
                }
             }
        }
        var startTime = startHour * 100 + startMinute*1;
    
        var endHour = document.getElementById('<%= ddlHourEnd.ClientID %>').value;
        var endMinute = document.getElementById('<%= ddlMinuteEnd.ClientID %>').value;
    
        if (theForm.hourformat.value == "12")
        {
            endHour = endHour % 12; //mod by 12
            timeCtrl = document.getElementById('<%= ddlAMPMEnd.ClientID %>');
            if (timeCtrl != null)
            {
                if (timeCtrl.value == theForm.pmdesignator.value)
                {
                    endHour += 12;
                }
            }
        }
        var endTime = (endHour * 100) + (endMinute*1);

        //alert("s: " + startTime + " -- e:" + endTime);
        var fromDate = <%= pickerStart.ClientObjectId %>.GetSelectedDate();
        var toDate = <%= pickerEnd.ClientObjectId %>.GetSelectedDate();
        if (startTime >= endTime)
        {
            if ( (fromDate.getYear()  == toDate.getYear()) && 
                 (fromDate.getMonth() == toDate.getMonth()) && 
                 (fromDate.getDate()  >= toDate.getDate())  )
            {
                alert(<%= AMX.RMS.Resources.Global.GetJavascriptString("timeError") %>);
                return false;
            }
        }
     
    
        //we also need to figure out how to check recurrence end time with start time
        if (document.getElementById('<%= _appointmentRecurrence.ClientID %>'+'__endByDateRadioButton').checked )
        {
            if (!AppointmentRecurrenceControl_RecurringEndDateAfterDate(fromDate))
            {
                alert(<%= AMX.RMS.Resources.Local.GetJavascriptString("endDateError") %>);
                return false;
            }

            if (!AppointmentRecurrenceControl_RecurringEndDateAfterDate(toDate))
            {
                alert(<%= AMX.RMS.Resources.Local.GetJavascriptString("endDateError") %>);
                return false;
            }            
        }
        
        return true;
    }
    
 
    function VerifyDelete()
    {
        // prompt to confirm delete
        if (confirm(<%= AMX.RMS.Resources.Local.GetJavascriptString("delete_prompt")%>) == true)
        {
           return true;
        }
        else
            return false;        
    }
    
    function VerifyPasswordEntry()
    {
        var name = document.getElementById('<%= txtPasswordEntry.ClientID %>');
        var text = "";
        if (name != null)
        {
            text = name.value;
            if ((TrimString(text) != "") && (text != undefined))
            {
                return true;           
            }
            else
            {
                name.focus();
                return false;
            }
        }
    }
    
    //This is a custom Javascript function for Viju Group
    function Viju_updateLessonInfo()
    {
        var textBox1 = document.getElementById('ctl00_placeholderMain__welcomeText1');
        var textBox2 = document.getElementById('ctl00_placeholderMain__welcomeText2');
        var textBox3 = document.getElementById('ctl00_placeholderMain__welcomeText3');
        var textBox4 = document.getElementById('ctl00_placeholderMain__welcomeText4');
        var roomType = document.getElementById('viju_teacher_option');
        var code = document.getElementById('viju_code');
        var pin = document.getElementById('viju_pin');
        var externalSite = document.getElementById('viju_external_site');
        var extCheckBox = document.getElementById('viju_ext_checkbox');
        var notValid = false;

        textBox1.value = '&type=' + roomType.options[roomType.selectedIndex].value;
        textBox2.value = '&pin=' + pin.value; 
        textBox3.value = '&code=' + code.value;


        //Validate entry
        if ( roomType.selectedIndex == 0 )
        {
            notValid = true;
            document.getElementById('viju_type_help').innerHTML = "Select a room type";
        }
        else
        {
            document.getElementById('viju_type_help').innerHTML = "";
        }

        if ( pin.value == '' ) 
        {
            notValid = true;
            document.getElementById('viju_pin_help').innerHTML = "Enter a room pin";
        }
        else if ( isNaN(pin.value) )
        {
            notValid = true;
            document.getElementById('viju_pin_help').innerHTML = "Please enter a number";
        }
        else if ( pin.value.length < 5 )
        {
            notValid = true;
            document.getElementById('viju_pin_help').innerHTML = "Pin must be more than 5 characters";
        }
        else
        {
            document.getElementById('viju_pin_help').innerHTML = "";
        }

        if ( code.value == '' )
        {
            notValid = true;
            document.getElementById('viju_code_help').innerHTML = "Enter a lesson code";
        }
        else
        {
            document.getElementById('viju_code_help').innerHTML = "";
        }

        
        if ( extCheckBox.checked )
        {
            if ( externalSite.value == '')
            {
                notValid = true;
                document.getElementById('viju_ext_help').innerHTML = "Enter a valid SIP or IP address";
            }
            else if ( externalSite.value.indexOf("@training.globalknowledge.net") != -1 )
            {
                notValid = true;
                document.getElementById('viju_ext_help').innerHTML = "Please use an external site address";
            }
            else if ( externalSite.value.indexOf('9976001') != -1 && externalSite.value.indexOf('@interoute.vc') != -1 )
            {
                notValid = true
                document.getElementById('viju_ext_help').innerHTML = "You cannot add virtual rooms as an external site";
            }
            else
            {
                document.getElementById('viju_ext_help').innerHTML = "";
                textBox4.value = '&ext=' + externalSite.value; 
            }
        }
        else
        {
            textBox4.value = ""; 
        }

        // Show or hide the save buttondepending on validation
        if ( notValid )
        {
            document.getElementById('Viju_SaveBtn').style.display = 'none';
        }
        else
        {
            document.getElementById('Viju_SaveBtn').style.display = 'inline';
        }

        if ( !extCheckBox.checked ) 
        {
            document.getElementById('viju_external_field_wrapper').style.display = 'none';
        }
        else
        {
            document.getElementById('viju_external_field_wrapper').style.display = 'inline';
        }
    }

    function viju_setTextFields()
    {
        var textBox1 = document.getElementById('ctl00_placeholderMain__welcomeText1');
        var textBox2 = document.getElementById('ctl00_placeholderMain__welcomeText2');
        var textBox3 = document.getElementById('ctl00_placeholderMain__welcomeText3');
        var textBox4 = document.getElementById('ctl00_placeholderMain__welcomeText4');
        var subjectBox = document.getElementById('ctl00_placeholderMain_txtSubject');
        var roomType = document.getElementById('viju_teacher_option');
        var code = document.getElementById('viju_code');
        var pin = document.getElementById('viju_pin');
        var externalSite = document.getElementById('viju_external_site');
        var extCheckBox = document.getElementById('viju_ext_checkbox');
        var temp;
        var notValid = false;
        var charIndex;

        //look for an adHoc lesson
        charIndex = subjectBox.value.indexOf('&pin=')

        //if there is an adhoc lesson
        if ( charIndex != -1 )
        {
            //get attributes of the meeting
            temp = subjectBox.value.substring(charIndex, subjectBox.value.length)
            
            var idx1 = temp.indexOf('&pin=');
            var idx2 = temp.indexOf('&code=');
            var idx3 = temp.indexOf('&type=');

            textBox2.value = temp.substring(idx1,idx2);

            textBox1.value = temp.substring(idx3);

            textBox3.value = temp.substring(idx2,idx3);

            //create new subject
            subjectBox.value  = subjectBox.value.substring(0, charIndex );
        }

        temp = textBox1.value;
        temp = temp.replace( '&type=','');
        roomType.selectedIndex = temp;
        
        temp = textBox2.value;
        temp = temp.replace( '&pin=','');
        pin.value = temp;

        temp = textBox3.value;
        temp = temp.replace( '&code=','');
        code.value = temp;

        if ( textBox4.value != '')
        {
            temp = textBox4.value;
            temp = temp.replace( '&ext=','');
            externalSite.value = temp;
            
            extCheckBox.checked = true;
        }
        
    }

    function viju_hideUnusedPanels()
    {
        document.getElementById('divPanelDisplay').style.display = 'none';
        document.getElementById('divMacros').style.display = 'none';
        document.getElementById('Viju_SaveBtn').style.display = 'none';

        //Validate Lesson Info
        Viju_updateLessonInfo()
    }

  </script>

  <table border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td align="left" class="AMXHeaderCtrl_TopSpacer" colspan="1" style="font-size: 8pt;font-family: Arial">
      </td>
    </tr>
    
    <tr>
      <td align="left" colspan="1" style="font-size: 8pt; font-family: Arial">
        <AMX:Header ID="Header1" runat="server" HeaderText="Appointment Details" Width="100%" meta:resourcekey="Header1Resource1">
          <ControlToolboxTemplate>
            <uc1:defaultnavtoolbar ID="Defaultnavtoolbar1" runat="server" />
          </ControlToolboxTemplate>
        </AMX:Header>
      </td>
    </tr>

    <tr>
      <td align="center" class="AMXHeaderCtrl_Content" colspan="1" style="font-size: 8pt;font-family: Arial">
          <asp:Panel ID="panelAppointment" runat="server" >
          <table border="0" class="" cellpadding="0" cellspacing="0">
          <tr>
            <td style="width: 400px;" valign="top">
          
              <!---------  Appointment Details : START --------->
              <div id="divAppointmentDetails" style="padding-bottom: 5px; padding-top: 5px"> 
                <table id="tableAppointmentDetails" border="0" class="TAB_Content" cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="property_table_header" align="center" colspan="2">
                            <asp:Label ID="lblAppointmentDetails" runat="server" Text="Appointment Details" meta:resourcekey="lblAppointmentDetailsResource1" ></asp:Label></td>
                    </tr>              
                    
                    <!---------  Room Selection : START --------->
                    <tr>
                        <td class="property_table_caption" style="padding-top: 10px;" valign="top">
                            <asp:Label ID="lblRoomCaption" runat="server" Text="Room:" meta:resourcekey="lblRoomCaptionResource1"></asp:Label></td>
                        <td class="property_table_value">                            
                            <table border="0" cellpadding="0" cellspacing="0" width="270">
                                <tr>
                                    <td>
                                        <uc4:roomselect ID="roomselectctrl" runat="server" />
                                    </td>
                                    <td>
                                       <asp:Label ID="lblRoomWarn" runat="server"  Visible = "false" Text="The room is not set." meta:resourcekey="lblRoomWarn" />
                                    </td>
                                    <td style="text-align: right; height: 10px; padding-top: 0px; padding-bottom: 0px;" align="right"  valign="top" >
                                        <asp:LinkButton ID="btnSearch" runat="server" Font-Names="Arial" Font-Size="8pt" OnClick="btnRoomSearch_Click" meta:resourcekey="btnSearchResource1" Text="Search"></asp:LinkButton>
                                    </td>
                                </tr>
                            </table>                            
                        </td>
                    </tr>
                    <!---------  Room Selection : END --------->
                    
                    <!---------  Scheduled By : START --------->
                    <tr>
                      <td class="property_table_caption">
                          <asp:Label ID="lblOrganizerCaption" runat="server" Text="Scheduled By:" meta:resourcekey="lblOrganizerCaptionResource1" /></td>
                      <td class="property_table_value">
                       <AMX:RestrictedTextBox ID="txtOrganizer" runat="server" Columns="64" InputRegularExpression="[^<>|+]" MaxLength="100" Width="270px" meta:resourcekey="txtOrganizerResource1"/></td>
                    </tr>
                    <!---------  Scheduled By : END --------->
                    
                    <!---------  Attendees : START --------->
                    <tr>
                      <td class="property_table_caption">
                          <asp:Label ID="lblAttendeesCaption" runat="server" Text="Attendees:" meta:resourcekey="lblAttendeesCaptionResource"  Visible="false"/></td>
                          <td class="property_table_value">
                          <AMX:RestrictedTextBox ID="txtAttendees" runat="server" InputRegularExpression="[^@<>|+]" TextMode="MultiLine" Rows="5" Columns="49" Width="270px" Visible="false" /></td>                          
                    </tr>
                    <!---------  Attendees : END --------->
                    
                    <!---------  Subject : START --------->
                    <tr>
                      <td class="property_table_caption">
                          <asp:Label ID="lblSubjectCaption" runat="server" Text="Subject:" meta:resourcekey="lblSubjectCaptionResource1" /></td>
                      <td class="property_table_value">
                          <AMX:RestrictedTextBox ID="txtSubject" runat="server" InputRegularExpression="[^<>|+]" Columns="64" MaxLength="255" Width="270px" meta:resourcekey="txtSubjectResource1" /></td>
                    </tr>
                    <!---------  Subject : END --------->
                    
                    <!---------  Message : START --------->
                    <tr>
                      <td class="property_table_caption">
                          <asp:Label ID="lblMessageCaption" runat="server" Text="Message:" meta:resourcekey="lblMessageCaptionResource1" /></td>
                      <td class="property_table_value">
                          <AMX:RestrictedTextBox ID="txtMessage" runat="server" TextMode="MultiLine" InputRegularExpression="[^@<>|+]" Rows="5" Columns="49" Width="270px" meta:resourcekey="txtMessageResource1" /></td>
                    </tr>
                    <!---------  Message : END --------->
                    
                    <tr>
                      <td colspan="2" style="height: 10px">
                      </td>
                    </tr>
                </table>             
            </div>  
            <!---------  Appointment Details : END --------->
              
              
            <!---------  Appointment Time : START --------->
            <div id="div1" style="padding-bottom: 5px; padding-top: 5px"> 
                <table border="0" cellpadding="0" cellspacing="0" style="width: 100%" class="TAB_Content">
                    <tr>
                        <td class="property_table_header" align="center" colspan="2">
                            Hello
							<asp:Label ID="lblAppointmentTime" runat="server" Text="Appointment Times" meta:resourcekey="lblAppointmentTimeResource1"></asp:Label></td>
                    </tr>
                    <tr>
                                        
                        <!---------  Start Date/Time : START --------->
                        <td class="property_table_caption">
                          <asp:Label ID="lblStartTimeCaption" runat="server" Text="Start Time:" meta:resourcekey="lblStartTimeCaptionResource1" /></td>
                        <td class="property_table_value">
                          <table border="0" cellpadding="0" cellspacing="0">
                              <tr>
                              <td onmouseup="FromButton_OnMouseUp()">
                                <ComponentArt:Calendar ID="pickerStart"
                                                       SkinId="None"
                                                       AllowMultipleSelection="False"
                                                       runat="server"
                                                       PickerFormat="Short"
                                                       ControlType="Picker"
                                                       ClientSideOnSelectionChanged="FromPicker_OnDateChange"
                                                       PickerCssClass="picker" 
                                                       />
                
                              </td>
                              <td style="padding-right: 16px; padding-left: 2px; padding-bottom: 0px; padding-top: 7px;" align="left">
                                <img id="imgCalendarStart" alt="" onclick="FromButton_OnClick()" onmouseup="FromButton_OnMouseUp()" style="cursor:pointer" src="../App_Themes/MeetingManager/images/icon/calendar.gif"/>
                              </td>
                              <td nowrap="nowrap">
                                <asp:DropDownList ID="ddlHourStart" runat="server" >
                                </asp:DropDownList>
                                            
                                <asp:DropDownList ID="ddlMinuteStart" runat="server" >
                                </asp:DropDownList>
                                
                                <asp:DropDownList ID="ddlAMPMStart" runat="server" >
                                </asp:DropDownList>
                              </td>
                              </tr>
                          </table>
                        </td>
                    </tr>
                    <!---------  Start Date/Time : END  --------->
            
            
                    <!---------  End Date/Time : START --------->            
                    <tr>
                        <td class="property_table_caption">
                          <asp:Label ID="lblEndTimeCaption" runat="server" Text="End Time:" meta:resourcekey="lblEndTimeCaptionResource1"/></td>
                        <td class="property_table_value">
                          <table border="0" cellpadding="0" cellspacing="0">
                            <tr>
                              <td onmouseup="ToButton_OnMouseUp()">
                                <ComponentArt:Calendar id="pickerEnd"
                                                       SkinID="NONE"
                                                       AllowMultipleSelection="False"                                                        
                                                       runat="server"
                                                       PickerFormat="Short"
                                                       ControlType="Picker"
                                                       ClientSideOnSelectionChanged="ToPicker_OnDateChange"
                                                       PickerCssClass="picker" 
                                                       Width="200px" 
                                                       />                    
                                
                              </td>
                              <td style="padding-right: 16px; padding-left: 2px; padding-bottom: 0px; padding-top: 7px;">
                                <img id="imgCalendarEnd" alt="" onclick="ToButton_OnClick()" onmouseup="ToButton_OnMouseUp()" style="cursor:pointer" src="../App_Themes/MeetingManager/images/icon/calendar.gif" />                                    
                              </td>
                              <td nowrap="nowrap">
                                <asp:DropDownList ID="ddlHourEnd" runat="server" >
                                </asp:DropDownList>                                    
                                <asp:DropDownList ID="ddlMinuteEnd" runat="server" >
                                </asp:DropDownList>                                    
                                <asp:DropDownList ID="ddlAMPMEnd" runat="server" >
                                </asp:DropDownList>
                              </td>
                            </tr>
                          </table>
                        </td>
                    </tr>
                    <!---------  End Date/Time : END  --------->
                    <tr>
                        <td colspan="2" style="height: 10px">
                        </td>
                    </tr>
                </table>
            </div>
            <!---------  Appointment Time : STOP --------->        
              
              
            <!---------  Appointment Password : START --------->
            <asp:Panel ID="panelAppointmentPassword" runat="server" Visible="False" >            
                <div id="divAppointmentPassword" style="padding-bottom: 5px; padding-top: 5px">
                    <table border="0" class="TAB_Content" cellpadding="0" cellspacing="0">
                        <tr>
                            <td class="property_table_header" align="center" colspan="2">
                                <asp:Label ID="lblAppointmentPassword" runat="server" Text="Appointment Password" meta:resourcekey="lblAppointmentPasswordResource1"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td class="property_table_caption">
                                <asp:Label ID="lblPasswordCaption" runat="server" Text="Password:" meta:resourcekey="lblPasswordCaptionResource1" />
                            </td>
                            <td class="property_table_value">
                                <asp:TextBox ID="txtPassword" runat="server" Columns="20" MaxLength="16" TextMode="Password" Width="270px" meta:resourcekey="txtPasswordResource1" />
                            </td>
                        </tr>
                        <tr>
                            <td align="center" colspan="2" style="height: 10px">
                            </td>
                        </tr>
                    </table>
                </div>
         
            
                </asp:Panel><asp:Panel ID="panelRecurring" runat="server" Width="100%" >
                    <div id="Div2" style="padding-bottom: 1px; padding-top: 1px">
                        <table border="0" class="TAB_Content" cellpadding="0" cellspacing="0">
                            <tr>
                                <td class="property_table_header" align="center" colspan="2">
                                <asp:Label ID="lblRecurringCaption" runat="server" Text="Recurring" meta:resourcekey="lblRecurringCaptionResource1"/>&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="property_table_caption" style="height: 24px" colspan="2">
                                    <uc1:AppointmentRecurrence ID="_appointmentRecurrence" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td align="center" colspan="2" style="height: 10px">
                                </td>
                            </tr>
                        </table>
                    </div>
                </asp:Panel>
                    &nbsp;
            <!---------  Appointment Password : END --------->
                   
                    
     
            </td>
            <td style="width: 10px;" nowrap="nowrap"></td>        
            <td valign="top">
                <asp:Panel ID="panelControlSystemFeatures" runat="server" Width="400px">
                    
                    <asp:Panel ID="panelAutomationControl" runat="server">
                    
                        <!---------  Automation Control : START --------->
                        <div id="divMacros" style="padding-bottom: 5px; padding-top: 5px">                                        
                            <table id="tableMacros" border="0" class="TAB_Content" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td class="property_table_header" align="center" colspan="2">
                                        <asp:Label ID="lblAutomationControl" runat="server" Text="Automation Control" meta:resourcekey="lblAutomationControlResource1"></asp:Label>
                                    </td>
                                </tr>
                                
                                <!---------  Macro Execution Option : START --------->
                                <tr>
                                    <td class="property_table_caption">
                                        <asp:Label ID="lblMacroExecutionCaption" runat="server" Text="Execution:" meta:resourcekey="lblMacroExecutionCaptionResource1" />
                                    </td>
                                    <td class="property_table_value">
                                        <asp:RadioButton ID="rdoMacroExecuteManually" GroupName="MacroExecution" runat="server" Text="Upon user confirmation at start of meeting." meta:resourcekey="rdoMacroExecuteManuallyResource1" /><br />
                                        <asp:RadioButton ID="rdoMacroExecuteAutomatically" GroupName="MacroExecution" runat="server" Text="Automatically executes at the start of meeting." meta:resourcekey="rdoMacroExecuteAutomaticallyResource1" Checked="True" />
                                    </td>
                                </tr>
                                <!---------  Macro Execution Option : END --------->
                                
                                <!---------  Macro Selection : START --------->
                                <tr>
                                    <td class="property_table_caption">
                                        <asp:Label ID="lblMacroEventCaption" runat="server" Text="Event:" meta:resourcekey="lblMacroEventCaptionResource1" />
                                    </td>
                                    <td class="property_table_value">
                                        <asp:DropDownList ID="ddlMacros" runat="server" Width="270px" >
                                        </asp:DropDownList></td>
                                </tr>
                                <!---------  Macro Selection : END --------->
                                
                                <tr>
                                    <td align="center" colspan="2" style="height: 10px">
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <!---------  Automation Control : END --------->          
                    </asp:Panel>
                    <asp:Panel ID="panelWelcome" runat="server">
                    
                        
                        <!---------  VIJU Lesson Information : START --------->
                        <div id="div3" style="padding-bottom: 5px; padding-top: 5px">
                            <table id="table1" border="0" class="TAB_Content" cellpadding="0" cellspacing="0" style="width: 400px">
                                <tr>
                                    <td class="property_table_header" align="center" colspan="2">
                                       Lesson Information
                                    </td>
                                </tr>
                                <tr>
                                    <td class="property_table_caption">
                                        Room Type:
                                    </td>
                                    <td class="property_table_value">
                                        <select id="viju_teacher_option" onchange="Viju_updateLessonInfo()">
                                             <option value="0" selected="selected">None</option>
                                             <option value="1">Teacher</option>
                                             <option value="2">Student</option>
                                             <option value="2">Virtual</option>
                                        </select>
                                    </td>
                                    <td class="property_table_caption">
                                        <span style="color: #f00" id="viju_type_help"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="property_table_caption">
                                        Pin Number:
                                    </td>
                                    <td class="property_table_value">
                                        <input onchange="Viju_updateLessonInfo()" type="text" id="viju_pin" />
                                    </td>
                                    <td class="property_table_caption">
                                        <span style="color: #f00" id="viju_pin_help"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="property_table_caption">
                                        Lesson Code:
                                    </td>
                                    <td class="property_table_value">
                                        <input onchange="Viju_updateLessonInfo()" type="text" id="viju_code" /> 
                                    </td>
                                    <td class="property_table_caption">
                                        <span style="color: #f00" id="viju_code_help"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="property_table_caption">
                                        External Site:
                                    </td>
                                    <td class="property_table_value">
                                        <input OnClick="Viju_updateLessonInfo()" id="viju_ext_checkbox" type="checkbox" name="viju_externalCheck" value="1"> 
                                    </td>
                                </tr>
                                <tr id="viju_external_field_wrapper">
                                    <td class="property_table_caption">
                                        External Site IP/SIP Address:
                                    </td>
                                    <td class="property_table_value">
                                        <input onchange="Viju_updateLessonInfo()" type="text" id="viju_external_site" /> 
                                    </td>
                                    <td class="property_table_caption">
                                        <span style="color: #f00" id="viju_ext_help"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        External sites cannot be added to classes with virtual rooms.  Please instruct the external site to dial the virtual room when the lesson begins.
                                    </td>
                                </tr>
                             </table>
                        </div>
                        <!---------  VIJU Lesson Information : END --------->
                        
                        
                        
                        
                        <!---------  Panel Display : START --------->
                        <div id="divPanelDisplay" style="padding-bottom: 5px; padding-top: 5px">
                            <table id="tablePanelDisplay" border="0" class="TAB_Content" cellpadding="0" cellspacing="0" style="width: 400px">
                                <tr>
                                    <td class="property_table_header" align="center" colspan="2">
                                       <asp:Label ID="lblPanelDisplay" runat="server" Text="Panel Display" meta:resourcekey="lblPanelDisplayResource1"></asp:Label>
                                    </td>
                                </tr>
                                
                                

                               
                                <!---------  Display Text : START --------->
                                <tr>
                                    <td class="property_table_caption" style="height: 120px">
                                        <asp:Label ID="lblDisplayTextCaption" runat="server" Text="Display Text:" meta:resourcekey="lblDisplayTextCaptionResource1" />
                                    </td>
                                    <td class="property_table_value" style="height: 120px">

                                        
                                                                              
                                        <AMX:RestrictedTextBox ID="_welcomeText1" runat="server" Columns="64" MaxLength="255" Width="270px" InputRegularExpression="[^@<>|+]" meta:resourcekey="txtSubjectResource1" /><br />
                                        <AMX:RestrictedTextBox ID="_welcomeText2" runat="server" Columns="64" InputRegularExpression="[^@<>|+]"  MaxLength="255" Width="270px" meta:resourcekey="txtSubjectResource1" /><br />
                                        <AMX:RestrictedTextBox ID="_welcomeText3" runat="server" Columns="64" InputRegularExpression="[^@<>|+]"  MaxLength="255" Width="270px" meta:resourcekey="txtSubjectResource1" /><br />
                                        <AMX:RestrictedTextBox ID="_welcomeText4" runat="server" Columns="64" InputRegularExpression="[^@<>|+]"  MaxLength="255" Width="270px" meta:resourcekey="txtSubjectResource1" /><br />
                                        <AMX:RestrictedTextBox ID="_welcomeText5" runat="server" Columns="64" InputRegularExpression="[^@<>|+]"  MaxLength="255" Width="270px" meta:resourcekey="txtSubjectResource1" /></td>
                                
                                        <script type="text/javascript">
                                            viju_setTextFields();
                                        </script>
                                </tr>
                                <!---------  Display Text : END --------->
                                
                                <!---------  Display Image Selection : START --------->
                                <tr>
                                    <td class="property_table_caption">
                                        <asp:Label ID="lblDisplayImageCaption" runat="server" Text="Display Image:" meta:resourcekey="lblDisplayImageCaptionResource1" />
                                    </td>
                                    <td class="property_table_value">
                                        <asp:DropDownList ID="ddlDisplayImage" runat="server" Width="270px" OnChange="javascript:GetPreviewImage(this.value);" >
                                        </asp:DropDownList></td>
                                </tr>
                                <!---------  Display Image Selection : END --------->
                                
                                
                                <!---------  Upload Image : START --------->
                                <tr>
                                    <td class="property_table_caption">
                                    </td>
                                    <td align="right" class="property_table_value" style="padding-right: 35px;">
                                        <asp:HyperLink ID="linkUploadImage" NavigateUrl="Javascript:DisplayUpload();" runat="server" meta:resourcekey="linkUploadImageResource1">Upload Image</asp:HyperLink></td>
                                <!---------  Upload Image : END --------->
                                
                                
                                <!---------  Display Image Preview : START --------->
                                </tr>
                                <tr>
                                    <td align="center" colspan="2" style="height: 10px">
                                        <asp:Panel ID="panelWelcomeImage" runat="server">
                                        <ComponentArt:MultiPage SkinID="None" BorderStyle="None" ID="multipageDisplayImage" runat="server" SelectedIndex="0" Width="350px" >                                
                                            <ComponentArt:PageView ID="pageDisplayImagePreview" runat="server" Width="350px">
                                                <center>
                                                <ComponentArt:CallBack
                                                    ID="callbackDisplayImage"
                                                    runat="server"                        
                                                    Width="100%"
                                                    OnCallback="DisplayImage_Callback"
                                                    PostState="True" >
                                                  <Content>
                                                    <asp:Image ID="imgDisplayImage" runat="server" GenerateEmptyAlternateText="true" AlternateText="No Image Selected" ImageUrl="~/App_Themes/MeetingManager/images/icon/nophoto.gif" meta:resourcekey="imgDisplayImageResource1" Height="350" Width="350"/>
                                                  </Content>
                                                </ComponentArt:CallBack>                                
                                                </center>          
                                            </ComponentArt:PageView>
                                            <ComponentArt:PageView ID="pageDisplayImageUpload" runat="server">                                    
                                                <table id="tableDisplayImageUpload" border="0" class="TAB_Content" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="property_table_header" align="center" colspan="2">
                                                            <asp:Label ID="lblImageUploadCaption" runat="server" Text="Select panel display image file:" meta:resourcekey="lblImageUploadCaptionResource1"></asp:Label>
                                                        </td>
                                                    </tr>              
                                                    <tr>
                                                        <td align="center">
                                                            <asp:FileUpload ID="fileUploadDisplayImage"  runat="server" Width="270px" meta:resourcekey="fileUploadDisplayImageResource1"/><br />                                                
                                                        </td>
                                                    </tr>                  
                                                    <tr>
                                                        <td align="center" class="property_table_footer" colspan="3">
                                                            <asp:Button ID="btnUpload" runat="server" Text="Upload" Width="75px" OnClientClick="Javascript:DisplayImagePreview();" OnClick="btnUpload_Click" meta:resourcekey="btnUploadResource1" />
                                                            &nbsp
                                                            <asp:Button ID="btnUploadCancel" runat="server" Text="Cancel" Width="75px" OnClientClick="Javascript:DisplayImagePreview(); return false;" meta:resourcekey="btnUploadCancelResource1" />
                                                        </td>
                                                    </tr>                                                                           
                                                </table>                                                                    
                                            </ComponentArt:PageView>
                                        </ComponentArt:MultiPage>
                                        </asp:Panel>
                                    </td>
                                </tr>
                                <!---------  Display Image Preview : END --------->
                                
                                <tr>
                                    <td align="center" colspan="2" style="height: 10px">
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <!---------  Panel Display : END --------->
                    </asp:Panel>
                </asp:Panel>            
              </td>
            </tr>
            <tr>
                <td align="center" colspan="3">
                  <asp:Panel ID="_buttonPanel" runat="server" Width="300px" >
                    <div id="Viju_SaveBtn">
                      <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="SaveChanges" OnClientClick="return TimeCheck();" meta:resourcekey="btnCancelResource1" Width="75px" />
                    </div>
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="CancelChanges" meta:resourcekey="btnSaveResource1" Width="75px" />
                    <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClick="DeleteChanges" OnClientClick="return VerifyDelete();" meta:resourcekey="btnDeleteResource1" Visible="false" Width="75px" />
                 </asp:Panel>
                </td>
            </tr>
        </table>
      </asp:Panel>  
         
      <asp:Panel ID="_appointmentPanel" runat="server" Visible="False" >
        <table border="0" cellpadding="0" cellspacing="0" class="TAB_Content" id="_tableAppointment">

          <!---                                         ---->
          <!--- Appointment details and times DIV BEGIN ---->
          <!---                                         ---->
          <!---                                       ---->
          <!--- Appointment details and times DIV END ---->
          <!---                                       ---->
          
          <!---                               ---->
          <!--- System preset setup DIV BEGIN ---->
          <!---                               ---->
          <tr>
            <td colspan="2" style="padding:0px">
              <asp:Panel ID="_appointmentPresetPanel" runat="server" >
                <table class="GRID_GridHeaderText" border="0" cellpadding="2" width="100%" style="font-size:8pt;font-family:Arial;">
                  <tr>
                    <td colspan="2" style="padding:0px">
                      <uc1:AppointmentPresetConfiguration ID="_appointmentPresetConfiguration" runat="server" />
                    </td>
                  </tr>
                </table>
              </asp:Panel>
            </td>
          </tr>
          
          <!---                               ---->
          <!--- System preset setup DIV END ---->
          <!---                               ---->

          <!---                                   ---->
          <!--- Appointment panel setup DIV BEGIN ---->
          <!---                                   ---->
          <!---                                 ---->
          <!--- Appointment panel setup DIV END ---->
          <!---                                 ---->

          <!---- OK/Cancel buttons definition BEGIN ---->
          <!---- OK/Cancel buttons definition END ---->
                  
          </table>
        </asp:Panel>
        <asp:Panel ID="panelPasswordEntry" runat="server" Visible="False" Width="350px" >
            <br />
           <table border="0" cellpadding="0" cellspacing="0" class="TAB_Content" id="passwordTable">
              <tr>
                <td class="TAB_ContentRow" style="height: 10px">
                </td>
              </tr>
              
              <!---- password caption BEGIN ---->              
              <tr>
                <td class="TAB_ContentRow" style="height: 50px" colspan="2">
                    <asp:Label ID="lblPasswordEntryCaption" runat="server" Font-Names="Arial" Font-Size="10pt" ForeColor="#404040" meta:resourcekey="lblPasswordEntryCaptionResource1">This appointment is password protected.  Please enter the appointment password to view this appointment:</asp:Label>
                </td>
              </tr>
              <!---- password caption END ---->

              <!---- password text entry BEGIN ---->              
              <tr>
                <td class="TAB_ContentRow" style="height: 50px" colspan="2" align="right">
                    <asp:TextBox ID="txtPasswordEntry" TextMode="Password" runat="server" Width="200px" meta:resourcekey="txtPasswordEntryResource1"></asp:TextBox>
                    &nbsp;
                    <asp:Button ID="btnPasswordEntrySubmit" runat="server" Text="Enter" meta:resourcekey="btnPasswordEntrySubmitResource1" OnClick="btnPasswordEntrySubmit_Click" />&nbsp;&nbsp;
                    &nbsp;</td>                
              </tr>
              <!---- password text entry END ---->
              
           </table>              
            </asp:Panel>
          &nbsp; &nbsp;
        </td>
      </tr>
    </table>
    
    <asp:HiddenField ID="_needUserInput" runat="server" Value="0" />
    <asp:HiddenField ID="_conflictingUserQuery" runat="server" />
    <asp:HiddenField ID="_overrideConflicting" runat="server" Value="0" />

    
    <!---- Start time definition BEGIN ---->
    <ComponentArt:Calendar runat="server"
                         id="calendarStart"
                         AllowMultipleSelection="False"
                         AllowWeekSelection="False"
                         AllowMonthSelection="False"
                         AllowDaySelection="True"
                         PopUp="Custom"
                         PopUpExpandControlId="imgCalendarStart"
                         Width="150px"
                         ClientSideOnSelectionChanged="FromCalendar_OnDateChange" 
                         meta:resourcekey="calendarStartResource1" />
    <!---- Start time definition END ---->


    <!---- End time definition BEGIN ---->
    <ComponentArt:Calendar runat="server"
                         id="calendarEnd"
                         AllowMultipleSelection="False"
                         AllowWeekSelection="False"
                         AllowMonthSelection="False"
                         AllowDaySelection="True"
                         PopUp="Custom"
                         PopUpExpandControlId="imgCalendarEnd"
                         Width="150px"
                         ClientSideOnSelectionChanged="ToCalendar_OnDateChange" 
                         meta:resourcekey="calendarEndResource1" />
    <!---- End time definition END ---->    
</asp:Content>
      
