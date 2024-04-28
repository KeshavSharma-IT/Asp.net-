namespace StocksDemo.Models
{
    public class Stocks
    {
        public int StockId { get; set; }
        public string MachineNumber { get; set; }
        public string VendorName { get; set; }
        public int VendorId { get; set; }
        public int MachineID { get; set; }
        public int FabricID { get; set; }
        
        public string BillNo { get; set; }
        public DateTime? BillDate { get; set; }
        public string FabricName { get; set; }
        public decimal Weight { get; set; }
        public DateTime? StockInDate { get; set; }
        public DateTime? StockOutDate { get; set; }
    }

    public class Vender
          
    {
       public int VendorId { get; set; }
       public string VendorName { get; set; }
       public string VendorAddress { get; set; }
    }

    public class Excel
    {
        public IFormFile File { get; set; }
    }

}
