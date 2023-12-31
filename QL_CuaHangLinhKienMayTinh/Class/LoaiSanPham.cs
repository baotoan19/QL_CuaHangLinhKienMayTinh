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
    internal class LoaiSanPham
    {
        public int MaLoai { get; set; }
        public string TenLoai { get; set; }

        public LoaiSanPham(int maLoai, string tenLoai)
        {
            MaLoai = maLoai;
            TenLoai = tenLoai;
        }

        public LoaiSanPham()
        {

        }
        public static List<LoaiSanPham> GetLoaiSanPham()
        {
            List<LoaiSanPham> lLoaiSanPham = new List<LoaiSanPham>();
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            try
            {
                con.Open();
                SqlCommand cmd = new SqlCommand("DaTa_LoaiSanPham", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                SqlDataReader reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    LoaiSanPham lsp = new LoaiSanPham();
                    lsp.MaLoai = int.Parse(reader["MaLoai"].ToString());
                    lsp.TenLoai = reader["TenLoai"].ToString();
                    lLoaiSanPham.Add(lsp);
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
            return lLoaiSanPham;
        }
        public int insertLoaiSanPham()
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            try
            {

                SqlCommand cmd = new SqlCommand("insertLoaiSanPham", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TenLoai", TenLoai);
                int result = cmd.ExecuteNonQuery();
                return result;
            }
            catch (Exception ex)
            {
                return -1;
            }
        }
        public int updateLoaiSanPham()
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();

            SqlCommand cmd = new SqlCommand("updateLoaiSanPham", con);
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@MaLoai", MaLoai);
            cmd.Parameters.AddWithValue("@TenLoai", TenLoai);
            //PrintMessage = "";
            //con.InfoMessage += (object inforSender, SqlInfoMessageEventArgs inforArgs) =>
            //{
            //    PrintMessage += inforArgs.Message + Environment.NewLine;
            //};
            int result = cmd.ExecuteNonQuery();
            return result;
        }

        public int deleteLoaiSanPham()
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();

            SqlCommand cmd = new SqlCommand("DeleteLoaiSanPham", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@MaLoai", MaLoai);
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
