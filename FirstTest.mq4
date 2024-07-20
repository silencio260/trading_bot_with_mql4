//+------------------------------------------------------------------+
//|                                                    FirstTest.mq4 |
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
int bullThreeLineMagicNum = 1230;
int bearThreeLineMagicNum = 1231;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   Alert("start");
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---ObjectCreate(ChartID(),"Label_Obj_MACD", OBJ_ARROW, 0,Time[0],High[0],Time[0],High[0]);
   TradeThreeLineStrike();

//Alert("something");

//double maValue = iMA(NULL,PERIOD_CURRENT, 14, 0,MODE_EMA, PRICE_CLOSE,0);
// Alert(maValue);

//tradeParabolicSar();

   /*double stoploss=NormalizeDouble(Bid-20*0.0001,Digits);
   double takeprofit=NormalizeDouble(Bid+20*0.0001,Digits);
   OrderSend(Symbol(),OP_BUY,0.1,Ask,3,stoploss,takeprofit,"My order",16384,0,clrGreen);*/
  }

//+------------------------------------------------------------------+




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

   if(CheckIfOpenOrders(bullThreeLineMagicNum) == false)//CheckIfOpenOrdersByMagicNB(bullThreeLineMagicNum)
     {

      if(BullThreeLineStrike(0) && Ask > maValue)
        {
         if(tradeThreeLineStrike)
           {
            OrderSend(NULL, OP_BUY, 0.10, Ask, 30, stopLoss, takeProfit, NULL, bullThreeLineMagicNum);
            //Alert("last error is " + GetLastError());
            tradeThreeLineStrike = false;
           }
        }

     }
   else
      if(CheckIfOpenOrders(bearThreeLineMagicNum)== false) //CheckIfOpenOrdersByMagicNB(bearThreeLineMagicNum)
        {

         if(BearThreeLineStrike(0) && Bid < maValue)
           {
            if(tradeThreeLineStrike)
              {
               OrderSend(NULL, OP_SELL, 0.10, Bid, 20, takeProfit, stopLoss, NULL, bearThreeLineMagicNum);
               tradeThreeLineStrike = false;
              }
           }

        }



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void tradeParabolicSar()
  {

   int EmaPeriod = 200;

   double takeProfit = Ask + 0.0001 * 20; //maValue +
   double stopLoss = Bid - 0.0001 * 15; //maValue -
   double maValue = iMA(NULL,PERIOD_CURRENT, EmaPeriod, 0,MODE_EMA, PRICE_CLOSE,0);


   if(CheckIfOpenOrdersByMagicNB(bullThreeLineMagicNum))
     {
      if(iSAR(NULL,0,0.02,0.2,0) > Close[0] && Ask > maValue)
        {

         OrderSend(NULL, OP_BUY, 0.10, Ask, 30, stopLoss, takeProfit, NULL, bullThreeLineMagicNum);
        }
      else
         if(iSAR(NULL,0,0.02,0.2,0) < Open[0] && Bid < maValue)
           {
            OrderSend(NULL, OP_SELL, 0.10, Ask, 30, stopLoss, takeProfit, NULL, bullThreeLineMagicNum);
           }

     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckIfOpenOrders(int magicNB)
  {
   int openOrders = OrdersTotal();


   if(openOrders > 0)
     {

      return true;
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
bool GetDoji(int i = 1)
  {
   double high  = High[i];
   double low   = Low[i];
   double open  = Open[i];
   double close = Close[i];

   double length = close - open;

   if(MathAbs(length) < 0.00005) //*****0.00005 or 0.00009 or  for lower timframes like 5mins
     {

      //ObjectCreate("Label_Obj_MACD" + i, OBJ_ARROW_DOWN, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
      //ObjectMove("Label_Obj_MACD" + i,0,Time[i],High[20]);
      return true;
     }



   return false;
  }//--------***** bodiless candles || tiny body candle

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BearishTweezerPattern(int i = 54)
  {
   double high  = High[i+1];
   double low   = Low[i+1];

   double high1  = High[i+2];
   double low1   = Low[i+2];

   double distance = MathAbs(high - high1);

   if(distance < 0.0001)//---------<= 0.0001
     {

      //ObjectCreate("Label_Obj_MACD" + i, OBJ_ARROW_DOWN, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
      //ObjectMove("Label_Obj_MACD" + i,0,Time[i+1],High[20]);
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullishTweezerPattern(int i = 21)
  {
   double high  = High[i+1];
   double low   = Low[i+1];

   double high1  = High[i+2];
   double low1   = Low[i+2];

   double distance = MathAbs(low - low1);

   if(distance <= 0.0001)
     {

      //ObjectCreate("Label_Obj_MACD" + i, OBJ_ARROW_DOWN, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
      //ObjectMove("Label_Obj_MACD" + i,0,Time[i+1],High[20]);
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Hammer(int i = 151)//84  // also check if entire candle size is greater than 15 pips as confluence
  {

   double high  = High[i];
   double low   = Low[i];
   double open  = Open[i];
   double close = Close[i];


   double body = MathAbs(close - open);
   double tail = MathAbs(low - open);
   double invertedTail = (low - close);


//********* Divide by 1.5 for candle longer than 20pips *****mostly in hr  *******undicided
   bool isHammer = NormalizeDouble(tail/2, Digits) >= NormalizeDouble(body, Digits);
   bool isInverted = NormalizeDouble(invertedTail/2, Digits) >= NormalizeDouble(body, Digits);

//Alert("Hammer Tester");
//Alert(tail/3);
//Alert(body);

   if(isHammer || isInverted)
     {

      //ObjectCreate("Label_Obj_MACD" + i, OBJ_ARROW, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
      //ObjectMove("Label_Obj_MACD" + i,0,Time[i],High[20]);
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShootingStar(int i = 76)//152
  {

   double high  = High[i];
   double low   = Low[i];
   double open  = Open[i];
   double close = Close[i];


   double body = MathAbs(close - open);
   double tail = (high - close);
   double invertedTail = (high - open);

   bool isShootingStar = NormalizeDouble(tail/2, Digits) >= NormalizeDouble(body, Digits);
   bool isInverted = NormalizeDouble(invertedTail/2, Digits) >= NormalizeDouble(body, Digits);

//Alert("Hammer Tester");
//Alert(tail/3);
//Alert(body);

   if(isShootingStar || isInverted)
     {

      //ObjectCreate("Label_Obj_MACD" + i, OBJ_ARROW_DOWN, 0,TimeCurrent(),High[i],TimeCurrent(),High[i]);
      //ObjectMove("Label_Obj_MACD" + i,0,Time[i],High[20]);
      return true;
     }

   return false;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BullThreeLineStrike(int i)
  {

   string candles[4];

   for(int j = 0; j <= 3; j++)
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

   if(candles[1] == "Bear" && candles[2] == "Bear" && candles[3] == "Bear")

     {
      if(candles[0] == "Bull")
        {

         if(BullishEngulfing(i-1))
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

   string candles[4];

   for(int j = 0; j <= 3; j++)
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

   if(candles[1] == "Bull" && candles[2] == "Bull" && candles[3] == "Bull")

     {
      if(candles[0] == "Bear")
        {

         if(BearishEngulfing(i-1))
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
