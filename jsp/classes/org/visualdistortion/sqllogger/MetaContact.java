/*
 * $URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/classes/org/visualdistortion/sqllogger/MetaContact.java $
 * $Id: MetaContact.java 1093 2005-07-04 14:40:51Z jmelloy $
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
import org.visualdistortion.util.Util;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Manipulates meta contacts.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev: 1093 $ $Date: 2005-07-04 09:40:51 -0500 (Mon, 04 Jul 2005) $
 **/
public class MetaContact extends HttpServlet {

    public void init() throws ServletException {
    }

    public void processRequest(HttpServletRequest request,
            HttpServletResponse response)
        throws ServletException, IOException {

        LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-update");
        Map params = new HashMap();

        ResultSet rset = null;

        boolean reloadParent = true;

        int meta_id = Util.checkInt(request.getParameter("meta_id"));
        int user_id = 0;

        try {

            String action = Util.safeString(request.getParameter("action"));

            if(action.equals("addMeta")) {
                String name = Util.checkNull(request.getParameter("name"));

                if(name != null && !name.equals("")) {

                    params.put("name", name);

                    lc.executeUpdate("add_meta", params);

                    params.put("sequence", "meta_container_meta_id_seq");

                    rset = lc.executeQuery("currval", params);

                    rset.next();
                    meta_id = rset.getInt("currval");

                    params.put("meta_id", new Integer(meta_id));

                    rset = lc.executeQuery("all_info_keys", params);

                    while(rset.next()) {
                        String requestText = request.getParameter(rset.getString("key_id"));

                        if(requestText != null && !requestText.equals("")) {

                            params.put("key_id", new Integer(rset.getInt("key_id")));
                            params.put("value", requestText);

                            lc.executeUpdate("insert_meta_key_info", params);
                        }
                    }
                }

            } else if (action.equals("addContactToMeta")) {
                String service, username, addAll;
                boolean all = false;

                service = Util.checkNull(request.getParameter("service"));
                username = Util.checkNull(request.getParameter("username"));
                addAll = request.getParameter("all");

                meta_id = Util.checkInt(request.getParameter("meta_id"));
                user_id = Util.checkInt(request.getParameter("user_id"));

                params.put("meta_id", new Integer(meta_id));
                params.put("user_id", new Integer(user_id));
                params.put("service", service);
                params.put("username", username);

                if(addAll != null && addAll.equals("on")) {
                    all = true;
                }

                if((service != null || username != null) && !all) {
                    rset = lc.executeQuery("count_service_user", params);

                    rset.next();

                    if(rset.getInt(1) > 1) {
                        response.sendRedirect("addContact.jsp?meta_id=" +
                                meta_id + "&service=" + Util.safeString(service) +
                                "&username=" + Util.safeString(username));
                    } else if (rset.getInt(1) == 1) {
                        if(user_id != 0) {
                            reloadParent = false;
                            response.getWriter().println("<span style=\"color: red\">Error.  Please de-select a user from the pulldown or remove the typed field.</span>");
                        }
                        rset = lc.executeQuery("get_user_id", params);

                        rset.next();

                        user_id = rset.getInt("user_id");
                        params.put("user_id", new Integer(user_id));
                    }
                } else if ((service != null || username != null) && meta_id != 0 && all) {

                    lc.executeUpdate("add_all_users_to_meta", params);
                }

                if(meta_id != 0 && user_id != 0) {
                    lc.executeUpdate("add_user_to_meta", params);
                }

            } else if (action.equals("removeContactFromMeta")) {
                params.put("user_id", new Integer(Util.checkInt(request.getParameter("user_id"))));
                params.put("meta_id", new Integer(Util.checkInt(request.getParameter("meta_id"))));

                lc.executeUpdate("delete_user_from_meta", params);
                response.sendRedirect("meta.jsp");

            } else if (action.equals("removeMetaContact")) {
                params.put("meta_id", new Integer(Util.checkInt(request.getParameter("meta_id"))));
                params.put("key_id", new Integer(0));
                params.put("user_id", new Integer(0));

                lc.executeUpdate("delete_user_from_meta", params);

                lc.executeUpdate("delete_meta_info", params);

                lc.executeUpdate("delete_meta_contact", params);

                response.sendRedirect("meta.jsp");

            } else if (action.equals("changeMetaInfo")) {
                params.put("meta_id", new Integer(request.getParameter("meta_id")));
                params.put("name", request.getParameter("name"));

                String name = Util.checkNull(request.getParameter("name"));

                if(name != null && meta_id != 0) {
                    lc.executeUpdate("change_meta_name", params);

                    rset = lc.executeQuery("all_info_keys", params);

                    while(rset.next()) {
                        String requestText = request.getParameter(rset.getString("key_id"));
                        int returnVal;

                        params.put("value", requestText);
                        params.put("key_id", new Integer(rset.getInt("key_id")));

                        if(requestText != null && !requestText.equals("")) {
                            returnVal = lc.executeUpdate("update_meta_info", params);

                            if(returnVal == 0) {
                                lc.executeUpdate("insert_meta_key_info", params);
                            }
                        } else if (requestText == null || requestText.equals("")) {

                            lc.executeUpdate("delete_meta_info", params);
                        }
                    }
                }

            } else if (action.equals("updatePreferredMetaContact")) {
                params.put("user_id", new Integer(request.getParameter("user_id")));
                params.put("meta_id", new Integer(request.getParameter("meta_id")));

                lc.executeUpdate("preferred_true", params);

                lc.executeUpdate("preferred_false", params);

                response.sendRedirect("meta.jsp");
            }

            if(reloadParent)
                response.getWriter().println("<html><body onLoad=\"window.opener.parent.location.reload(); window.close()\"></body></html>");
        } catch (SQLException e) {
            response.getWriter().println(e.getMessage());
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }
    
    /** Returns a short description of the servlet.
     */
    public String getServletInfo() {
        return "Short description";
    }
    // </editor-fold>
    
    public void destroy() {
    }
}
