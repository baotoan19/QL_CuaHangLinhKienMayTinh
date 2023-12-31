using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace QL_CuaHangLinhKienMayTinh.Class
{
    class DoanhThu
    {
        public DataTable GetDoanhThuTheoThang(int nam)
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection con = new SqlConnection(ConnectDB.conSql))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("GET_DOANHTHUTHEOTHANG", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@nam", nam);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }

            return dt;
        }
        public DataTable GetDoanhThuTheoNgay(int thang, int nam)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection con = new SqlConnection(ConnectDB.conSql))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("GET_DOANHTHUTHEONGAY", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@thang", thang);
                    cmd.Parameters.AddWithValue("@nam", nam);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message);
            }

            return dt;
        }
    }
}
