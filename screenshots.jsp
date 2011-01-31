<%@ page import = 'java.sql.*' %>
<%@ page import = 'javax.sql.*' %>
<%@ page import = 'javax.naming.*' %>
<%
Context env = (Context) new InitialContext().lookup("java:comp/env/");
DataSource source = (DataSource) env.lookup("jdbc/postgresql");
Connection conn = source.getConnection();

Statement stmt = null;
Statement pics = null;
ResultSet rset = null;
ResultSet picSet = null;

try {
    stmt = conn.createStatement();
    pics = conn.createStatement();

    rset = stmt.executeQuery("select name, description, category_id from " +
        " visualdistortion.pic_category where parent = 96 order by " +
        " category_id asc");

    picSet = pics.executeQuery("select short_caption, " +
        " thheight, thwidth, thname, image_id, category_id " +
        " from visualdistortion.image_info " +
        " where category_id in (select category_id from visualdistortion."+
        " pic_category where parent = 96) order by category_id asc, " +
        " secondary_sort asc");

    picSet.next();
    while(rset.next() ) {
        int picCount = 1;
%>
    <h3><%= rset.getString("name") %></h3>
    <%
    if(rset.getString("description") != null) {
        out.print(rset.getString("description"));
    }
    %>
    <hr>
    <table><tr>
<%      while(!picSet.isAfterLast() &&
            picSet.getInt("category_id") == rset.getInt("category_id") ) {
            out.println("<td align=\"center\" valign=\"top\" width=\"" +
            (picSet.getInt("thwidth") + 5) +"\">");
            out.println("<a " +
            "href=\"http://www.visualdistortion.org/pictures/viewpic.jsp?pic="+
            picSet.getString("image_id") +
            "&group=true&nocomment=true&return-url=" +
            request.getServletPath() + "\">" +
            "<img src=\"" + picSet.getString("thname") +
            "\" width=\"" + picSet.getString("thwidth") + "\" height=\"" +
            picSet.getString("thheight") +"\" border=\"0\"></a>");
            if (picSet.getString("short_caption") != null) {
                out.println("<br />" + picSet.getString("short_caption"));
            }
            out.println("</td>");
            if (picCount++ % 2 == 0) {
                out.println("</tr><tr>");
            }
            picSet.next();
        }
%>
    </tr></table>
<%
    }
} catch (SQLException e) {
    out.println(e.getMessage());
} finally {
    stmt.close();
    conn.close();
}
%>
