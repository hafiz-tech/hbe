class ApiUrls{
  //API's KEYS AND BASE URL
  static String apikey = "8156sdcas1dcc1d8c4894Coiuj784C8941e856";
  static String baseURL = "https://hgeapi.devstackdigital.com/API/";
  static String distributorUrl = "https://hgeapi.devstackdigital.com/API/Distributor/";
  static String key_name = "Web_API_Key";

  //FIREBASE SERVER KEY
  static String firebaseKey = "AAAAqYJU-Z4:APA91bF0XAZVpEklUwCCX8J9TfW9Xrebk0OEGO1Z2YSJFtjDHqZomilPWNxsPfSUjkgYoT2KE5OOnsjcCGhDypYDuBZxB-rDw6PLJAbXiktpf0U8z9RHxrIZ1egNhG6Uj-Xk4FjGzAGj";


  /* ---- AUTH APIS ---- */

  //LOGIN API
  static String getLoginUserDetails ="Auth/GetLoginUserDetails";
  static String getLoginUser ="GetLoginUserDetails";
  // RESET/CHANGE PASSWORD API
  static String resetPassword="Auth/ResetPassword";
  //GET MENU ITEMS API
  static String getMenuList= "Auth/GetMenuList";
  static String getMenuList2= "GetMenuList";

  /* ---- DASHBOARD APIS ---- */

  //GET DASHBOARD ATTENDANCE COUNT API
  static String getDashBoardAttendanceCount ="Dashboard/GetDashBoardAttendanceCount";
  //GET DASHBOARD ATTENDANCE API
  static String getDashBoardAttendance ="Dashboard/GetDashBoardAttendance";
  //GET EMP ATTENDANCE REPORT API
  static String getAttendanceReportUrl="Dashboard/GetAttendanceReportUrl";
  //GET STORE ATTENDANCE REPORT API
  static String getStoreAttendanceReportUrl= "Dashboard/GetStoreAttendanceReportUrl";
  //GET EMP STORE ATTENDANCE API
  static String getStoreDashBoardAttendance = "Dashboard/GetStoreDashBoardAttendance";
  //GET WEEKLY DATA API
  static String getWeeklyGraph="Dashboard/GetWeeklyGraph";
  //GET MONTHLY DATA API
  static String getMonthlyGraph="Dashboard/GetMonthlyGraph";
  //GET SALE TARGET API
  static String getSaleTargetDetails="Dashboard/GetSaleTargetDetails";



  /* ---- ATTENDANCE RELATED APIS ---- */

  //MARK ATTENDANCE API
  static String markAttendance="Auth/MarkAttendanceNew";
  static String markAttendance2="MarkAttendanceNew";
  //MARK LEAVE API
  static String markLeave="Auth/MarkLeave";
  static String markLeave2="MarkLeave";
  //GET LEAVE TYPES API
  static String getLeaveType= "Auth/GetLeaveType";
  //GET MAPPED CUSTOMERS API
  static String getMappedCustomer="KeyAccount/GetMapedCustomer";
  static String getMappedCustomer2="GetMapedCustomer";
  //ADD NEW IMAGE API
  static String addNewImage="KeyAccount/AddNewImage";
  //GET USER IMAGE LIST API
  static String getMerchandiser_ImagesList="KeyAccount/GetMerchandiser_ImagesList";


  /* ---- SALES ORDER APIS ---- */

  //GET DAILY SALE API
  static String getSaleDetails="KeyAccount/GetSaleDetails";
  //DELETE DAILY SALE API
  static String deleteSale="KeyAccount/DeleteSale";
  //POST DAILY SALE API
  static String postSale="KeyAccount/PostSale";
  //UPDATE MASTER SALE API
  static String updateMasterSale= "KeyAccount/UpdateMstrSale";
  //DELETE MASTER SALE API
  static String deleteDetSale= "KeyAccount/DeleteDetSale";
  //SUBMIT MASTER INVOICE API
  static String submitMstrSale="KeyAccount/SubmitMstrSale";
  //SUBMIT MASTER SALE API
  static String submitDetSale= "KeyAccount/SubmitDetSale";
  //UPDATE NEW SALE API
  static String getSaleDetails_Single2 = "KeyAccount/GetSaleDetails_Single";
// UPDATE USER LOCATION
  static String updateUserLocation ="Auth/UpdateUserLocation";

  /* ---- SALE RETURN APIS ---- */

  //1- GET MAPPED CUSTOMER API
  static String getSaleDetailsR="SaleReturn/GetSaleDetails";
  //2- GET MAPPED CUSTOMER API
  static String getMappedCustomerR="SaleReturn/GetMapedCustomer";
  //3- GET PRODUCT LIST BY CUSTOMER
  static String getRListCustomer="SaleReturn/GetProductListByCustomer";
  //4- POST DAILY SALE API
  static String postSaleR="SaleReturn/PostSale";
  //5- DELETE SALE RETURN API
  static String deleteSaleR="SaleReturn/DeleteSale";
  //6- UPDATE MASTER SALE API
  static String updateMasterSaleR= "SaleReturn/UpdateMstrSale";
  //7- DELETE MASTER SALE API
  static String deleteDetSaleR= "SaleReturn/DeleteDetSale";
  //8- SUBMIT MASTER INVOICE API
  static String submitMasterSaleR="SaleReturn/SubmitMstrSale";
  //9- SUBMIT MASTER SALE API
  static String submitDetSaleR= "SaleReturn/SubmitDetSale";
  //10- GetSaleDetails_Single SALE API
  static String getSaleDetailsSingleR = "SaleReturn/GetSaleDetails_Single";

  /* ---- PURCHASE ORDER APIS ---- */

  //GET PO INVOICE API
  static String getPODetails="KeyAccount/GetPODetails";
  //DELETE PO INVOICE API
  static String deletePO="KeyAccount/DeletePO";
  //POST PO INVOICE API
  static String postPO="KeyAccount/PostPO";
  //GET PRODUCT BY CUSTOMER ID API
  static String getProductListByCustomer= "Invoice/GetProductListByCustomer";
  //SUBMIT MASTER PO API
  static String submitMasterPO= "KeyAccount/SubmitMstrPO";
  //SUBMIT DETAIL OF PO API
  static String submitDetPO= "KeyAccount/SubmitDetPO";
  //UPDATE MASTER INVOICE API
  static String updateMasterPO="KeyAccount/UpdateMstrPO";
  //DELETE INVOICE DETAIL API
  static String deleteDetPO= "KeyAccount/DeleteDetPO";
  //UPDATE NEW INVOICE DETAIL API
  static String getPODetails_Single= "KeyAccount/GetPODetails_Single";


  /* ---- STOCK DETAIL APIS ---- */

  static String submitMstrStock="Stock/SubmitMstrStock";
  static String updateMstrStock="Stock/UpdateMstrStock";
  static String deleteDetStock="Stock/DeleteDetStock";
  static String submitDetStock= "Stock/SubmitDetStock";
  static String getStockDetails= "Stock/GetStockDetails";
  static String postStock= "Stock/PostStock";
  static String deleteStock="Stock/DeleteStock";
  static String getStockDetails_Single="Stock/GetStockDetails_Single";


/* ---- REPORTS APIS ---- */

  static String getEmployeeList= "Auth/GetEmployeeList";
  static String getAttendanceReportName= "ReportDropDown/GetAttendanceReportName";
  static String getSaleAndTargetReportName= "ReportDropDown/GetSaleAndtargetReportName";
  static String loadSaleReport="Dashboard/LoadSaleReport";
  static String loadAttendanceReport="Dashboard/LoadAttendanceReport";


  /* ------------ DISTRIBUTOR APIS ------------ */


  /* ----DISTRIBUTOR DASHBOARD APIS ---- */

  //GET DASHBOARD SHOP COUNT API
  static String getDashBoardShopCount ="GetDashBoardShopCount";
  //GET TODAY SHOP VISIT API
  static String getTodayShopVisit ="GetTodayShopVisit";
  //GET WEEKLY GRAPH API
  static String getWeeklyGraph2="GetWeeklyGraph";
  //GET MONTHLY DATA API
  static String getMonthlyGraph2="GetMonthlyGraph";
  //UPDATE SHOP VISIT API
  static String updateShopVisit="UpdateShopVisit";


  /* ---- DISTRIBUTOR REPORTS APIS ---- */

  static String getSaleReportName2= "GetSaleReportName";
  static String getAttendanceReportName2= "GetAttendanceReportName";
  static String loadSaleReport2="LoadSaleReport";
  static String loadAttendanceReport2="LoadAttendanceReport";

  /* ---- SALES ORDER APIS ---- */

  //SUBMIT DET SALE API
  static String submitDetSale2= "SubmitDetSale";
  //SUBMIT MASTER SALE API
  static String submitMstrSale2="SubmitMstrSale";
  static String submitMstrSaleNew2= "SubmitMstrSaleNew";
  //DELETE MASTER SALE API
  static String deleteDetSale2= "DeleteDetSale";
  //UPDATE MASTER SALE API
  static String updateMasterSale2= "UpdateMstrSale";
  //GET CUSTOMER LIST API
  static String getProductListByCustomer2= "GetProductListByCustomer";
  //GET SALE DETAILS API
  static String getSaleDetails2="GetSaleDetails";
  //DELETE SALE LIST API
  static String deleteSale2="DeleteSale";
  //POST SALE LIST API
  static String postSale2="PostSale";
  //GET MAPPED CUSTOMER LIST API
  static String mappedCustomer="GetMapedCustomer";


  /* ---- PAYMENT RECEIVED APIS ---- */

  //SUBMIT PAYMENT RECEIVED LIST API
  static String submitPaymentReceived="SubmitPaymentReceived";
  //GET PAYMENT RECEIVED LIST API
  static String getPaymentReceived="GetPaymentReceived";
  //UPDATE PAYMENT RECEIVED LIST API
  static String updatePaymentReceived="UpdatePaymentReceived";
  //DELETE PAYMENT RECEIVED LIST API
  static String deletePaymentReceived="DeletePaymentReceived";
  //POST PAYMENT RECEIVED LIST API
  static String postPaymentReceived="PostPaymentReceived";

  //GET SALE DETAILS SINGLE API
  static String getSaleDetails_Single="GetSaleDetails_Single";
  //RESET PASSWORD API
  static String resetPassword2="ResetPassword";
  // GET SALE TARGET API
  static String getSaleTargetDetails2="GetSaleTargetDetails";
  // UPDATE USER LOCATION
  static String updateUserLocation2 ="UpdateUserLocation";
}