using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QL_CuaHangLinhKienMayTinh.Class;
namespace QL_CuaHangLinhKienMayTinh.Form_Design
{
    public partial class QL_FormHoaDon : Form
    {
        public QL_FormHoaDon()
        {
            InitializeComponent();
        }

        private void QL_FormHoaDon_Load(object sender, EventArgs e)
        {
            Load_DataGirdView_HD();
            Load_DataGirdView_CTHD();
            DemSLHD();
            TongTienALL();
        }

        private void Load_DataGirdView_HD()
        {
            List<HoaDon> hd = HoaDon.GetHoaDon();
            dataGridView_HD.Columns.Clear();
            dataGridView_HD.DataSource = null;
            dataGridView_HD.DataSource = hd;
            dataGridView_HD.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }

        private void Load_DataGirdView_CTHD()
        {
            List<ChiTietHoaDon> cthd = ChiTietHoaDon.GetCTHoaDon();
            dataGridView_CTHD.Columns.Clear();
            dataGridView_CTHD.DataSource = null;
            dataGridView_CTHD.DataSource = cthd;
            dataGridView_CTHD.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }

        private void DemSLHD()
        {
            int soLuongHoaDon = 0;

            string sql = "SELECT COUNT(*) FROM HoaDon";
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                soLuongHoaDon += (int)cmd.ExecuteScalar();
            }

            txt_SLHD.Text = soLuongHoaDon.ToString();
        }

        private void TongTienALL()
        {
            decimal tongTien = 0;

            string sql = "SELECT SUM(TongTien) FROM HoaDon";
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                tongTien = decimal.Parse(cmd.ExecuteScalar().ToString());
            }

            txt_TongTienALL.Text = tongTien.ToString();
        }

        private void dataGridView_HD_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            int r = dataGridView_HD.CurrentCell.RowIndex;
            txt_maHD.Text = dataGridView_HD.Rows[r].Cells[0].Value.ToString();
            txt_maKH.Text = dataGridView_HD.Rows[r].Cells[1].Value.ToString();
            txt_maNV.Text = dataGridView_HD.Rows[r].Cells[2].Value.ToString();
            maskedTextBox_NgayXuatHD.Text = dataGridView_HD.Rows[r].Cells[3].Value.ToString();
            txt_TongTien.Text = dataGridView_HD.Rows[r].Cells[4].Value.ToString();
        }

        private void dataGridView_CTHD_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            int r = dataGridView_CTHD.CurrentCell.RowIndex;
            txt_mahd_CT.Text = dataGridView_CTHD.Rows[r].Cells[0].Value.ToString();
            txt_maSP.Text = dataGridView_CTHD.Rows[r].Cells[1].Value.ToString();
            txt_SLB.Text = dataGridView_CTHD.Rows[r].Cells[2].Value.ToString();
            txt_ThanhTien.Text = dataGridView_CTHD.Rows[r].Cells[3].Value.ToString();
        }

        private void btn_Search_KH_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            string tenkh = txt_Search_tenKH.Text;
            string searchQuery = "SELECT HOADON.*,TENKH FROM HoaDon,KHACHHANG WHERE HoaDon.MaKH=KHACHHANG.MaKH and TenKh LIKE @tenkh";
            SqlCommand cmd = new SqlCommand(searchQuery, con);
            cmd.Parameters.Add("@tenkh", SqlDbType.NVarChar).Value = "%" + tenkh + "%";
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            dataGridView_HD.DataSource = dt;
            con.Close();
        }

        private void btn_Search_NgayMua_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            string ngaymua = maskedTextBox_ngayMua.Text;
            string searchQuery = "SELECT HOADON.* ,TENKH FROM HoaDon,KHACHHANG WHERE HoaDon.MaKH=KHACHHANG.MaKH and NgayXuatHD =  @ngaymua";
            SqlCommand cmd = new SqlCommand(searchQuery, con);
            cmd.Parameters.Add("@ngaymua", SqlDbType.DateTime).Value = ngaymua;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            dataGridView_HD.DataSource = dt;
        }

        private void btn_Search_maHD_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            string mahd = txt_Search_maHD.Text;
            string searchQuery = "SELECT \r\n  h.MaHD,\r\n  s.MaSP,\r\n  ct.SoLuongBan,\r\n  ct.ThanhTien,\r\n  k.TenKH,\r\n  s.TenSP,\r\n  s.GiaBan\r\nFROM HoaDon h\r\nINNER JOIN KhachHang k ON h.MaKH = k.MaKH  \r\nINNER JOIN ChiTietHD ct ON h.MaHD = ct.MaHD\r\nINNER JOIN SanPham s ON ct.MaSP = s.MaSP\r\nWHERE H.MaHD=@mahd";
            SqlCommand cmd = new SqlCommand(searchQuery, con);
            cmd.Parameters.Add("@mahd", SqlDbType.NVarChar).Value = mahd;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            dataGridView_CTHD.DataSource = dt;


            int tongSoLuong = 0;
            string sql = "SELECT SUM(SoLuongBan) AS TongSoLuong " +
                         "FROM ChiTietHD " +
                         "WHERE MaHD = @mahd";

            using (SqlCommand cmd1 = new SqlCommand(sql, con))
            {
                cmd1.Parameters.Add("@mahd", SqlDbType.NVarChar).Value = mahd;
                try
                {
                    tongSoLuong = int.Parse(cmd1.ExecuteScalar().ToString());
                }
                catch
                {
                    tongSoLuong = 0;
                }
            }

            txt_SLSPHD.Text = tongSoLuong.ToString();

            con.Close();
        }
    }
}
