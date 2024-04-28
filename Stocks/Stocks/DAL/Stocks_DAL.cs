namespace StocksDemo.Models;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.Data;
using System.Data.SqlClient;



public class Stocks_DAL
{
    SqlConnection con;
    SqlCommand _cmd;

    public static IConfiguration Configuration { get; set; }

    public string getConnectionString()
    {
        var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
        Configuration = builder.Build();
        return Configuration.GetConnectionString("DbConnection");

    }


    public List<Stocks> GetFullStockReport()
    {
        List<Stocks> StocksList = new List<Stocks>();
        using (SqlConnection con = new SqlConnection(getConnectionString()))
        {
            SqlCommand _cmd = con.CreateCommand();
            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "GetStockReport";
            con.Open();
            SqlDataReader dr = _cmd.ExecuteReader();
            while (dr.Read())
            {
                Stocks stocks = new Stocks();
                stocks.StockId = Convert.ToInt32(dr["StockID"]);
                stocks.VendorName = dr["VendorName"].ToString();
                stocks.BillNo = dr["BillNo"].ToString();
                stocks.BillDate = dr["BillDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["BillDate"]) : null;
                stocks.FabricName = dr["FabricName"].ToString();
                stocks.Weight = (decimal)Convert.ToDouble(dr["Weight"]);
                //stocks.StockInDate = Convert.ToDateTime(dr["StockInDate"]);
                stocks.StockInDate = dr["StockInDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["StockInDate"]) : null;
                stocks.StockOutDate = dr["StockOutDate"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(dr["StockOutDate"]) : null;

                stocks.MachineNumber = dr["Lot"].ToString();
                StocksList.Add(stocks);
            }
            con.Close();
        }

        return StocksList;
    }

    public List<Vender> GetVenderList()
    {
        List<Vender> venderList = new List<Vender>();
        using (SqlConnection con = new SqlConnection(getConnectionString()))
        {
            SqlCommand _cmd = con.CreateCommand();
            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "GetActiveVendors";
            con.Open();
            SqlDataReader dr = _cmd.ExecuteReader();
            while (dr.Read())
            {
                Vender vender = new Vender(); 
                vender.VendorId = Convert.ToInt32(dr["VendorId"]);
                vender.VendorName = dr["VendorName"].ToString();
                vender.VendorAddress = dr["VendorAddress"].ToString();
                venderList.Add(vender);
            }
            con.Close();
        }
        return venderList;
    }

    public string AddVendor(StocksDemo.Models.Vender Obj, int Action)
    {
        string message = string.Empty;
        using (SqlConnection con = new SqlConnection(getConnectionString()))
        {
            SqlCommand _cmd = con.CreateCommand();
            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "AddVendor";
            _cmd.Parameters.AddWithValue("@Action", Action);
            _cmd.Parameters.AddWithValue("@VendorId", Obj.VendorId);
            _cmd.Parameters.AddWithValue("@VendorName", Obj.VendorName);
            _cmd.Parameters.AddWithValue("@VendorAddress", Obj.VendorAddress);
            _cmd.Parameters.Add("@Message", SqlDbType.NVarChar, 255).Direction = ParameterDirection.Output;
            con.Open();
            _cmd.ExecuteNonQuery();
            message = _cmd.Parameters["@Message"].Value.ToString();
            con.Close();
        }
        return message;
    }

    public string AddStock(StocksDemo.Models.Stocks Obj)
    {
        string message = string.Empty;
        using (SqlConnection con = new SqlConnection(getConnectionString()))
        {
            SqlCommand _cmd = con.CreateCommand();
            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "AddStockProcedure";
            _cmd.Parameters.AddWithValue("@VendorId", Obj.VendorId);
            _cmd.Parameters.AddWithValue("@BillNo", Obj.BillNo);
            _cmd.Parameters.AddWithValue("@BillDate", Obj.BillDate);
            _cmd.Parameters.AddWithValue("@MachineID", Obj.MachineID);
            _cmd.Parameters.AddWithValue("@FabricID", Obj.FabricID);
            _cmd.Parameters.AddWithValue("@Weight", Obj.Weight);
            _cmd.Parameters.Add("@Message", SqlDbType.NVarChar, 255).Direction = ParameterDirection.Output;
            con.Open();
            _cmd.ExecuteNonQuery();
            message = _cmd.Parameters["@Message"].Value.ToString();
            con.Close();
        }
        return message;
    }

    
    public string DeleteVendor(int vendorId)
    {
        string message = string.Empty;
        using (SqlConnection con = new SqlConnection(getConnectionString()))
        {
            SqlCommand _cmd = con.CreateCommand();
            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "DeleteVendor";
            _cmd.Parameters.AddWithValue("@VendorId", vendorId);
            con.Open();
            message = _cmd.ExecuteScalar()?.ToString();
            con.Close();
        }
        return message;
    }
    public string Checkout(int stockId)
    {
        string result = string.Empty;
        using (SqlConnection con = new SqlConnection(getConnectionString()))
        {
            SqlCommand _cmd = con.CreateCommand();
            _cmd.CommandType = CommandType.StoredProcedure;
            _cmd.CommandText = "StockOut";
            _cmd.Parameters.AddWithValue("@StockID", stockId);
            _cmd.Parameters.Add("@result", SqlDbType.NVarChar, 255).Direction = ParameterDirection.Output;
            con.Open();
            result = _cmd.ExecuteScalar()?.ToString();
            con.Close();
        }
        return result;
    }

    public void StoreDataInDatabase(DataTable table)
    {
        using (var connection = new SqlConnection(getConnectionString()))
        {
            connection.Open();
            using (var sqlBulkCopy = new SqlBulkCopy(connection))
            {
                sqlBulkCopy.DestinationTableName = table.TableName;
                foreach (DataColumn column in table.Columns)
                {
                    sqlBulkCopy.ColumnMappings.Add(column.ColumnName, column.ColumnName);
                }
                sqlBulkCopy.WriteToServer(table);
            }
        }
    }
}


