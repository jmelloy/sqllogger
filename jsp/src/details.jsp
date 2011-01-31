<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.regex.*' %>
<%@ page import = 'java.util.Vector' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--$URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/src/details.jsp $-->
<!--$Rev: 1092 $ $Date: 2005-07-03 09:49:04 -0500 (Sun, 03 Jul 2005) $ -->

<%
LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");
LibraryConnection stats = (LibraryConnection) request.getAttribute("lc-stats");

Map params = new HashMap();

int sender, meta_id;

sender = Util.checkInt(request.getParameter("sender"));
meta_id = Util.checkInt(request.getParameter("meta_id"));
String date = Util.checkNull(request.getParameter("start"));

params.put("user_id", null);
params.put("sender", null);
params.put("meta_id", new Integer(meta_id));
params.put("startDate", date);

String endMonth = new String();

boolean loginUsers =
    Boolean.valueOf(request.getParameter("login")).booleanValue();

params.put("login", Boolean.toString(loginUsers));

String sender_sn = new String();
String title = new String();

int lastDayOfMonth = 0;
String month = new String();

ResultSet rset = null;
ResultSetMetaData rsmd = null;

try {

    if(sender != 0 || meta_id != 0) {
        params.put("user_id", new Integer(sender));
        params.put("sender", new Integer(sender));

        if(sender != 0)
            rset = lc.executeQuery("user_display_name", params);
        else if(meta_id != 0)
            rset = lc.executeQuery("meta_contained_users", params);

        rset.next();

        if(meta_id != 0) {
            title = rset.getString("name");
            sender_sn = rset.getString("name");
        } else {
            title = "<img src=\"images/services/" + rset.getString("service") +
                ".png\" width=\"28\" height=\"28\" /> " +
                rset.getString("display_name");
            sender_sn = rset.getString("username");
        }
    } else {
        title = "Detailed Statistics";
    }

    rset = stats.executeQuery("date_info", params);

    rset.next();

    month = rset.getString("month");

    lastDayOfMonth = rset.getInt("last_day");

    endMonth = rset.getString("end_month");

    params.put("endDate", endMonth);

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: Detailed Statistics</title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="styles/layout.css" />
<link rel="stylesheet" type="text/css" href="styles/default.css" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<script language="javascript" type="text/javascript">
 function OpenLink(c){
   window.open(c, 'link', 'width=480,height=480,scrollbars=yes,status=yes,toolbar=no');
 }
</script>
</head>
<body>
	<div id="container">
	   <div id="header">
	   </div>
	   <div id="banner">
            <div id="bannerTitle">
                <img class="adiumIcon" src="images/headlines/stats.png" width="128" height="128" border="0" alt="Details Icon" />
                <div class="text">
                    <h1><%= title %></h1>
                    <p><%= month %></p>
                </div>
            </div>
        </div>
        <div id="central">
            <div id="navcontainer">
                <ul id="navlist">
                    <li><a href="index.jsp">Viewer</a></li>
                    <li><a href="search.jsp">Search</a></li>
                    <li><a href="users.jsp">Users</a></li>
                    <li><a href="meta.jsp">Meta-Contacts</a></li>
                    <li><a href="chats.jsp">Chats</a></li>
                    <li><a href="statistics.jsp">Statistics</a></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="sidebar-a">

                <h1>Meta Contacts</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">

<%
    rset = lc.executeQuery("meta_contacts", params);

    while(rset.next()) {
        out.println("<p><a href=\"statistics.jsp?meta_id=" +
            rset.getInt("meta_id") + "\">" + rset.getString("name") +
            "</a></p>");
    }
%>
                </div>
                <div class="boxThinBottom"></div>

                <h1>Users</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">
<%

    if(!loginUsers) {
        out.print("<p><i><a href=\"statistics.jsp?sender=" +
            sender + "&login=true\">Login Users</a></i></p>");
    } else {
        out.print("<p><i><a href=\"statistics.jsp?sender=" +
            sender + "&login=false\">" +
            "All Users</a></i></p>");
    }

    out.println("<p></p>");

    rset = lc.executeQuery("all_users", params);

    while (rset.next())  {
        if (rset.getInt("user_id") != sender) {
            out.println("<p>");
            out.println("<img src=\"images/services/" +
                rset.getString("service") + ".png\" width=\"12\" height=\"12\" />");
            out.println("<a href=\"statistics.jsp?sender=" +
            rset.getString("user_id") + "&login=" +
            Boolean.toString(loginUsers) +
            "\" title=\"" + rset.getString("username") + "\">" +
            rset.getString("display_name") +
            "</a></p>");
        }
        else {
            out.println("<p>" + rset.getString("username") + "</p>");
        }
    }

%>
                </div>
                <div class="boxThinBottom"></div>
            </div>
            <div id="content">

                <h1>Detailed Statistics</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
                <jsp:include page="Calendar">
                    <jsp:param name="sender" value="<%=sender%>"/>
                    <jsp:param name="meta_id" value="<%=meta_id%>"/>
                    <jsp:param name="returnURL" value="details.jsp"/>
                </jsp:include>
                </div>
                <div class="boxWideBottom"></div>


                <h1>Total Messages Sent/Received</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

    if(meta_id != 0)
        rset = stats.executeQuery("total_messages_month_meta", params);
    else if (sender != 0)
        rset = stats.executeQuery("total_messages_month_user", params);
    else
        rset = stats.executeQuery("total_messages_month", params);

    int total = 0;
    while(rset.next()) {
        String ident = rset.getString("identifier");
        total += rset.getInt("total_sent"); %>
            Total <%= ident %>: <%= rset.getString("total_sent") %><br />
            Minimum <%= ident %> Length: <%= rset.getString("min_length") %><br />
            Maximum <%= ident %> Length: <%= rset.getString("max_length") %><br />
            Average <%= ident %>  Length: <%= rset.getString("avg_length") %><br />
        <br />
    <% } %>

        Total Sent/Received: <%= total %><br />
        <br />

                </div>
                <div class="boxWideBottom"></div>

                <h1>Total Messages by Day</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">

<%

    if(meta_id != 0) {
        rset = stats.executeQuery("daily_totals_meta", params);
    } else
        rset = stats.executeQuery("daily_totals_user", params);

    int[] dailyAry = new int[lastDayOfMonth + 1];
    int maxCount = 0;

    for(int i = 0; i <= lastDayOfMonth; i++) {
        dailyAry[i] = 0;
    }

    while(rset.next()) {
        dailyAry[rset.getInt("day")] = rset.getInt("count");

        if (rset.getInt("count") > maxCount) {
            maxCount = rset.getInt("count");
        }
    }
    maxCount *= 1.1;

    out.print("<table cellspacing=\"0\" cellpadding=\"0\"><tr>");

    for (int i = 1; i <= lastDayOfMonth; i++) {
        double height = (double)dailyAry[i] / maxCount * 300;
        if (height < 1 && height != 0) {
            height = 1;
        }
        out.print("<td height=\"300\" valign=\"bottom\"" +
        " background=\"images/gridline.gif\" rowspan=\"4\">");
        out.print("<img src=\"images/bar2.gif\" width=\"11\" height=\"" +
        (int)height  + "\"></td>");
    }

    out.print("<td valign=\"top\" height=\"70\">" + maxCount + "</td></tr>");
    out.print("<tr><td valign=\"top\" height=\"73\">" +
        (int) (maxCount * .75) + "</td></tr>");
    out.print("<tr><td valign=\"top\" height=\"75\">" +
        (int) (maxCount * .5) + "</td></tr>");
    out.print("<tr><td valign=\"top\">" + (int) (maxCount * .25) +
        "</td></tr>");

    out.print("<tr>");
    for(int i = 1; i <= lastDayOfMonth; i++) {
        out.print("<td valign=\"top\" align=\"center\">" +
        i + "&nbsp;</td>");
    }
    out.print("</tr>");

    out.print("</table>");
%>

                </div>
                <div class="boxWideBottom"></div>

                <h1>Most Popular Messages</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">

<%


    if(meta_id != 0) {
        rset = stats.executeQuery("popular_messages_meta", params);
    } else
        rset = stats.executeQuery("popular_messages_sender", params);

    out.println("<table>");

    out.println("<tr><td>#</td>"+
        "<td>Message</td><td >"+
        "Cnt</td></tr>");

    while(rset.next()) {
        out.println("<tr><td>" + rset.getRow() + "</td>");
        out.println("<td>" +
            rset.getString("message") + "</td>");
        out.println("<td>" +
                rset.getString("count") + "</td></tr>");
    }
    out.println("</table>");

%>
                </div>
                <div class="boxWideBottom"></div>

                <h1>Most Popular Conversation Starters</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

    if(meta_id != 0) {
        rset = stats.executeQuery("popular_convo_starters_meta_range", params);
    } else
        rset = stats.executeQuery("popular_convo_starters_user_range", params);
%>
                <table>
                    <tr>
                        <td>#</td>
                        <td>Sender<br />
                        &nbsp;&nbsp;&nbsp;&nbsp;Recipient</td>
                        <td>Message</td>
                        <td>Count</td>
                    </tr>
<%
        while(rset.next()) {
            out.println("<tr>");
            out.println("<td>" +
                rset.getRow() + "</td>");
            out.println("<td>" + rset.getString("sender_sn") + "<br />");
            out.println("&nbsp;&nbsp;&nbsp;&nbsp;" +
                rset.getString("recipient_sn") + "</td>");
            out.println("<td>" + rset.getString("message") + "</td>");
            out.println("<td>" + rset.getString("count") + "</td>");
            out.println("</tr>");
        }
        out.print("</table>");

%>
                </div>
                <div class="boxWideBottom"></div>

                <h1>Messages by Hour of Day</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%

    if(meta_id != 0)
        rset = stats.executeQuery("daily_hourly_totals_meta_range", params);
    else
        rset = stats.executeQuery("daily_hourly_totals_user_range", params);

    int[][] dailyHourly= new int[lastDayOfMonth + 1][24];
    int maxHourly = 0;
    for(int i = 0; i <= lastDayOfMonth; i++) {
        for(int j = 0; j < 24; j++) {
            dailyHourly[i][j] = 0;
        }
    }

    while(rset.next()) {
        dailyHourly[rset.getInt("day")][rset.getInt("hour")] =
        rset.getInt("count");
        if (rset.getInt("count") > maxHourly) {
            maxHourly = rset.getInt("count");
        }
    }

    out.println("<table border=\"0\">");
    out.println("<tr><td></td>");
    for(int i = 0; i < 24; i++) {
        out.println("<td>" + i + "</td>");
    }
    out.println("<td>"+
    "Total</td></tr>");

    for(int i = 1; i <= lastDayOfMonth; i++) {
        out.print("<tr><td>" + i + "</td>");
        for(int j = 0; j < 24; j++) {
            String start = new String(date);
            String finish = new String(date);

            start = start.replaceFirst("01 ", i + " ");
            start = start.replaceFirst("00:", j + ":");
            if(j != 23) {
                finish = finish.replaceFirst("01 ", i + " ");
                finish = finish.replaceFirst("00:", j + 1  + ":");
            } else if (j == 23 && i != lastDayOfMonth) {
                finish = finish.replaceFirst("01 ", (i + 1) + " ");
            } else if (j == 23 && i == lastDayOfMonth) {
                Pattern p = Pattern.compile("(\\d*-)(\\d*)(-01.*)");
                Matcher m = p.matcher(finish);
                StringBuffer sb = new StringBuffer();
                while(m.find()) {
                    sb.append(m.group(1) +
                        (Integer.parseInt(m.group(2)) + 1) +
                        m.group(3));
                }
                finish = sb.toString();
            }

            out.print("<td align=\"center\" class=\"shade\"");

            double shade = (255 - ((double) dailyHourly[i][j] / maxHourly) * 255);
            if (dailyHourly[i][j] != 0) {
                 out.print(" bgcolor=\"#" + Integer.toHexString((int)shade) +
                 Integer.toHexString((int)shade) +
                 Integer.toHexString((int)shade) + "\" ");
                out.print("><a href=\"index.jsp?dateStart=" + start +
                "&dateFinish=" + finish + "\">" + dailyHourly[i][j] +
                "</a>");
            } else {
                out.print(">&nbsp;&nbsp;&nbsp;&nbsp;");
            }

            out.print("</td>");
        }
        out.print("<td ");
        out.print(" align=\"right\"><b>" + dailyAry[i] + "</b></td>");
        out.print("</tr>");
    }
    out.print("</table>");
%>
                </div>
                <div class="boxWideBottom"></div>

                <h1>Message Statistics</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%


    if(meta_id != 0)
        rset = stats.executeQuery("popular_users_meta", params);
    else
        rset = stats.executeQuery("popular_users_sender", params);

    out.print("<table>");

    out.println("<tr><td>#</td><td>Username</td><td>Sent</td><td>Received</td><td>Random Quote</td></tr>");
    while(rset.next()) {
        out.println("<tr>");
        out.println("<td>" + rset.getRow() + "</td>");
        out.println("<td>" + rset.getString("username") + "</td>");
        out.println("<td>" + rset.getString("sent") + "</td>");
        out.println("<td>" + rset.getString("received") + "</td>");
        out.println("<td>" + rset.getString("message") + "</td>");
        out.println("</tr>");
    }

    out.print("</table>");
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

<%
} catch (SQLException e) {
    out.print("<br /><span style=\"color: red\">" + e.getMessage() + "</span>");
    while(e.getNextException() != null) {
        out.println("<br />" + e.getMessage());
    }
}
%>
</body>
</html>
