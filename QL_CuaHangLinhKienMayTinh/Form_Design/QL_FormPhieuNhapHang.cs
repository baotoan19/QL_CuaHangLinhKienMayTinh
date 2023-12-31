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
    public partial class QL_FormPhieuNhapHang : Form
    {
        public QL_FormPhieuNhapHang()
        {
            InitializeComponent();
        }

        private void QL_FormPhieuNhapHang_Load(object sender, EventArgs e)
        {
            Load_DataGirdView_CTPN();
        }
        private void Load_DataGirdView_CTPN()
        {
            List<ChiTietPhieuNhapHang> ctpn = ChiTietPhieuNhapHang.GetCTPhieuNhap();
            dataGridView_CTPNH.Columns.Clear();
            dataGridView_CTPNH.DataSource = null;
            dataGridView_CTPNH.DataSource = ctpn;
            dataGridView_CTPNH.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }


        private void btn_exits_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Bạn muốn Thoát?", "Thông báo",
             MessageBoxButtons.YesNo, MessageBoxIcon.Warning,
             MessageBoxDefaultButton.Button2) == System.Windows.Forms.DialogResult.Yes)
            {
                this.Close();
            }
        }

        private void btn_saves_Click(object sender, EventArgs e)
        {
            Load_DataGirdView_CTPN();
        }

        private void btn_search_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            con.Open();
            string mapn = txt_Search_maPhieus.Text;
            string searchQuery = "SELECT \r\n  p.MaPhieu,\r\n  s.MaSP,\r\n  ct.SoLuongNhap,\r\n  ct.DonGiaNhap,\r\n  ct.ThanhTien,\r\n  n.TenNV,\r\n  s.TenSP, \r\n  p.NgayNhap\r\n  \r\nFROM PHIEUNHAPHANG p\r\nINNER JOIN NhanVien n ON p.MaNV = n.MaNV\r\nINNER JOIN CHITIETPN ct ON p.MaPhieu = ct.MaPhieu\r\nINNER JOIN SanPham s ON ct.MaSP = s.MaSP\r\nWHERE p.MaPhieu=@mapn";
            SqlCommand cmd = new SqlCommand(searchQuery, con);
            cmd.Parameters.Add("@mapn", SqlDbType.NVarChar).Value = mapn;
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            dataGridView_CTPNH.DataSource = dt;


            int tongSoLuong = 0;
            string sql = "SELECT SUM(SoLuongNhap) " +
                         "FROM ChiTietPN " +
                         "WHERE MaPhieu = @mapn";

            using (SqlCommand cmd1 = new SqlCommand(sql, con))
            {
                cmd1.Parameters.Add("@mapn", SqlDbType.NVarChar).Value = mapn;
                try
                {
                    tongSoLuong = int.Parse(cmd1.ExecuteScalar().ToString());
                }
                catch
                {
                    tongSoLuong = 0;
                }
            }

            txt_sumPN.Text = tongSoLuong.ToString();
            con.Close();
        }

        private void dataGridView_CTPN_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            int r = dataGridView_CTPNH.CurrentCell.RowIndex;
            txt_maPhieu.Text = dataGridView_CTPNH.Rows[r].Cells[0].Value.ToString();
            txt_maSP.Text = dataGridView_CTPNH.Rows[r].Cells[1].Value.ToString();
            txt_SLN.Text = dataGridView_CTPNH.Rows[r].Cells[2].Value.ToString();
            txt_DGN.Text = dataGridView_CTPNH.Rows[r].Cells[3].Value.ToString();
            txt_ThanhTien.Text = dataGridView_CTPNH.Rows[r].Cells[4].Value.ToString();
        }

        private void txt_SLN_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void txt_DGN_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void txt_ThanhTien_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void txt_Search_maPhieus_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }
    }
}
