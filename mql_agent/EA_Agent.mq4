//+------------------------------------------------------------------+
//|                                                     EA_Agent.mq4 |
//|                                         Copyright © 2018, forex. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, mmetwally, moataz960@gmail.com"
#property link      "https://github.com/moataz-metwally/mt4-ea-web-interface"
#include <mq4-http.mqh>
#include <hash.mqh>
#include <json.mqh>

extern string hostIp= "127.0.0.1";
extern int hostPort = 3000;
extern string url="/ea-check";

int glob_status=0;
int glob_all_orders=0;
int glob_all_pending_orders=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
/*
  
  put your code here..
  
  */
// start the agent timer
   EventSetTimer(1);
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------+
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  
  if(glob_status==false)
  {
  
  return(0);
  
  }

/*
  
  put your code here..
  
  */
   

   Print("Expert is running");

   return(0);
  }

MqlNet INet;
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string cookie=NULL,headers;
   char post[],result[];
   int res;

   ResetLastError();

//Create the response string
   string response="";

//Make the connection
   if(!INet.Open(hostIp,hostPort)) return(0);
   if(!INet.Request("GET",url,response,false, true, "", false))
     {
      Print("-Err download ");
      return(0);
     }
//--- Checking errors
   if(response=="")
     {
      Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      //   MessageBox("Add the address '"+google_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      //--- Load successfully
      JSONParser *parser=new JSONParser(); //Since the response is a JSON object, let's parse it
      JSONValue *jv=parser.parse(response);

      //If the object looks good
      if(jv==NULL)
        {
         Print("http errro");
           } else {

         JSONObject *jo=jv;

         int status=jo.getInt("status");
         int close_all_orders=jo.getInt("close_all_orders");
         int close_all_pending_orders=jo.getInt("close_all_pending_orders");

         Print("status:",status);
         Print("close_all_orders:",close_all_orders);
         Print("close_all_pending_orders:",close_all_pending_orders);
         
         glob_status=status;
         glob_all_orders=close_all_orders;
         glob_all_pending_orders=close_all_pending_orders;

         if(close_all_orders)
           {
            CloseAllOpenedOrders();
           }

         if(close_all_pending_orders)
           {
            CloseAllPendingOrders();
           }

        }

      delete parser;


     }

  }
// Close all opened orders
void CloseAllOpenedOrders()

  {

   int total=OrdersTotal();

   for(int i=total-1;i>=0;i--)

     {

      OrderSelect(i,SELECT_BY_POS);

      if(OrderSymbol()==Symbol())
        {

         int type=OrderType();

         bool result=false;

         RefreshRates();

         switch(type)

           {

            //Close opened long positions

            case OP_BUY       :

               while(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),1,Red)==false)
                 {

                  Sleep(100);
                  RefreshRates();
                 }

               break;

               //Close opened short positions

            case OP_SELL      :

               while(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),1,Red)==false)
                 {

                  Sleep(100);
                  RefreshRates();
                 }

           }

        }

     }

   return(0);

  }
// Close all Pending orders
void CloseAllPendingOrders()

  {

   int total=OrdersTotal();

   for(int i=total-1;i>=0;i--)

     {

      OrderSelect(i,SELECT_BY_POS);

      if(OrderSymbol()==Symbol())
        {

         int type=OrderType();

         bool result=false;

         RefreshRates();

         if(type==OP_BUYLIMIT || 
            type == OP_BUYSTOP ||
            type == OP_SELLLIMIT ||
            type==OP_SELLSTOP)
           {

            while(OrderDelete(OrderTicket())==false)
              {

                  Sleep(100);
                  RefreshRates();
              }

           }

        }

     }

   return(0);

  }
//+------------------------------------------------------------------+
