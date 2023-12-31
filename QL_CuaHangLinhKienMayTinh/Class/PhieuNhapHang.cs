﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;
using QL_CuaHangLinhKienMayTinh.Crystal_Reports;
using QL_CuaHangLinhKienMayTinh.Form_Design;

namespace QL_CuaHangLinhKienMayTinh.Class
{
    internal class PhieuNhapHang
    {
        public int MaPhieu { get; set; }
        public int MANV { get; set; }
        public DateTime NgayNhap { get; set; }
        public string GhiChu { get; set; }
        public double TongTienNhap { get; set; }

        public PhieuNhapHang(int manv, DateTime ngayNhap, string ghiChu, double tongtiennhap)
        {
            MANV = manv;
            NgayNhap = ngayNhap;
            GhiChu = ghiChu;
            TongTienNhap = tongtiennhap;
        }
        public int insertPhieuNhap()
        {
            int maPhieu = -1;
            SqlConnection conSql = new SqlConnection(ConnectDB.conSql);
            conSql.Open();
            SqlCommand cmd = new SqlCommand("insertPhieuNhap", conSql);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@MaNV", this.MANV);
            cmd.Parameters.AddWithValue("@NgayNhap", this.NgayNhap);
            cmd.Parameters.AddWithValue("@GhiChu", GhiChu);
            cmd.Parameters.AddWithValue("@TongTienNhap", this.TongTienNhap);

            try
            {
                cmd.ExecuteNonQuery();
                SqlCommand cmdGetMaxMaPN = new SqlCommand("MAX_MAPN", conSql);
                cmdGetMaxMaPN.CommandType = CommandType.StoredProcedure;

                object result = cmdGetMaxMaPN.ExecuteScalar();
                if (result != DBNull.Value)
                {
                    maPhieu = Convert.ToInt32(result);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: Thêm Phiếu Nhập: " + ex.Message, "Thông Báo", MessageBoxButtons.OK, MessageBoxIcon.Error);

            }
            finally
            {
                conSql.Close();
            }
            return maPhieu;
        }
        public void inPhieuNhap(int maPhieu)
        {
            SqlConnection con = new SqlConnection(ConnectDB.conSql);
            SqlCommand cmd = new SqlCommand("InPhieuNhap", con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@MaPhieu", maPhieu);
            DataTable dt = new DataTable();
            SqlDataAdapter da = new SqlDataAdapter();
            da.SelectCommand = cmd;
            da.Fill(dt);
            rptInPhieuNhap rpt = new rptInPhieuNhap();
            rpt.SetDataSource(dt);
            FormInPhieuNhap frmIn = new FormInPhieuNhap();
            frmIn.crystalReportViewer1.ReportSource = rpt;
            frmIn.ShowDialog();
        }


    }
}

