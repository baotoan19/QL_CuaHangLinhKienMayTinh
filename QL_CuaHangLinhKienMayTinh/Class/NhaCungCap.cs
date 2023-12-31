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
    internal class NhaCungCap
    {
        
        public int MaNCC {  get; set; }
        public string TenNCC {  get; set; }
        public string SDT {  get; set; }    
        public string DiaChi {  get; set; }
        public string Email {  get; set; }

        public NhaCungCap(int maNCC, string tenNCC, string sDT, string diaChi, string email)
        {
            MaNCC = maNCC;
            TenNCC = tenNCC;
            SDT = sDT;
            DiaChi = diaChi;
            Email = email;
        }
        public NhaCungCap()
        {

        }
        public static List<NhaCungCap> GetNhaCungCap()
        {
            List<NhaCungCap> lNhaCungCap = new List<NhaCungCap>();
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            try
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("DaTa_NhaCungCap", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    NhaCungCap lncc = new NhaCungCap();
                    lncc.MaNCC = int.Parse(reader["MaNCC"].ToString());
                    lncc.TenNCC = reader["TenNCC"].ToString();
                    lncc.SDT = reader["SDT"].ToString();
                    lncc.DiaChi = reader["DiaChi"].ToString();
                    lncc.Email = reader["Email"].ToString();


                    lNhaCungCap.Add(lncc);
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                con.Close();
            }
            return lNhaCungCap;
        }

        public int insertNhaCungCap()
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();

            try
            {
                SqlCommand cmd = new SqlCommand("insertNhaCungCap", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TenNCC", TenNCC);
                cmd.Parameters.AddWithValue("@SDT", SDT);
                cmd.Parameters.AddWithValue("@Email", Email);
                cmd.Parameters.AddWithValue("@DiaChi", DiaChi);

                int result = cmd.ExecuteNonQuery();
                return result;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }

        public int updateNhaCungCap(int MaNCC)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();

            SqlCommand cmd = new SqlCommand("updateNhaCungCap", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@MaNCC", MaNCC);
            cmd.Parameters.AddWithValue("@TenNCC", TenNCC);
            cmd.Parameters.AddWithValue("@SDT", SDT);
            cmd.Parameters.AddWithValue("@Email", Email);
            cmd.Parameters.AddWithValue("@DiaChi", DiaChi);
            //PrintMessage = "";
            //con.InfoMessage += (object inforSender, SqlInfoMessageEventArgs inforArgs) =>
            //{
            //    PrintMessage += inforArgs.Message + Environment.NewLine;
            //};
            int result = cmd.ExecuteNonQuery();
            return result;
        }

        public int deleteNhaCungCap(int MaNCC)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();

            SqlCommand cmd = new SqlCommand("DeleteNhaCungCap", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@MaNCC", MaNCC);
            //PrintMessage = "";
            //con.InfoMessage += (object inforSender, SqlInfoMessageEventArgs inforArgs) =>
            //{
            //    PrintMessage += inforArgs.Message + Environment.NewLine;
            //};
            int result = cmd.ExecuteNonQuery();
            return result;
        }
    }
}
