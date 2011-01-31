<%@ page import = 'java.sql.*' %>
<%@ page import = 'java.util.Map' %>
<%@ page import = 'java.util.HashMap' %>
<%@ page import = 'org.slamb.axamol.library.*' %>
<%@ page import = 'org.visualdistortion.util.Util' %>
<%@ page import = 'org.visualdistortion.util.Search' %>
<%@ page import = 'org.visualdistortion.sqllogger.SearchUtil' %>
<%@ page import = 'java.util.Enumeration' %>

<%
String searchFormURL = new String("saveForm.jsp?action=saveForm&type=search");
int item_id = 0;

item_id = Util.checkInt(request.getParameter("item_id"));

Enumeration e = request.getParameterNames();
HashMap h = new HashMap();

while(e.hasMoreElements()) {
    String key = (String) e.nextElement();
    String value = Util.checkNull(request.getParameter(key));
    h.put(key, value);

    if(value != null) {
        searchFormURL += "&" + key + "=" + value;
    }
}

String orderBy;

String group;
String group_sort;
String within;
String within_sort;

group = (String) h.get("group");
if(group == null) group = "flat";

group_sort = (String) h.get("group_sort");
if(group_sort == null && group.equals("date")) {
    group_sort = "desc";
} else if(group_sort == null) {
    group_sort = "asc";
}

within = (String) h.get("within");
if(within == null) within = "rank";

within_sort = (String) h.get("within_sort");

if(within_sort == null &&
        (within.equals("rank") || within.equals("date"))) {
    within_sort = "desc";
} else if (within_sort == null) {
    within_sort = "asc";
}

if(group.equals("flat"))
    orderBy = within + " " + within_sort;
else if(group.equals("date"))
    orderBy = "message_date " + group_sort + ", " +
        within + " " + within_sort;
else
    orderBy = group + " " + group_sort + ", " +
        within + " " + within_sort;

String title = new String();
String notes = new String();

ResultSet rset = null;

long beginTime = 0;
long queryTime = 0;

String searchKey = new String();
searchKey = (String) h.get("search");

LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-standard");;
Map params = new HashMap();

try {
if(item_id != 0) {
        params.put("item_id", new Integer(item_id));

        rset = lc.executeQuery("saved_fields", params);

        while(rset.next()) {
            title = rset.getString("title");
            notes = rset.getString("notes");

            h.put(rset.getString("field_name"), rset.getString("value"));

        }
    } else {
        title = "Search";
    }

    String searchType = new String();

    // Check if tsearch types exist
    rset = lc.executeQuery("check_for_tsearch", params);

    if (rset != null && !rset.isBeforeFirst()) {
        searchType = "search_none";
    } else {
        rset.next();
        if(rset.getString(1).equals("txtidx")) {
            searchType = "search_tsearch1";
        } else if (rset.getString(1).equals("tsquery")) {
            searchType = "search_tsearch2";
        }
    }

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>SQL Logger: Search</title>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="styles/layout.css" />
<link rel="stylesheet" type="text/css" href="styles/default.css" />
<link rel="stylesheet" type="text/css" href="styles/message.css" />
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<script language="javascript" type="text/javascript">
 function OpenLink(c){
   window.open(c, 'link', 'width=480,height=480,scrollbars=yes,status=yes,toolbar=no');
 }
</script>
<script lanaguage = "JavaScript">
    window.name='search';
</script>
<script language="JavaScript" src="calendar.js"></script>
<script src="ac.js"></script>
</head>
<body>
	<div id="container">
	   <div id="header">
	   </div>
	   <div id="banner">
            <div id="bannerTitle">
                <img class="adiumIcon" src="images/headlines/search.png" width="128" height="128" border="0" alt="Search" />
                <div class="text">
                    <h1><%= title %></h1>
                    <p><%= notes %></p>
                </div>
            </div>
        </div>
        <div id="central">
            <div id="navcontainer">
                <ul id="navlist">
                    <li><a href="index.jsp">Viewer</a></li>
                    <li><span id="current">Search</span></li>
                    <li><a href="users.jsp">Users</a></li>
                    <li><a href="meta.jsp">Meta-Contacts</a></li>
                    <li><a href="chats.jsp">Chats</a></li>
                    <li><a href="statistics.jsp">Statistics</a></li>
                    <li><a href="query.jsp">Query</a></li>
                </ul>
            </div>
            <div id="sidebar-a">
                <h1>Saved Searches</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">
<%
    params.put("type", "search");
    rset = lc.executeQuery("saved_items_list", params);

    while(rset.next()) {
        out.println("<p><a href=\"search.jsp?item_id=" +
            rset.getString("item_id") + "\">" + rset.getString("title") +
            "</a></p>");
    }
%>
                    <br />
                        <p>
                        <a href="#" onClick="window.open('<%= searchFormURL %>', 'Save Search', 'width=275,height=225')">
                        Save Search ...</a></p>
                </div>
                <div class="boxThinBottom"></div>

                <h1>Sort Options</h1>
                <div class="boxThinTop"></div>
                <div class="boxThinContent">
                    <p><b>Group by:</b></p>
                    <%
                    String search = (String) h.get("search");
                    String date = Util.safeString((String) h.get("start"));
                    if(group.equals("date")) {
                        out.println("<p>Date");

                        if(group_sort.equals("asc")) {
                            out.println("Asc");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, "asc", within, within_sort, date, search));
                        }

                        if(group_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, "desc", within, within_sort, date, search));
                        }

                        out.println("</p>");
                    } else {
                        out.println("<p>" + SearchUtil.getLink("Date", "date", "desc", within, within_sort, date, search) + "</p>");
                    }


                    if(group.equals("sender_sn")) {
                        out.println("<p>Sender");

                        if(group_sort.equals("asc")) {
                            out.println("Asc");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, "asc", within, within_sort, date, search));
                        }

                        if(group_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, "desc", within, within_sort, date, search));
                        }

                        out.println("</p>");

                    } else {
                        out.println("<p>" + SearchUtil.getLink("Sender", "sender_sn", "asc", within, within_sort, date, search) + "</p>");
                    }

                    if(group.equals("recipient_sn")) {
                        out.println("<p>Recipient");

                        if(group_sort.equals("asc")) {
                            out.println("Asc");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, "asc", within, within_sort, date, search));
                        }

                        if(group_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, "desc", within, within_sort, date, search));
                        }

                        out.println("</p>");

                    } else {
                        out.println("<p>" + SearchUtil.getLink("Recipient", "recipient_sn", "asc", within, within_sort, date, search) + "</p>");
                    }

                    if(group.equals("flat")) {
                        out.println("<p>None</p>");

                    } else {
                        out.println("<p>" + SearchUtil.getLink("None", "flat", null, within, within_sort, date, search) + "</p>");
                    }
                    out.println("<hr />");

                    out.println("<p><b>Sort Within Group by:</b></p>");
                    if(within.equals("rank")) {
                        out.println("<p>Rank");

                        if(within_sort.equals("asc")) {
                            out.println("Asc");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, group_sort, within, "asc", date, search));
                        }

                        if(within_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, group_sort, within, "desc", date, search));
                        }

                        out.println("</p>");

                    } else {
                        out.println("<p>" + SearchUtil.getLink("Rank", group, group_sort, "rank", "desc", date, search) + "</p>");
                    }

                    if(within.equals("sender_sn") || within.equals("recipient_sn")) {
                        out.println("<p>Name");

                        if(within_sort.equals("asc")) {
                            out.println("Asc ");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, group_sort, within, "asc", date, search));
                        }

                        if(within_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, group_sort, within, "desc", date, search));
                        }

                        out.println("</p>");
                    } else {
                        out.println("<p>" + SearchUtil.getLink("Name", group, group_sort, (group.equals("sender_sn") ? "recipient_sn" : "sender_sn"), "asc", date, search) + "</p>");
                    }

                    if(within.equals("message")) {
                        out.println("<p>Message");

                        if(within_sort.equals("asc")) {
                            out.println("Asc");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, group_sort, within, "asc", date, search));
                        }

                        if(within_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, group_sort, within, "desc", date, search));
                        }

                        out.println("</p>");
                    } else {
                        out.println("<p>" + SearchUtil.getLink("Message", group, group_sort, "message", "asc", date, search) + "</p>");
                    }

                    if(within.equals("message_date")) {
                        out.println("<p>Date");

                        if(within_sort.equals("asc")) {
                            out.println("Asc ");
                        } else {
                            out.println(SearchUtil.getLink("Asc", group, group_sort, within, "asc", date, search));
                        }

                        if(within_sort.equals("desc")) {
                            out.println("Desc");
                        } else {
                            out.println(SearchUtil.getLink("Desc", group, group_sort, within, "desc", date, search));
                        }
                        out.println("</p>");
                    } else {
                        out.println("<p>" + SearchUtil.getLink("Date", group, group_sort, "message_date", "asc", date, search) + "</p>");
                    }
                    out.println("<hr />");

                    rset = lc.executeQuery("date_ranges", params);
                    rset.next();

                    out.println("<p><b>When:</b></p>");

                    if(!date.equals("")) {
                        out.println("<p>" + SearchUtil.getLink("All", group, group_sort, within, within_sort, null, search) + "</p>");
                    } else {
                        out.println("<p>All</p>");
                    }

                    if(!date.equals(rset.getString("today")))
                        out.println("<p>" + SearchUtil.getLink("Today", group, group_sort, within, within_sort, rset.getString("today"), search) + "</p>");
                    else
                        out.println("<p>Today</p>");

                    if(!date.equals(rset.getString("yesterday")))
                        out.println("<p>" + SearchUtil.getLink("Yesterday", group, group_sort, within, within_sort, rset.getString("yesterday"), search) + "</p>");
                    else
                        out.println("<p>Yesterday</p>");

                    if(!date.equals(rset.getString("week")))
                        out.println("<p>" + SearchUtil.getLink("This Week", group, group_sort, within, within_sort, rset.getString("week"), search) + "</p>");
                    else
                        out.println("<p>This Week</p>");

                    if(!date.equals(rset.getString("month")))
                        out.println("<p>" + SearchUtil.getLink("This Month", group, group_sort, within, within_sort, rset.getString("month"), search) + "</p>");
                    else
                        out.println("<p>This Month</p>");

                    if(!date.equals(rset.getString("year")))
                        out.println("<p>" + SearchUtil.getLink("This Year", group, group_sort, within, within_sort, rset.getString("year"), search) + "</p>");
                    else
                        out.println("<p>This Year</p>");

                    %>
                </div>
                <div class="boxThinBottom"></div>
            </div>
            <div id="content">
                <h1>Search</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
                    <form action="search.jsp" method="post" name="control">
                    <table border="0" cellpadding="3" cellspacing="0">
                        <tr>
                            <td>
                                <label for="searchstring">Search String: </label>
                            </td>
                            <td>
                                <input type="text" name="search"
                                    accesskey="s" tabindex="1"
                        <%
                        if ((String) h.get("search") != null)
                            out.print("value=\"" + ((String) h.get("search")).replaceAll("\"","&quot;") + "\"");
                        %> id="searchstring" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                <label for="username">Username: </label>
                            </td>
                            <td><input type="text" name="username" tabindex="2"
                        <% if (h.get("username") != null)
                            out.print("value=\"" + (String) h.get("username") + "\""); %> id="username" />
                            </td>
                        </tr>
                        </table><br />
                        <input type="hidden" name="within" value="<%= within %>" />
                        <input type="hidden" name="within_sort" value="<%= within_sort %>" />
                        <input type="hidden" name="group" value="<%= group %>" />
                        <input type="hidden" name="group_sort" value="<%= group_sort %>" />
                        <input type="hidden" name="start" value="<%= (String) h.get("start")%>" />
                        <input type="hidden" name="finish" value="<%= (String) h.get("finish") %>" />
                        <div align="right">
                            <input type="reset" tabindex="16" />
                            <input type="submit" tabindex="15" />
                        </div>
                    <script>
                        InstallAC(document.control,document.control.username,document.control.gbtn,'user','en');
                    </script>

                    </form>
                </div>
                <div class="boxWideBottom"></div>
<%
    if((String) h.get("search") != null) {

        //If the user hasn't installed tsearch, be slow & simple
        if(searchType.equals("search_none")) {

            out.print("<div align=\"center\">");
            out.print("<i>This query is case sensitive for speed.<br>");
            out.print("For a non-case-sensitive, faster query, "+
            "install the tsearch2 module.</i></div>");

            params.put("search", (String) h.get("search"));

            // If the user has installed a tsearch, transform the search string
        } else {
            Search s = new Search((String) h.get("search"));

            params.put("matchRegexp", s.getExactMatches());
            params.put("search", s.getSearch());
        }

        params.put("username", (String) h.get("username"));
        params.put("recipient", (String) h.get("recipient"));
        params.put("dateStart", (String) h.get("start"));
        params.put("dateFinish", (String) h.get("finish"));
        params.put("service", (String) h.get("service"));

        beginTime = System.currentTimeMillis();
        try {
            rset = lc.executeQuery(searchType, params, orderBy);
        } catch (SQLException err) {
            out.println("<span style=\"color:red\">" + err.getMessage() +
                "</span>");
        }
        queryTime = System.currentTimeMillis() - beginTime;

%>
                <span style="float:right"><i><%=queryTime%> milliseconds</i></span>
                <h1>Search Results</h1>
                <div class="boxWideTop"></div>
                <div class="boxWideContent">
<%
        if(rset != null && rset.isBeforeFirst()) {


            String prevGroup = new String();

            while(rset.next()) {

                if(!group.equals("flat")
                        && !rset.getString(group).equals(prevGroup)) {
                    out.println("<div class=\"search_group\">" +
                            rset.getString(group) +
                            "</div>");
                }

                String messageContent = rset.getString("message");
                messageContent = messageContent.replaceAll("\n", "<br>");
                messageContent = messageContent.replaceAll("   ", " &nbsp; ");

                if(!group.equals("sender_sn")
                        && !group.equals("recipient_sn")) {
                    out.print(rset.getString("sender_sn") +
                            ":&#8203;" + rset.getString("recipient_sn"));
                }

                out.println("<span style=\"float: right\"><img src=\"images/bar2.gif\" height=\"12\" width=\"" + (int)(rset.getDouble("rank") * 50) + "\"></span>");

                out.print("<p style=\"text-indent: 30px\">" +
                    messageContent + "<br />");

                String cleanString = searchKey;
                cleanString = cleanString.replaceAll("&", " ");
                cleanString = cleanString.replaceAll("!", " ");
                cleanString = cleanString.replaceAll("\\|", " ");

                out.print("<a href=\"index.jsp?sender=" +
                rset.getString("sender_sn") +
                "&amp;recipient=" + rset.getString("recipient_sn") +
                "&amp;hl=" + cleanString +
                "&amp;message_id=" + rset.getString("message_id") +
                "&amp;time=15#" + rset.getInt("message_id") + "\">");
                out.print("&#177;15&nbsp;");
                out.print("</a>");

                out.print("<a href=\"index.jsp?sender=" +
                rset.getString("sender_sn") +
                "&amp;recipient=" + rset.getString("recipient_sn") +
                "&amp;message_id=" + rset.getString("message_id") +
                "&amp;time=30" +
                "&amp;hl=" + cleanString +
                "#" + rset.getInt("message_id") + "\">");
                out.print("&#177;30&nbsp;");
                out.print("</a> ");

                if(group.equals("sender_sn"))
                    out.print("[" + rset.getString("recipient_sn") + "]");
                else if(group.equals("recipient_sn"))
                    out.print("[" + rset.getString("sender_sn") + "]");

                out.print("<span style=\"float:right\">" +
                    rset.getDate("message_date") +
                    "&nbsp;" + rset.getTime("message_date") +
                    "</span></p>\n");

                if(!group.equals("flat"))
                    prevGroup = rset.getString(group);
            }

        } else if (rset != null && !rset.isBeforeFirst()) {
            out.print("<div align=\"center\"><i>No results found.</i>");

            out.print("</div>");
        }
%>
            </div>
            <div class="boxWideBottom"></div>
<%
    }

} catch (SQLException err) {
    out.print("<br />" + err.getMessage() + "<br>");
}
%>
        </div>
        <div id="bottom">
            <div class="cleanHackBoth"> </div>
        </div>
        </div>
        <div id="footer">&nbsp;</div>
    </div>
</body>
</html>
