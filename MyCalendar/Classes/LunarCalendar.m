//
//  LunarCalendar.m
//  MyCalendar
//
//  Created by app on 2010/4/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//  
//

/*
 ***************************************
 農曆月曆&世界時間 DHTML 程式 (台灣版)
 ***************************************
 最後修改: 2007 年 3 月 6 日
 
 
 如果您覺得這個程式不錯，您可以自由轉寄給親朋好友分享。自由使
 用範圍: 學校、學會、公會、公司內部、程式研究、個人網站供人查
 詢使用。
 
 Open Source 不代表放棄著作權，任何形式之引用或轉載前請來信告
 知。如需於「商業或營利」目的中使用此部份之程式碼或資料，需取
 得本人書面授權。
 
 最新版本與更新資訊於 http://sean.o4u.com/ap/calendar/ 公佈
 
 
 　                            歡迎來信互相討論研究與指正誤謬
 連絡方式：http://sean.o4u.com/contact/
 　　　　　　　　　　Sean Lin (林洵賢)
 尊重他人創作‧請勿刪除或變更此說明
 */

/*
 Usage:
 1. get lunar calendar for a specific solar date: [LunarCalendar lunarAtDate:(NSDate *)date]
 2. get info for the lunar date
 get number
 + (int) getLunarYear;
 + (int) getLunarMonth;
 + (int) getLunarDay;
 get chinese number
 + (NSString *) getLunarDayChinese;
 + (NSString *) getLunarMonthChinese;
 get Festival
 + (NSString *) getLunarFestival;
  get 節氣
 + (NSString *) getSolarTerms;
 */



#import "LunarCalendar.h"


static 	int lunarInfo[201] = {
0x4bd8,0x4ae0,0xa570,0x54d5,0xd260,0xd950,0x5554,0x56af,0x9ad0,0x55d2,
0x4ae0,0xa5b6,0xa4d0,0xd250,0xd295,0xb54f,0xd6a0,0xada2,0x95b0,0x4977,
0x497f,0xa4b0,0xb4b5,0x6a50,0x6d40,0xab54,0x2b6f,0x9570,0x52f2,0x4970,
0x6566,0xd4a0,0xea50,0x6a95,0x5adf,0x2b60,0x86e3,0x92ef,0xc8d7,0xc95f,
0xd4a0,0xd8a6,0xb55f,0x56a0,0xa5b4,0x25df,0x92d0,0xd2b2,0xa950,0xb557,
0x6ca0,0xb550,0x5355,0x4daf,0xa5b0,0x4573,0x52bf,0xa9a8,0xe950,0x6aa0,
0xaea6,0xab50,0x4b60,0xaae4,0xa570,0x5260,0xf263,0xd950,0x5b57,0x56a0,
0x96d0,0x4dd5,0x4ad0,0xa4d0,0xd4d4,0xd250,0xd558,0xb540,0xb6a0,0x95a6,
0x95bf,0x49b0,0xa974,0xa4b0,0xb27a,0x6a50,0x6d40,0xaf46,0xab60,0x9570,
0x4af5,0x4970,0x64b0,0x74a3,0xea50,0x6b58,0x5ac0,0xab60,0x96d5,0x92e0,
0xc960,0xd954,0xd4a0,0xda50,0x7552,0x56a0,0xabb7,0x25d0,0x92d0,0xcab5,
0xa950,0xb4a0,0xbaa4,0xad50,0x55d9,0x4ba0,0xa5b0,0x5176,0x52bf,0xa930,
0x7954,0x6aa0,0xad50,0x5b52,0x4b60,0xa6e6,0xa4e0,0xd260,0xea65,0xd530,
0x5aa0,0x76a3,0x96d0,0x4afb,0x4ad0,0xa4d0,0xd0b6,0xd25f,0xd520,0xdd45,
0xb5a0,0x56d0,0x55b2,0x49b0,0xa577,0xa4b0,0xaa50,0xb255,0x6d2f,0xada0,
0x4b63,0x937f,0x49f8,0x4970,0x64b0,0x68a6,0xea5f,0x6b20,0xa6c4,0xaaef,
0x92e0,0xd2e3,0xc960,0xd557,0xd4a0,0xda50,0x5d55,0x56a0,0xa6d0,0x55d4,
0x52d0,0xa9b8,0xa950,0xb4a0,0xb6a6,0xad50,0x55a0,0xaba4,0xa5b0,0x52b0,
0xb273,0x6930,0x7337,0x6aa0,0xad50,0x4b55,0x4b6f,0xa570,0x54e4,0xd260,
0xe968,0xd520,0xdaa0,0x6aa6,0x56df,0x4ae0,0xa9d4,0xa4d0,0xd150,0xf252,
0xd520
};


//===== 某年的第n個節氣為幾日(從0小寒起算)
static int solarTermBase[24] = {4,19,3,18,4,19,4,19,4,20,4,20,6,22,6,22,6,22,7,22,6,21,6,21};
NSString *solarTermIdx = @"0123415341536789:;<9:=<>:=1>?012@015@015@015AB78CDE8CD=1FD01GH01GH01IH01IJ0KLMN;LMBEOPDQRST0RUH0RVH0RWH0RWM0XYMNZ[MB\\]PT^_ST`_WH`_WH`_WM`_WM`aYMbc[Mde]Sfe]gfh_gih_Wih_WjhaWjka[jkl[jmn]ope]qph_qrh_sth_W";
NSString *solarTermOS = @"211122112122112121222211221122122222212222222221222122222232222222222222222233223232223232222222322222112122112121222211222122222222222222222222322222112122112121222111211122122222212221222221221122122222222222222222222223222232222232222222222222112122112121122111211122122122212221222221221122122222222222222221211122112122212221222211222122222232222232222222222222112122112121111111222222112121112121111111222222111121112121111111211122112122112121122111222212111121111121111111111122112122112121122111211122112122212221222221222211111121111121111111222111111121111111111111111122112121112121111111222111111111111111111111111122111121112121111111221122122222212221222221222111011111111111111111111122111121111121111111211122112122112121122211221111011111101111111111111112111121111121111111211122112122112221222211221111011111101111111110111111111121111111111111111122112121112121122111111011111121111111111111111011111111112111111111111011111111111111111111221111011111101110111110111011011111111111111111221111011011101110111110111011011111101111111111211111001011101110111110110011011111101111111111211111001011001010111110110011011111101111111110211111001011001010111100110011011011101110111110211111001011001010011100110011001011101110111110211111001010001010011000100011001011001010111110111111001010001010011000111111111111111111111111100011001011001010111100111111001010001010000000111111000010000010000000100011001011001010011100110011001011001110111110100011001010001010011000110011001011001010111110111100000010000000000000000011001010001010011000111100000000000000000000000011001010001010000000111000000000000000000000000011001010000010000000";

//國曆
static int sYear;		//西元年4位數字
static int sMonth;		//西元月數字
static int sDay;		//西元日數字


static int lYear;		//西元年4位數字
static int lMonth;		//農曆月數字
static int lDay;		//農曆日數字
static BOOL isLeap;	//是否為農曆閏月?



@implementation LunarCalendar



+ (void) test{
	[LunarCalendar lunarAtDate:[NSDate date]];
	DoLog(DEBUG,@"DDD:::%d,%d,%d", lYear,lMonth,lDay);
	
	NSString *a = [LunarCalendar getSolarTerms];
	DoLog(DEBUG,@"節氣:::%@",a);
	a = [LunarCalendar getLunarMonthChinese];
	DoLog(DEBUG,@"getLunarMonthChinese:::%@",a);
	a = [LunarCalendar getLunarDayChinese];
	DoLog(DEBUG,@"getLunarDayChinese:::%@",a);
	a = [LunarCalendar getLunarFestival];
	DoLog(DEBUG,@"getLunarFestival:::%@",a);
	
}

/*****************************************************************************
 日期計算
 *****************************************************************************/

//====================================== 傳回農曆 y年的總天數
+(int) lYearDays:(int)y {
	int i, sum = 348;
	for(i=0x8000; i>0x8; i>>=1)
		sum += (lunarInfo[y-1900] & i)? 1: 0;
	return(sum + [self leapDays:y]);
}

//====================================== 傳回農曆 y年閏月的天數
+(int) leapDays:(int)y {
	if([self leapMonth:y]) 
		return( (lunarInfo[y-1899]&0xf)==0xf? 30: 29);
	else 
		return(0);
}

//====================================== 傳回農曆 y年閏哪個月 1-12 , 沒閏傳回 0
+(int) leapMonth:(int)y {
	int lm = lunarInfo[y-1900] & 0xf;
	return(lm==0xf?0:lm);
}

//====================================== 傳回農曆 y年m月的總天數
+(int) monthDays:(int)y m:(int)m {
	return( (lunarInfo[y-1900] & (0x10000>>m))? 30: 29 );
}


//====================================== 算出農曆, 傳入日期物件, 傳回農曆日期物件
//                                       該物件屬性有 .year .month .day .isLeap
+(int) lunarAtDate:(NSDate *)date{
	
	int i, leap=0, temp=0;
	
	NSDate *inputDate;
	NSDate *originDate;
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *cmp = [[[NSDateComponents alloc] init] autorelease];
	[comps setYear:1900];
	[comps setMonth:1];
	[comps setDay:31];
	originDate = [cal dateFromComponents:comps];
	cmp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
	[comps setYear:cmp.year];
	sYear = cmp.year;
	if(sYear < 1900 || sYear > 2100){//1900-2100
		lYear=0;
		lMonth=0;
		lDay=0;
		return 1;
	}
	[comps setMonth:cmp.month];
	sMonth = cmp.month;
	[comps setDay:cmp.day];
	sDay = cmp.day;
	inputDate = [cal dateFromComponents:comps];
	
	int offset = ([inputDate timeIntervalSinceReferenceDate] - [originDate timeIntervalSinceReferenceDate])/86400;
	DoLog(DEBUG,@"YYY:::%f,%f,%d",[inputDate timeIntervalSinceReferenceDate] ,[originDate timeIntervalSinceReferenceDate],offset);
	
	for(i=1900; i<2100 && offset>0; i++) {
		temp=[LunarCalendar lYearDays:i]; 
		offset-=temp; 
	}
	
	if(offset<0) {
		offset+=temp;
		i--; 
	}
	
	lYear = i;
	
	leap = [LunarCalendar leapMonth:i]; //閏哪個月
	isLeap = NO;
	
	for(i=1; i<13 && offset>0; i++) {
		//閏月
		if(leap>0 && i==(leap+1) && isLeap==NO){
			--i;
			isLeap = YES;
			temp = [LunarCalendar leapDays:lYear];
		}
		else{
			temp = [LunarCalendar monthDays:lYear m:i]; 
		}
		
		//解除閏月
		if(isLeap==YES && i==(leap+1)) 
			isLeap = NO;
		offset -= temp;
	}
	
	if(offset==0 && leap>0 && i==leap+1){
		if(isLeap){
			isLeap = NO; 
		}else{
			isLeap = YES; 
			--i; 
		}
	}
	if(offset<0){
		offset += temp; --i; 
	}
	
	lMonth = i;
	lDay = offset + 1;
	return 0;

}
+ (NSArray*) solarTerm{
	static NSArray* solarTerm = nil;
    if (solarTerm == nil) {
        solarTerm = [[NSArray alloc] initWithObjects:@"小寒",@"大寒",@"立春",@"雨水",@"驚蟄",@"春分",@"清明",@"穀雨",@"立夏",@"小滿",@"芒種",@"夏至",@"小暑",@"大暑",@"立秋",@"處暑",@"白露",@"秋分",@"寒露",@"霜降",@"立冬",@"小雪",@"大雪",@"冬至",nil];
    }
    return solarTerm;
}

+ (NSArray*) nStr1{
	static NSArray* nStr1 = nil;
    if (nStr1 == nil) {
        nStr1 = [[NSArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二",nil];
    }
    return nStr1;
}

+ (NSArray*) nStr2{
	static NSArray* nStr2 = nil;
    if (nStr2 == nil) {
		nStr2 = [[NSArray alloc] initWithObjects:@"初",@"十",@"廿",@"卅",@"卌",nil];
	}
    return nStr2;
}


+ (NSDictionary*) lFtv{
	static NSDictionary* lFtv = nil;
    if (lFtv == nil) {
		lFtv = [[NSDictionary alloc] initWithObjectsAndKeys:
				@"春節",@"0101",
				@"回娘家",@"0102",
				@"祭祖",@"0103",
				@"迎神",@"0104",
				@"開市",@"0105",
				@"天公生",@"0109",
				@"元宵節",@"0115",
				@"土地公生",@"0202",
				@"媽祖生",@"0323",
				@"浴佛節",@"0408",
				@"端午節",@"0505",
				@"開鬼門",@"0701",
				@"七夕",@"0707",
				@"中元節",@"0715",
				@"關鬼門",@"0800",
				@"中秋節",@"0815",
				@"重陽節",@"0909",
				@"臘八節",@"1208",
				@"尾牙",@"1216",
				@"送神",@"1224",
				@"除夕",@"0100",
				nil
		];
	}
    return lFtv;
}

+ (int) getLunarYear{
	return lYear;
}
+ (int) getLunarMonth{
	return lMonth;
}
+ (int) getLunarDay{
	return lDay;
}
+ (NSString *) getSolarTerms{
	if(sYear < 1900 || sYear > 2100){//1900-2100
		return @"";
	}
	int tmp1= [LunarCalendar sTerm:sYear n:(sMonth-1)*2];
	int tmp2= [LunarCalendar sTerm:sYear n:(sMonth-1)*2+1];
	//DoLog(DEBUG,@"tmp1:::%d",tmp1);
	//DoLog(DEBUG,@"tmp2:::%d",tmp2);
	//DoLog(DEBUG,@"solarTerm1:::%@",[[LunarCalendar solarTerm] objectAtIndex:((sMonth-1)*2)]);
	//DoLog(DEBUG,@"solarTerm2:::%@",[[LunarCalendar solarTerm] objectAtIndex:((sMonth-1)*2+1)]);
	if(sDay == tmp1){
		return [[LunarCalendar solarTerm] objectAtIndex:((sMonth-1)*2)];
	}else if(sDay == tmp2){
		return [[LunarCalendar solarTerm] objectAtIndex:((sMonth-1)*2+1)];
	}	
	return @"";
}


+ (int) sTerm:(int)y n:(int)n {
	
	
	NSString *charCode=[NSString stringWithFormat:@"%i",[solarTermIdx characterAtIndex:(y-1900)]];
	NSString *character=[NSString stringWithFormat:@"%c",[solarTermOS characterAtIndex:( ( floor([charCode intValue]) - 48) * 24 + n  )]];
	//DoLog(DEBUG,@"charCode:::%d,%f",[charCode intValue],( ( floor([solarTermIdx characterAtIndex:(y-1900)]) - 48) * 24 + n  ));
	//DoLog(DEBUG,@"charCode:::%d,%d",[charCode intValue],[intString intValue]);
	//return(solarTermBase[n] +  Math.floor( solarTermOS.charAt( ( Math.floor(solarTermIdx.charCodeAt(y-1900)) - 48) * 24 + n  ) ) );
	return(solarTermBase[n] +  floor( [character intValue] ) );
	
}

+ (NSString *) getLunarMonthChinese{
	if(sYear < 1900 || sYear > 2100){//1900-2100
		return @"";
	}
	NSString *tmp = [NSString stringWithFormat:@"%@月",[[LunarCalendar nStr1]objectAtIndex:lMonth]];
	return tmp;
}
+ (NSString *) getLunarDayChinese{
	if(sYear < 1900 || sYear > 2100){//1900-2100
		return @"";
	}
	NSString *s=@"";
	
	switch (lDay) {
		case 10:
			s = @"初十"; break;
		case 20:
			s = @"二十"; break;
			break;
		case 30:
			s = @"三十"; break;
			break;
		default :
			s = [NSString stringWithFormat:@"%@%@",[[LunarCalendar nStr2]objectAtIndex:floor(lDay/10)],[[LunarCalendar nStr1]objectAtIndex:(lDay%10)]];
	}
	return s;
}
+ (NSString *) getLunarFestival{
	if(sYear < 1900 || sYear > 2100){//1900-2100
		return @"";
	}
	if(isLeap == NO){
		NSString *key= [NSString stringWithFormat:@"%02d%02d",lMonth,lDay];
		if([LunarCalendar monthDays:lYear m:lMonth] == lDay){//如果是每月的最後一天 
			if(lMonth == 12){//跳到1
				key= [NSString stringWithFormat:@"%02d%02d",1,0];
			}else{
				key= [NSString stringWithFormat:@"%02d%02d",lMonth+1,0];
			}
		}
		if([[LunarCalendar lFtv] objectForKey:key]!=nil){
			return [[LunarCalendar lFtv] objectForKey:key];
		}
		
	}
	return @"";
}

@end
