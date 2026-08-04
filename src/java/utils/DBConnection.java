package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DBConnection {

    // 1. Database Configuration
    private static final String URL = "jdbc:mysql://localhost:3306/schoolmanagement?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    // 2. Connection Pool Settings (Heerka Production-ka)
    private static final int INITIAL_POOL_SIZE = 5;  // Xiriirada diyaar ah marka Server-ka la shido
    private static final int MAX_POOL_SIZE = 50;     // Inta ugu badan ee isku mar nidaamka isticmaali karta
    
    private static final List<Connection> connectionPool = new ArrayList<>();
    private static final List<Connection> usedConnections = new ArrayList<>();

    // 3. Driver Load & Pool Initialization (Hal mar ayuu shaqaynayaa)
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("[LOG] MySQL Driver Loaded Successfully.");
            
            // Diyaari xiriirada ugu horreeya si degdeg loogu adeego qofka kowaad
            for (int i = 0; i < INITIAL_POOL_SIZE; i++) {
                connectionPool.add(createConnection());
            }
            System.out.println("[LOG] Connection Pool waa diyaar. Tirada xiriirada kaydka ah: " + INITIAL_POOL_SIZE);
        } catch (Exception e) {
            System.err.println("[ERROR] Cilad ayaa ku timid furitaanka Database-ka!");
            e.printStackTrace();
        }
    }

    // Abuur xiriir cusub
    private static Connection createConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // ==========================================
    // 4. HEL CONNECTION (Get Connection)
    // ==========================================
    // Ka qaado Pool-ka intii aad mid cusub samayn lahayd
    public static synchronized Connection getConnection() {
        try {
            if (connectionPool.isEmpty()) {
                if (usedConnections.size() < MAX_POOL_SIZE) {
                    connectionPool.add(createConnection());
                    System.out.println("[LOG] Xiriir dheeri ah ayaa la abuuray. (Dadka isticmaalaya: " + (usedConnections.size() + 1) + ")");
                } else {
                    System.err.println("[ERROR] Server-ku aad ayuu u mashquul yahay! Waxaa la gaaray xadkii (Max Pool Reached).");
                    return null;
                }
            }
            
            // Xiriirka ugu dambeeya ka bixi kaydka
            Connection conn = connectionPool.remove(connectionPool.size() - 1);
            
            // Hubi in xiriirku uusan dhicin ama go'in
            if (conn == null || conn.isClosed()) {
                conn = createConnection();
            }
            
            usedConnections.add(conn);
            return conn;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    // ==========================================
    // 5. DIB U CELIN CONNECTION (Release Connection)
    // ==========================================
    public static synchronized void releaseConnection(Connection conn) {
        if (conn != null) {
            usedConnections.remove(conn);
            connectionPool.add(conn);
            // System.out.println("[LOG] Connection dib ayaa loogu celiyay Pool-ka si qof kale u isticmaalo.");
        }
    }

    // ==========================================
    // 6. XIRIDA XOGTA (CLOSE METHODS)
    // ==========================================
    
    public static void close(ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    public static void close(PreparedStatement ps) {
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    public static void close(Statement st) {
        if (st != null) {
            try { st.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // MUHIIM: Hadda `close(conn)` maaha mid xiraya xiriirka gebi ahaanba!
    // Wuxuu dib ugu celinayaa kaydka (Pool) maadaama aan u baahanahay in mar kale la isticmaalo.
    public static void close(Connection conn) {
        releaseConnection(conn);
    }

    public static void close(Connection conn, Statement st, ResultSet rs) {
        close(rs);
        close(st);
        close(conn);
    }

    public static void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        close(rs);
        close(ps);
        close(conn);
    }

    // ==========================================
    // 7. AUTO TRANSACTIONS (Advanced Security)
    // ==========================================
    // Tani waxay muhiim u tahay Servlets-ka xogta badan diiwaangeliya (Sida AddTeacher)
    
    // Jooji Auto-Commit si xogta haddii ay isku dhegto aan badkeed la gudbin
    public static void beginTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(false);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Xogta si rasmi ah u wada kaydi
    public static void commitTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.commit();
                conn.setAutoCommit(true); // Dib u daaq nidaamka caadiga ah
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Haddii cillad timaado gudaha Servlet-ka, xogta la celiyo si uusan qashin u gelin Database-ka
    public static void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
                conn.setAutoCommit(true);
                System.out.println("[LOG] Transaction waa la joojiyay (Rolled Back) cilad awgeed. Xogtii waa badqabtaa.");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}