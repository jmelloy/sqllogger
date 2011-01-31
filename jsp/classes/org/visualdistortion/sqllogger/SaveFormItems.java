/*
 * $URL: http://svn.visualdistortion.org/repos/projects/sqllogger/jsp/classes/org/visualdistortion/sqllogger/SaveFormItems.java $
 * $Id: SaveFormItems.java 1093 2005-07-04 14:40:51Z jmelloy $
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
 * Saves form items passed to it.
 *
 * @author      Jeffrey Melloy &lt;jmelloy@visualdistortion.org&gt;
 * @version     $Rev: 1093 $ $Date: 2005-07-04 09:40:51 -0500 (Mon, 04 Jul 2005) $
 **/
public class SaveFormItems extends HttpServlet {

    public void init() throws ServletException {
    }

    public void processRequest(HttpServletRequest request,
            HttpServletResponse response)
        throws ServletException, IOException {

        LibraryConnection lc = (LibraryConnection) request.getAttribute("lc-update");
        Map params = new HashMap();

        ResultSet rset = null;

        try {

            String action = Util.checkNull(request.getParameter("action"));

            if(action != null && action.equals("saveForm")) {

                params.put("title", request.getParameter("title"));
                params.put("notes", request.getParameter("notes"));
                params.put("type", request.getParameter("type"));

                lc.executeUpdate("insert_saved_form", params);

                params.put("sequence", "saved_items_item_id_seq");

                rset = lc.executeQuery("currval", params);

                rset.next();

                params.put("seq", new Integer(rset.getInt(1)));

                Enumeration e = request.getParameterNames();

                while(e.hasMoreElements()) {
                    String key = (String) e.nextElement();

                    if(!key.equals("title") && !key.equals("notes") && !key.equals("type") && !key.equals("action")) {
                        params.put("key", key);
                        String value = Util.checkNull(request.getParameter(key));

                        if(value != null) {
                            params.put("value", value);

                            lc.executeUpdate("insert_saved_fields", params);
                        }
                    }
                }
            } else if (action != null && action.equals("saveNote")) {
                    params.put("message_id", new Integer(request.getParameter("message_id")));
                    params.put("title", request.getParameter("title"));
                    params.put("notes", request.getParameter("notes"));
                    lc.executeUpdate("insert_message_note", params);

            } else if (action != null && action.equals("updateFields")) {
                String returnVar  = request.getParameter("return");

                Enumeration e = request.getParameterNames();
                List l = new ArrayList();

                while(e.hasMoreElements()) {
                    try {
                        l.add(new Integer((String) e.nextElement()));
                    } catch (NumberFormatException err) {
                        // do nothing
                    }
                }

                params.put("key_list", l);
                lc.executeUpdate("delete_keys", params);
                lc.executeUpdate("undelete_keys", params);

                for(int i = 1; i <= 3; i++) {
                    String req = request.getParameter("new" + i);

                    if(req != null && !req.equals("")) {
                        params.put("name", req);

                        lc.executeUpdate("insert_key", params);
                    }
                }
                response.sendRedirect(returnVar);
            }

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
