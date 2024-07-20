//+------------------------------------------------------------------+
//|                                                    TestingEa.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

bool tradeThreeLineStrike = false;
bool _dailyhigh = false;
bool _dailylow = false;
int bullThreeLineMagicNum = 1230;
int bearThreeLineMagicNum = 1231;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
//TradeThreeLineStrike();
   TradeDailyHigh();
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeDailyHigh()
  {

   double EmaPeriod = 14;

   double maValue = iMA(NULL,PERIOD_CURRENT, EmaPeriod, 0,MODE_EMA, PRICE_CLOSE,0);

   DailyHigh();
   DailyLow();

   double confluence = maValue + 0.00070;
   double takeProfit = Ask + 0.0001 * 20; //maValue +
   double stopLoss = Bid - 0.0001 * 20; //maValue -

   if(_dailyhigh)
     {
      if(Bid < (maValue - 0.00070) && !CheckIfOpenOrdersByMagicNB(bearThreeLineMagicNum))
        {
         
         OrderSend(NULL, OP_SELL, 0.01, Bid, 20, takeProfit, stopLoss, NULL, bearThreeLineMagicNum);
        }
      _dailyhigh = false;
     }
   else
      if(_dailylow)
        {
         if(Ask > (maValue + 0.00070) && !CheckIfOpenOrdersByMagicNB(bullThreeLineMagicNum))
           {
            
            OrderSend(NULL, OP_BUY, 0.01, Ask, 30, stopLoss, takeProfit, NULL, bullThreeLineMagicNum);
           }
         _dailylow = false;
        }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DailyLow()
  {

   int index = iLowest(NULL,0,MODE_HIGH,287,0);

   if(index == 0)
     {

      _dailylow = true;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DailyHigh()
  {

   int index = iHighest(NULL,0,MODE_HIGH,287,0);

   if(index == 0)
     {

      _dailyhigh = true;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeThreeLineStrike()
  {

   int EmaPeriod = 200;



   double maValue = iMA(NULL,PERIOD_CURRENT, EmaPeriod, 0,MODE_EMA, PRICE_CLOSE,0);
   double confluence = maValue + 0.00070;
   double takeProfit = Ask + 0.0001 * 20; //maValue +
   double stopLoss = Bid - 0.0001 * 20; //maValue -

   if(!CheckIfOpenOrdersByMagicNB(bullThreeLineMagicNum))
     {

      if(BullThreeLineStrike(0)) //&& Ask > maValue
        {
         if(tradeThreeLineStrike)
           {
            OrderSend(NULL, OP_BUY, 0.01, Ask, 30, stopLoss, takeProfit, NULL, bullThreeLineMagicNum);
            //Alert("last error is " + GetLastError());
            tradeThreeLineStrike = false;
           }
        }

     }
   else
      if(CheckIfOpenOrdersByMagicNB(bearThreeLineMagicNum) == false)
        {

         if(BearThreeLineStrike(0))
           {
            if(tradeThreeLineStrike)
              {
               OrderSend(NULL, OP_SELL, 0.01, Bid, 20, takeProfit, stopLoss, NULL, bearThreeLineMagicNum);
               tradeThreeLineStrike = false;
              }
           }

        }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetBullCandle(int i)
  {

   double high  = High[i];
   double low   = Low[i];
   double open  = Open[i];
   double close = Close[i];

   if(close > open)
     {
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishEngulfing(int i)
  {
   double high  = High[i+1];
   double low   = Low[i+1];
   double open  = Open[i+1];
   double close = Close[i+1];

   double high1  = High[i+2];
   double low1   = Low[i+2];
   double open1  = Open[i+2];
   double close1 = Close[i+2];

   if(GetBearCandle(i+1) == true && GetBullCandle(i+2) == true)
     {
      if((open - close) >= (close1 - open1))
        {
         return true;
        }
      else
        {
         return false;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishEngulfing(int i)
  {
   double high  = High[i+1];
   double low   = Low[i+1];
   double open  = Open[i+1];
   double close = Close[i+1];

   double high1  = High[i+2];
   double low1   = Low[i+2];
   double open1  = Open[i+2];
   double close1 = Close[i+2];

   if(GetBullCandle(i+1) == true && GetBearCandle(i+2) == true)
     {
      if((close - open) >= (open1 - close1))
        {
         return true;
        }
      else
        {
         return false;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetBearCandle(int i)
  {

   double high  = High[i];
   double low   = Low[i];
   double open  = Open[i];
   double close = Close[i];

   if(open > close)
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullThreeLineStrike(int i)
  {

   string candles[5];

   for(int j = 0; j <= 4; j++)
     {

      if(GetBearCandle(i+j))
        {

         candles[j] = "Bear";
        }
      else
         if(GetBullCandle(i+j))
           {

            candles[j] = "Bull";
           }
     }

   if(candles[1] == "Bear" && candles[2] == "Bear" && candles[3] == "Bear" && candles[4] == "Bear")

     {
      if(candles[0] == "Bull")
        {
         double length = (GetLength(candles[0]) + GetLength(candles[1]) + GetLength(candles[2]) + GetLength(candles[3]) + GetLength(candles[4]))/5;

         if(BullishEngulfing(i-1)) //&& length > 0.0005
           {
            tradeThreeLineStrike = true;

            //ObjectCreate("Label_Obj_MACD" + i, OBJ_RECTANGLE, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
            //ObjectMove("Label_Obj_MACD" + i,0,Time[i],High[20]);
            return true;
           }
        }
     }


   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearThreeLineStrike(int i)
  {

   string candles[5];

   for(int j = 0; j <= 4; j++)
     {

      if(GetBearCandle(i+j))
        {
         candles[j] = "Bear";
        }
      else
         if(GetBullCandle(i+j))
           {
            candles[j] = "Bull";
           }
     }

   if(candles[1] == "Bull" && candles[2] == "Bull" && candles[3] == "Bull" && candles[4] == "Bull")

     {
      if(candles[0] == "Bear")
        {

         double length = (GetLength(candles[0]) + GetLength(candles[1]) + GetLength(candles[2]) + GetLength(candles[3]) + GetLength(candles[4]))/5;

         if(BearishEngulfing(i-1)) //i+1, i-1
           {
            tradeThreeLineStrike = true;

            //ObjectCreate("Label_Obj_MACD" + i, OBJ_RECTANGLE, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
            //ObjectMove("Label_Obj_MACD" + i,0,Time[i],High[20]);
            return true;
           }
        }
     }


   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckIfOpenOrdersByMagicNB(int magicNB)
  {
   int openOrders = OrdersTotal();

   for(int i = 0; i < openOrders; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==true)
        {
         if(OrderMagicNumber() == magicNB)
           {
            return true;
           }
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLength(int i)
  {

//double high  = High[i];
//double low   = Low[i];
   double open  = Open[i];
   double close = Close[i];

   return NormalizeDouble(MathAbs(close - open), Digits);
  }




//+------------------------------------------------------------------+
