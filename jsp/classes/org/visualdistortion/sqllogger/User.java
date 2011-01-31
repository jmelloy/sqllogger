/*
 * $URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/classes/org/visualdistortion/sqllogger/User.java $
 * $Id: User.java 1078 2005-05-23 01:39:40Z jmelloy $
 *
 * Jeffrey Melloy
 */

package org.visualdistortion.sqllogger;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.slamb.axamol.library.*;
import java.util.Map;
import java.util.HashMap;
import java.util.Enumeration;
import java.util.List;
import java.util.ArrayList;
import org.visualdistortion.util.Util;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Manipulates information about users.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev: 1078 $ $Date: 2005-05-22 20:39:40 -0500 (Sun, 22 May 2005) $
 **/
public class User extends HttpServlet {

    public void init() throws ServletException {
    }

    public void doGet(HttpServletRequest request,
            HttpServletResponse response)
        throws ServletException, IOException {

        LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-update");
        LibraryConnection stan = (LibraryConnection) request.getAttribute("lc-standard");

        Map params = new HashMap();

        ResultSet rset = null;

        int user_id = Util.checkInt(request.getParameter("user_id"));

        try {
            String action = Util.safeString(request.getParameter("action"));

            if(action.equals("")) {

                response.setContentType("text/html; charset=UTF-8");
                request.setCharacterEncoding("UTF-8");

                params.put("letters", request.getParameter("qu") + "%");

                rset = stan.executeQuery("users_starting_no_display", params);

                String services[] = new String[10];
                int svcCount = 0;

                String out = new String("sendRPCDone(frameElement, \"" +
                    request.getParameter("qu") + "\", new Array(");

                while(rset.next()) {
                    if(rset.getRow() != 1) out += ", ";
                    out += "\"" + rset.getString("username") + "\"";
                    services[svcCount++] = rset.getString("service");
                }

                out += "), new Array(";

                for(int i = 0; i < svcCount; i++) {
                    if(i != 0) out += ", ";
                    out += "\"" + services[i] + "\"";
                }

                out += "), new Array(\"\"));";

                response.getWriter().print(out);

            } else if(action.equals("updateLogin")) {
                Enumeration e = request.getParameterNames();
                List l = new ArrayList();

                while(e.hasMoreElements()) {
                    try {
                        l.add(new Integer((String) e.nextElement()));
                    } catch (NumberFormatException err) {
                    }
                }

                params.put("user_list", l);

                int rowsAffected = lc.executeUpdate("remove_login_user", params);

                rowsAffected = lc.executeUpdate("add_login_user", params);

                response.sendRedirect("users.jsp");
            } else if (action.equals("changeUserInfo")) {
                params.put("user_id", new Integer(user_id));

                if(user_id != 0) {

                    rset = lc.executeQuery("all_info_keys", params);

                    while(rset.next()) {
                        String requestText = request.getParameter(rset.getString("key_id"));
                        int returnVal;

                        params.put("value", requestText);
                        params.put("key_id", new Integer(rset.getInt("key_id")));

                        if(requestText != null && !requestText.equals("")) {

                            returnVal = lc.executeUpdate("update_user_info", params);

                            if(returnVal == 0) {
                                lc.executeUpdate("insert_user_info", params);
                            }
                        } else if (requestText == null || requestText.equals("")) {

                            lc.executeUpdate("delete_user_info", params);
                        }
                    }
                }

                response.getWriter().println("<html><body onLoad=\"window.opener.parent.location.reload(); window.close()\"></body></html>");
            }
        } catch (SQLException e) {
            response.getWriter().println(e.getMessage());
        }
    }

    public void destroy() {
    }
}
