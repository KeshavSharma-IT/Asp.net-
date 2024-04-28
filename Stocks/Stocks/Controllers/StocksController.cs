using ExcelDataReader;
using Microsoft.AspNetCore.Mvc;
using StocksDemo.Models;
using System.Data;
using System.Numerics;
using System.Text;


namespace Stocks.Controllers
{

    public class StocksController : Controller
    {
        private readonly Stocks_DAL _context;

        public StocksController()
        {
            _context = new Stocks_DAL();
        }

        public ActionResult Index()
        {
            var stockTransactions = _context.GetFullStockReport().ToList();
            TempData["Message"] = "Welcome";
            return View(stockTransactions);
        }

        public ActionResult Vender()
        {
            ViewBag.Action = 1;
            var venderList = _context.GetVenderList().ToList(); 
            return View(venderList);
        }

        public ActionResult VenderName()
        {
            var venderList = _context.GetVenderList().ToList();
            return Json(venderList);
        }


        /* [HttpPost]
         public ActionResult AddVendor(StocksDemo.Models.Vender Obj,int Action)
         {
             if (Action == 1)
             {
                 string message = _context.AddVendor(Obj,Action);
                 if (message != "success")
                 {
                     TempData["errorMessage"] = "server error";
                     ViewBag.Action = 1;
                     return View();
                 }
                 TempData["successMessage"] = "Data  saved";
                 return RedirectToAction("Vender", _context.GetVenderList().ToList());
             }
             else
             {
                 string message = _context.AddVendor(Obj,Action);
                 if (message != "success")
                 {
                     TempData["errorMessage"] = "server error";
                     ViewBag.Action = 1;
                     return View();
                 }
                 TempData["successMessage"] = "Data  saved";
                 return RedirectToAction("Vender", _context.GetVenderList().ToList());
             }

         }
 */
        [HttpPost]
        public ActionResult AddVendor(StocksDemo.Models.Vender Obj)
        {
            int Action;
            if (Obj.VendorId == 0)
            {
                 Action = 1;
            }
            else
            {
                 Action = 0;
            }
             string message = _context.AddVendor(Obj,Action);
            if (message != "success")
            {
                TempData["errorMessage"] = "server error";
                TempData["Message"] = "server error";
                return View();
            }
            TempData["Message"] = "Data saved";
            TempData["successMessage"] = "Data saved";
            return RedirectToAction("Vender", _context.GetVenderList().ToList());
        }

        [HttpPost]
        public ActionResult DeleteVendor(int vendorId)
        {
            string message = _context.DeleteVendor(vendorId);
            if (message == "Vendor deleted successfully")
            {
                /*TempData["successMessage"] = "Vendor deleted successfully";*/
                return Json(new { success = true });
            }
            else
            {
                /*TempData["errorMessage"] = "Failed to delete vendor";*/
                return Json(new { success = false, errorMessage = "Failed to delete vendor" });
            }
            /*return RedirectToAction("Vender")*/
            //return View();
        }
        [HttpPost]
        public ActionResult AddStock(StocksDemo.Models.Stocks Obj)
        {
            string message = _context.AddStock(Obj);
            if (message != "Success")
            {
                TempData["Message"] = "server error";
            }
            else
            {
                TempData["Message"] = "Data saved";
            }
            return RedirectToAction("Index");
        }
        [HttpPost]
        public ActionResult Checkout(int stockId)
        {
            string message = _context.Checkout(stockId);
            if (message != "success")
            {
                TempData["errorMessage"] = "server error";
                TempData["Message"] = "Data saved";
            }
            else
            {
                TempData["successMessage"] = "Data saved";
                TempData["Message"] = "Data saved";
            }
            return RedirectToAction("Index");
        }

        
        
        public ActionResult Excel()
        {
            return View();
        }
        [HttpPost]
        public ActionResult ExcelUplode(IFormFile file)
        {

            if (file != null && file.Length > 0)
            {
                try
                {
                    using (var stream = file.OpenReadStream())
                    {
                        byte[] bytes;
                        using (var memoryStream = new MemoryStream())
                        {
                            stream.CopyTo(memoryStream);
                            bytes = memoryStream.ToArray();
                        }

                        // Register the CodePageProvider for handling encoding (if using .NET Core)
                        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

                        // Convert the binary stream to a MemoryStream
                        using (var memoryStream = new MemoryStream(bytes))
                        using (var reader = ExcelReaderFactory.CreateReader(memoryStream, new ExcelReaderConfiguration()
                        {
                            // Optional: Set FallbackEncoding to UTF-8 if confident about file encoding
                            // FallbackEncoding = Encoding.UTF8,
                            AutodetectSeparators = new char[] { ',', ';', '\t' } // Autodetect separators
                        }))
                        {
                            var result = reader.AsDataSet(new ExcelDataSetConfiguration()
                            {
                                ConfigureDataTable = (_) => new ExcelDataTableConfiguration() { UseHeaderRow = true }
                            });

                            DataTable table = result.Tables[0];
                            string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(file.FileName);
                            table.TableName = fileNameWithoutExtension;
                            _context.StoreDataInDatabase(table);
                        }
                    }

                    TempData["Message"] = "File uploaded successfully.";
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = "Error: " + ex.Message;
                }
            }
            else
            {
                TempData["ErrorMessage"] = "Please select a file to upload.";
            }

            return RedirectToAction("Excel");
        }
    }
}
