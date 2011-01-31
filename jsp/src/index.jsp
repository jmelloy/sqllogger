<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.ArrayList' %>
<%@ page import = 'java.util.StringTokenizer' %>
<%@ page import = 'java.util.regex.Pattern' %>
<%@ page import = 'java.util.regex.Matcher' %>
<%@ page import = 'java.net.URLEncoder' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.visualdistortion.util.Util' %>
<%@ page import = 'org.visualdistortion.sqllogger.*' %>
<%@ page import = 'java.util.Enumeration' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/index.jsp $-->
<!--$Rev: 1076 $ $Date: 2005-05-20 08:47:43 -0500 (Fri, 20 May 2005) $ -->

<%

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");

boolean showDisplay = true;
boolean showMeta = false;
boolean advanced = Boolean.valueOf(request.getParameter("advanced")).booleanValue();

Date today = new Date(System.currentTimeMillis());
int item_id = Util.checkInt(request.getParameter("item_id"));
int meta_id = Util.checkInt(request.getParameter("meta_id"));
int message_id = Util.checkInt(request.getParameter("message_id"));

String formURL = new String();

Enumeration e = request.getParameterNames();
HashMap h = new HashMap();

while(e.hasMoreElements()) {
    String key = (String) e.nextElement();
    String value = Util.checkNull(request.getParameter(key));
    h.put(key, value);

    if(value != null && !key.equals("advanced")) {
        formURL += "&amp;" + key + "=" + value;
    }
}

String advURL = new String();
if(!advanced) advURL = new String("index.jsp?advanced=true");
else advURL = new String("index.jsp?advanced=false");

advURL += formURL;

String form = new String("saveForm.jsp?action=saveForm&amp;type=chat");

formURL = form + formURL;

ArrayList hlWords = new ArrayList();
String hl = (String) h.get("hl");

String title = new String("");
String notes = new String("");

if (hl != null) {
    hl = hl.trim();
    StringTokenizer st = new StringTokenizer(hl, " ");
    while (st.hasMoreTokens()) {
        hlWords.add(st.nextToken());
    }
}

String screenDisplayMeta = (String) h.get("screen_or_display");
if(screenDisplayMeta != null && screenDisplayMeta.equals("screen")) {
    showDisplay = false;
} else if (screenDisplayMeta != null && screenDisplayMeta.equals("meta")) {
    showMeta = true;
    showDisplay = false;
}

if(meta_id != 0) {
    showMeta = true;
    showDisplay = false;
}

String hlColor[] = {"#ff6","#a0ffff", "#9f9", "#f99", "#f69"};

MessageFormatter.clearUsers();

ResultSet rset = null;
ResultSet noteSet = null;

Map paramMap = new HashMap();

try {

   if(item_id != 0) {

        paramMap.put("item_id", new Integer(item_id));

        rset = lc.executeQuery("saved_fields", paramMap);

        while(rset.next()) {
            title = rset.getString("title");
            notes = rset.getString("notes");

            h.put(rset.getString("field_name"), rset.getString("value"));

            if( h.get("meta_id") != null && !((String)h.get("meta_id")).equals("0")) {
                showMeta = true;
                showDisplay = false;
            }
        }
    } else {
        title = "SQL Logger";
    }

    if(message_id != 0) {

        paramMap.put("afterTime", new Integer(Util.checkInt((String) h.get("aTime"), 45)));
        paramMap.put("beforeTime", new Integer(Util.checkInt((String) h.get("bTime"), 15)));
        paramMap.put("message_id", new Integer(message_id));

        rset = lc.executeQuery("message_times", paramMap);

        if(rset.next()) {
            h.put("dateStart", rset.getString("start"));
            h.put("dateFinish",  rset.getString("finish"));
        }
    }

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: Message Viewer</title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="styles/layout.css" />
<link rel="stylesheet" type="text/css" href="styles/default.css" />
<link rel="stylesheet" type="text/css" href="styles/message.css" />
<script language = "JavaScript">
    window.name='viewer';
</script>
<script language="JavaScript" src="calendar.js"></script>
<script language="JavaScript" src="ac.js"></script>
</head>
<body>
    <div id="container">
        <div id="header">
        </div>
        <div id="banner">
            <div id="bannerTitle">
                <img class="adiumIcon" src="images/headlines/index.png" width="128" height="128" border="0" alt="SQL Logger: Viewer" />
                <div class="text">
                    <h1><%= title %></h1>
                    <p><%= notes %></p>
                </div>
            </div>
        </div>
        <div id="central">
            <div id="navcontainer">
                <ul id="navlist">
                    <li><span id="current">Viewer</span></li>
                    <li><a href="search.jsp">Search</a></li>
                    <li><a href="users.jsp">Users</a></li>
                    <li><a href="meta.jsp">Meta-Contacts</a></li>
                    <li><a href="chats.jsp">Chats</a></li>
                    <li><a href="statistics.jsp">Statistics</a></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="sidebar-a">
    <%
    if (hl != null) {
        out.print("<h1>Search Words</h1>");
        out.println("<div class=\"boxThinTop\"></div>\n");
        out.println("<div class=\"boxThinContent\">");
        for (int i = 0; i < hlWords.size(); i++) {
            out.print("<p><b style=\"color:black;" +
                "background-color:" + hlColor[i % hlColor.length] +
                "\">" + hlWords.get(i).toString() + "</b></p>\n");
        }
        out.println("</div>\n");
        out.println("<div class=\"boxThinBottom\"></div>\n");
    }

    boolean unconstrained = false;

    if(h.get("dateStart") != null && h.get("dateFinish") == null) unconstrained = true;

    if(unconstrained) {
        out.print("<div align=\"center\"><i>Limited to 250 " +
        "messages.</i><br><br></div>\n");
    }

    out.println("<h1>Users</h1>");
    out.println("<div class=\"boxThinTop\"></div>\n");
    out.println("<div class=\"boxThinContent\">");

    try {
        paramMap.put("startDate", h.get("dateStart"));
        paramMap.put("endDate", h.get("dateFinish"));

        rset = lc.executeQuery("date_range_users", paramMap);

        while(rset.next()) {
            out.print("<p>" +
                "<a href=\"index.jsp?dateStart=" + Util.safeString((String) h.get("dateStart")) +
                "&amp;dateFinish=" + Util.safeString((String) h.get("dateFinish")) + "&amp;service=" +
                rset.getString("service") + "\">" +
                "<img src=\"images/services/" +
                rset.getString("service").toLowerCase() +
                ".png\" width=\"12\" height=\"12\" alt=\"" +
                rset.getString("service") +"\"/></a> " +
                "<a href=\"index.jsp?dateStart=" + Util.safeString((String) h.get("dateStart")) +
                "&amp;dateFinish=" + Util.safeString((String) h.get("dateFinish")) + "&amp;contains=" +
                rset.getString("username") + "\">"+
                rset.getString("username") + "</a></p>\n");
        }

        out.print("<a href=\"index.jsp?dateStart=" + Util.safeString((String) h.get("dateStart")) +
            "&amp;finish=" + Util.safeString((String) h.get("dateFinish")) + "\"><i>All</i></a>");
    } catch (SQLException err) {
        out.print("<span style=\"color: red\">" + err.getMessage() + "</span>");
    }

    out.println("</div>\n");
    out.println("<div class=\"boxThinBottom\"></div>\n");

    out.println("<h1>Saved Chats</h1>");
    out.println("<div class=\"boxThinTop\"></div>\n");
    out.println("<div class=\"boxThinContent\">");

    paramMap.put("type", "chat");
    rset = lc.executeQuery("saved_items_list", paramMap);

    while(rset.next()) {
        out.println("<p><a href=\"index.jsp?item_id=" + rset.getInt("item_id") +
            "\">" + rset.getString("title") + "</a></p>");
    }
    out.println("<p></p>");
    %>
        <p><a href="#"
                onClick="window.open('<%= formURL %>', 'Save Chat', 'width=275,height=225')">
                Save Chat ...
            </a></p>
    <%
    out.println("</div>\n");
    out.println("<div class=\"boxThinBottom\"></div>\n");

    out.println("<h1>Links</h1>");
    out.println("<div class=\"boxThinTop\"></div>\n");
    out.println("<div class=\"boxThinContent\">");
%>

                <p><a href="#"
                onClick="window.open('urls.jsp?start=<%=Util.safeString((String) h.get("dateStart"), today.toString()) %>&amp;finish=<%= Util.safeString((String) h.get("dateFinish")) %>', 'Save Chat', 'width=640,height=480')">Recent Links</a></p>

                <p><a href="#"
                onClick="window.open('simpleViewer.jsp?start=<%= Util.safeString((String) h.get("dateStart")) %>&amp;finish=<%= Util.safeString((String) h.get("dateFinish")) %>&amp;from=<%= URLEncoder.encode(Util.safeString((String) h.get("sender")), "UTF-8")  %>&amp;to=<%= URLEncoder.encode(Util.safeString((String) h.get("recipient")), "UTF-8")  %>&amp;contains=<%= URLEncoder.encode(Util.safeString((String) h.get("contains")), "UTF-8") %>&amp;screen_or_display=<%= screenDisplayMeta %>&amp;meta_id=<%=meta_id%>&amp;item_id=<%=item_id%>', 'Save Chat', 'width=640,height=480')">Simple Message View</a></p>
<%
    out.println("</div>\n");
    out.println("<div class=\"boxThinBottom\"></div>\n");
%>
            </div>
            <div id="content">
            <h1>View Messages by Date</h1>

            <div class="boxWideTop"></div>
            <div class="boxWideContent">
            <form action="index.jsp" method="get" name="control">
                <table border="0" cellpadding="3" cellspacing="0">
<%  if(advanced) { %>
                <tr>
                    <td align="right">
                        <label for="from">Sent SN: </label></td>
                    <td>
                        <input type="text" name="sender" autocomplete="off"
                            value="<%= Util.safeString((String) h.get("sender")) %>"
                            id="from" />
                    </td>
                </tr>
                <tr>
                <tr>
                    <td align="right"><label for="to">Received SN: </label></td>
                    <td><input type="text" name="recipient"
                        value="<%= Util.safeString((String) h.get("recipient")) %>"
                        id="to" autocomplete="off" />
                    </td>
                </tr>
<%  } %>
                <tr>
                    <td align="right">
                        <label for="contains">Username:</label>
                    </td>
                    <td>
                        <input type="text" name="contains"
                            value="<%= Util.safeString((String) h.get("contains"))  %>"
                            id = "contains" autocomplete="off" />
                    </td>
                </tr>
<%  if(advanced) { %>
                <tr>
                    <td align="right">
                        <label for="service">Service:</label>
                    </td>
                    <td>
                        <select name="service" id="service">
                            <option value="null">Choose One</option>
<%

        rset = lc.executeQuery("distinct_services", paramMap);

        while(rset.next()) {
            out.print("<option value=\"" + rset.getString("service") + "\"" );
            out.print(Util.compare(rset.getString("service"),
                        (String) h.get("service"), " selected=\"selected\""));
            out.print(">" + rset.getString("service") + "</option>\n");
        }
%>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        <label for="meta">Meta Contact:</label>
                    </td>
                    <td>
                        <select name="meta_id">
                            <option value="0">Choose One</option>
<%

        rset = lc.executeQuery("meta_contacts", paramMap);

        while(rset.next()) {
            out.print("<option value=\"" + rset.getInt("meta_id") + "\"");
            if(rset.getInt("meta_id") == meta_id) {
                out.print(" selected=\"selected\"");
            }
            out.print(" >" + rset.getString("name") + "</option>\n");
        }
%>
                        </select>
                    </td>
                </tr>
<%  } %>
                <tr>
                    <td align="right"><label for="start_date">Date Range: </label></td>
                <td><input type="text" name="dateStart" value="<%=
                Util.safeString((String) h.get("dateStart"), today.toString() + " 00:00:00")
                %>" id="start_date" />
                <a href="javascript:show_calendar('control.start');"
                    onmouseover="window.status='Date Picker';return true;"
                    onmouseout="window.status='';return true;">
                <img src="images/calicon.jpg" border="0" alt="cal" /></a>

                <label for="finish_date">&nbsp;--&nbsp;</label>
                <input type="text" name="dateFinish"
                        value="<%= Util.safeString((String) h.get("dateFinish")) %>"
                        id="finish_date" />
                <a href="javascript:show_calendar('control.finish');"
                    onmouseover="window.status='Date Picker';return true;"
                    onmouseout="window.status='';return true;">
                    <img src="images/calicon.jpg" border="0" alt="cal" /></a>
                    </td>
                </tr>
                <tr>
                    <td>
                    </td>
                    <td valign="top">
                        <p><i>(YYYY-MM-DD hh:mm:ss)</i></p>
                    </td>
                </tr>
                </table>

                <input type="radio" name="screen_or_display" value
                = "screen" id = "sn" <% if (!showDisplay && !showMeta)
                out.print("checked=\"checked\""); %> />
                    <label for="sn">Show Screename</label><br />
                <input type="radio" name="screen_or_display"
                value="display" id="disp" <% if (showDisplay)
                out.print("checked=\"checked\""); %> />
                <label for="disp">Show Alias/Display Name</label>
               <br />
                <input type="radio" name="screen_or_display" value="meta" id="meta" <% if (showMeta) out.print("checked=\"checked\""); %> />
                    <label for="meta">Show Meta Contact</label><br /><br />

                <span style="float:left">
                    <a href="<%= advURL %>"><%= !advanced ? "Advanced" : "Simple" %> Form</a>
                </span>

                <span style="float: right">
                    <input type="reset" /><input type="submit" name="gbtn" />
                </span>
                </form>

                <script>
                    InstallAC(document.control,document.control.contains,document.control.gbtn,'User','en');
                </script>
            </div>
            <div class="boxWideBottom"></div>

            <h1>Messages</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%
    paramMap.put("startDate", (String) h.get("dateStart"));
    paramMap.put("endDate", (String) h.get("dateFinish"));
    paramMap.put("sendSN", (String) h.get("sender"));
    paramMap.put("recSN", (String) h.get("recipient"));
    paramMap.put("containsSN", (String) h.get("contains"));
    paramMap.put("service", (String) h.get("service"));
    paramMap.put("meta_id", new Integer(meta_id));

    if(unconstrained) paramMap.put("limit", new Integer(250));
    else paramMap.put("limit", null);

    if(showDisplay)
        rset = lc.executeQuery("message_span_display", paramMap);
    else
        rset = lc.executeQuery("message_span_meta", paramMap);

    if (!rset.isBeforeFirst()) {
        out.print("<div align=\"center\"><i>No records found.</i></div>\n");
    }

    String sent_color = new String();
    String received_color = new String();
    String user = new String();
    String prevSender, prevRecipient;
    prevSender = new String();
    prevRecipient = new String();

    Date currentDate = null;
    Timestamp currentTime = new Timestamp(0);

    int greyCount = 1;

    String currSender = new String();
    String currRec = new String();

    while (rset.next()) {
        if(!rset.getDate("message_date").equals(currentDate)) {
            currentDate = rset.getDate("message_date");
            prevSender = "";
            prevRecipient = "";

            out.println("<div class=\"weblogDateHeader\">");
            out.println(rset.getString("fancy_date"));
            out.println("</div>\n");
        } else if (rset.getTimestamp("message_date").getTime() -
            currentTime.getTime() > 60*10*1000) {
            out.println("<hr width=\"75%\" />");
        }

        currentTime = rset.getTimestamp("message_date");

        String message = rset.getString("message");

        if(showMeta) {
            sent_color = MessageFormatter.nameColor(rset.getString("sender_meta"));
            received_color = MessageFormatter.nameColor(rset.getString("recipient_meta"));
            currSender = rset.getString("sender_meta");
            currRec = rset.getString("recipient_meta");
        } else {
            sent_color = MessageFormatter.nameColor(rset.getString("sender_sn"));
            received_color = MessageFormatter.nameColor(rset.getString("recipient_sn"));
            currSender = rset.getString("sender_sn");
            currRec = rset.getString("recipient_sn");
        }

        message = message.replaceAll("\r|\n", "<br />");
        message = message.replaceAll("   ", " &nbsp; ");

        for (int i = 0; i < hlWords.size(); i++) {

            Pattern p = Pattern.compile("(?i)(.*?)(" +
            hlWords.get(i).toString() + ")(.*?)");
            Matcher m = p.matcher(message);
            StringBuffer sb = new StringBuffer();
            int oldIndex = 0;
            while(m.find()) {
                sb.append(message.substring(oldIndex,m.start()));
                if(sb.toString().lastIndexOf('<') <=
                  sb.toString().lastIndexOf('>')) {
                    sb.append(m.group(1) + "<b style=\"color:black;background-color:" +
                    hlColor[i % hlColor.length] + "\">");
                    sb.append(m.group(2) + "</b>" + m.group(3));
                } else {
                    sb.append(m.group(1) + m.group(2) + m.group(3));
                }
                oldIndex = m.end();
            }
            sb.append(message.substring(oldIndex, message.length()));

            message = sb.toString();
        }

        if(!currSender.equals(prevSender) ||
            !currRec.equals(prevRecipient)) {

            greyCount = 1;

            out.println("<a name=\"" + rset.getString("message_id") + "\"></a>");
            out.print("<div class=\"message_container\">");

            out.println("<div class=\"sender\">");
            out.print("<a href=\"index.jsp?");
            if(!showMeta) {
                out.print("sender=" +
                        rset.getString("sender_sn") +
                        "&amp;recipient=" + rset.getString("recipient_sn"));
            }
            out.print("&amp;dateStart=" + Util.safeString((String) h.get("dateStart")) +
                "&amp;dateFinish=" + Util.safeString((String) h.get("dateFinish")) + "#" +
                rset.getInt("message_id") + "\" ");

            out.print("title=\"" + rset.getString("sender_sn") + "\">");

            out.print("<span style=\"color: " + sent_color + "\">");
            if(showDisplay) {
                out.print(rset.getString("sender_display").replaceAll("<", "&lt;").replaceAll(">", "&gt;"));
            } else if (showMeta) {
                out.print(rset.getString("sender_meta").replaceAll("<", "&lt;").replaceAll(">", "&gt;"));
            } else {
                out.print(rset.getString("sender_sn").replaceAll("<", "&lt;").replaceAll(">", "&gt;"));
            }
            out.print("</span></a>\n");

            if((h.get("recipient") == null
                    || h.get("sender") == null)
                    && h.get("contains") == null) {
                out.println("&rarr;");

                out.println("<a href=\"index.jsp?sender=" +
                rset.getString("sender_sn") +
                    "&amp;recipient=" + rset.getString("recipient_sn") +
                    "&amp;dateStart=" + Util.safeString((String) h.get("dateStart")) +
                    "&amp;dateFinish" + Util.safeString((String) h.get("dateFinish")) +
                    "#" + rset.getInt("message_id") +
                    "\" title=\"" + rset.getString("recipient_sn") + "\">");

                out.print("<span style=\"color: " +
                received_color + "\">");
                if(showDisplay) {
                    out.print(rset.getString("recipient_display").replaceAll("<", "&lt;").replaceAll(">", "&gt;"));
                } else if (showMeta) {
                    out.print(rset.getString("recipient_meta").replaceAll("<", "&lt;").replaceAll(">", "&gt;"));
                } else {
                    out.print(rset.getString("recipient_sn").replaceAll("<", "&lt;").replaceAll(">", "&gt;"));
                }
                out.print("</span></a>");
            }
            out.println("</div>\n\n");
        } else {
            out.println("<div class=\"msg_container_next\">\n");
        }

        if(!showMeta) {
            prevSender = rset.getString("sender_sn");
            prevRecipient = rset.getString("recipient_sn");
        } else {
            prevSender = rset.getString("sender_meta");
            prevRecipient = rset.getString("recipient_meta");
        }

        out.println("<div class=\"time_initial\">");
        if(rset.getBoolean("notes")) {

            paramMap.put("message_id",
                new Integer(rset.getInt("message_id")));
            noteSet = lc.executeQuery("message_notes", paramMap);

            out.print("<a class=\"info\" href=\"#\">");
            out.print("<img src=\"images/note.png\" alt=\"note\" /><span>");

            while(noteSet.next()) {
                out.print("<p><b>" + noteSet.getString("title") + "</b><br />" +
                    noteSet.getString("notes") + "</p>");
            }
            out.print("</span></a>");

        }
        out.println("<a href=\"#\" title=\"Add Note ...\" " +
            "onClick=\"window.open('saveForm.jsp?action=saveNote&amp;type=note&amp;message_id=" +
            rset.getString("message_id") + "', 'Add Note', "+
            "'width=275,height=225')\">");

        out.print("<img src=\"images/note_add.png\" alt=\"Add Note\" /></a>");

        out.print(rset.getTime("message_date"));
        out.println("</div>\n");

        out.println("<div class=\"message\"><p " +
                (greyCount++ % 2 == 0 ? "class=\"even\"" :
                 "class=\"odd\"") + ">");
        out.println(message);
        out.println("</p></div>\n");

        out.println("</div>\n");
    }
} catch (SQLException err) {
    out.print("<br /><span style=\"color: red\">" + err.getMessage() + "</span>");
}
%>
                </div>
                <div class="boxWideBottom"></div>
            </div>
            <div id="bottom">
                <div class="cleanHackBoth"> </div>
            </div>
        </div>
        <div id="footer">&nbsp;</div>
    </div>
</body>
</html>
