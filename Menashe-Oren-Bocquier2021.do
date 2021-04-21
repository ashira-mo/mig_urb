//Menashe-Oren & Bocquier (2021) "Urbanization is no longer driven by migration in low- and middle-income countries (1985-2015)", Population and Development Review//

/* set working directory cd */

** importing total population and migration estimates into stata
import excel "Population_migration_estimates.xlsx", sheet("Net_Migrants") firstrow
drop if Area!="Total" 
drop if Sex=="Male"
drop Sex Area
drop if Year==1980
replace Year=Year-2.5
sort Country Year
save Net_Migrants_CSRM_world, replace

** importing only rural/urban population estimates
import excel "Population_migration_estimates.xlsx", sheet("Net_Migrants") firstrow
drop if Area=="Total"
label define gender 1 "Female" 2 "Male"
encode Sex, generate(gender)
label define area 1 "Rural" 2 "Urban"
encode Area, generate(area)
drop Sex Area
reshape wide Total_Pop, i(Country area Year) j(gender)
gen Total_Pop=Total_Pop1 + Total_Pop2
drop Total_Pop1 Total_Pop2
bysort Country area (Year): gen Mean_Pop=(Total_Pop+Total_Pop[_n-1])/2
bysort Country area (Year): gen Total_Diff=(Total_Pop-Total_Pop[_n-1])
gen taux=100*(Total_Diff/5)/Mean_Pop //national population growth rate
drop Total_Pop
drop if Year==1980
replace Year=Year-2.5
reshape wide Mean_Pop Total_Diff taux, i(Country Year) j(area)
rename taux1 tauxrur
rename taux2 tauxurb
rename Mean_Pop1 popmoyrur
rename Mean_Pop2 popmoyurb
rename Total_Diff1 diffrur
rename Total_Diff2 diffurb
gen dG=tauxurb-tauxrur  //difference between urban and rural growth
compress

sort Country Year
drop Net_Migrants
merge 1:1 Country Year using Net_Migrants_CSRM_world.dta
drop _merge


gen date= Year
gen tauxnetrur=100*(Net_Migrants/5)/popmoyrur //rural migration rate
gen tauxneturb=100*(Net_Migrants/5)/popmoyurb //urban migration rate
gen dMRG=tauxneturb-tauxnetrur //urban-rural difference in migration & reclassification
gen dNG=dG-dMRG //urban-rural difference in natural growth

gen dGw=dG*(popmoyurb+popmoyrur) //weighted difference in growth
gen dMRGw=dMRG*(popmoyurb+popmoyrur) //weighted difference in migration
gen dNGw=dGw-dMRGw // weighted urban-rural difference in natural growth

*proportion urban
capture drop PU*
gen PU=100*popmoyurb/(popmoyurb+popmoyrur)
gen PU_2=PU^2
gen d_dMR_NG=100*(dMRG - dNG)


*identifying countries with no original data used- ie. imputed by UN based on regional divisions
gen impute=1 if (Country=="Afghanistan")  | (Country=="Algeria")  | (Country=="Angola")  | (Country=="Antigua and Barbuda")  ///
                      | (Country=="Aruba")  | (Country=="Bahamas")  | (Country=="Bahrain")  | (Country=="Barbados")  ///
                      | (Country=="Bosnia and Herzegovina")  | (Country=="Cameroon")  | (Country=="Chad")  | (Country=="Channel Islands")  ///
                      | (Country=="China")  | (Country=="Congo")  | (Country=="Democratic Republic of the Congo")  | (Country=="Denmark") ///
                      | (Country=="Djibouti")  | (Country=="Equatorial Guinea")  | (Country=="Eritrea")  | (Country=="French Guiana")  ///
                      | (Country=="French Polynesia")  | (Country=="Gabon")  | (Country=="Gambia")  | (Country=="Germany")  ///
                      | (Country=="Grenada")  | (Country=="Guadeloupe")  | (Country=="Guinea")  | (Country=="Guinea-Bissau")  ///
                      | (Country=="Guyana")  | (Country=="Haiti")  | (Country=="Italy")  | (Country=="Kuwait")  | (Country=="Lebanon")  ///
                      | (Country=="Liberia")  | (Country=="Luxembourg")  | (Country=="Macao SAR")  | (Country=="Martinique")  ///
                      | (Country=="Mauritania")  | (Country=="Mayotte")  | (Country=="Federated States of Micronesia")  | (Country=="Qatar")  ///
                      | (Country=="Réunion")  | (Country=="Saint Vincent and the Grenadines")  | (Country=="Samoa")  | (Country=="Saudi Arabia")  ///
                      | (Country=="Seychelles")  | (Country=="Sierra Leone")  | (Country=="Singapore")  | (Country=="Solomon Islands")  ///
                      | (Country=="South Sudan")  | (Country=="Sudan")  | (Country=="Democratic Republic of Timor-Leste")  | (Country=="Togo")  ///
                      | (Country=="Trinidad and Tobago")  | (Country=="Western Sahara")  | (Country=="Zimbabwe") 

*creating region variable
gen region= 0
lab def region 0 "Not specified" 1 "South America" 2 "Central America Caribbeans" 3 "North Africa West Asia" 4 "East Asia South Asia" 5 "Southeast Asia Pacific" 6 "East South Africa" 7 "West Central Africa"
lab val region region

replace region=1 if (Country=="Argentina") | (Country=="Brazil") | (Country=="Chile") |(Country=="Colombia") | (Country=="French Guiana") | ///
                        (Country=="Ecuador")   |  (Country=="Mexico") |  (Country=="Peru")  |  (Country=="Suriname") |  ///
                        (Country=="Bolivia") | (Country=="Guatemala") | (Country=="Bolivia (Plurinational State of)") | (Country=="Uruguay") | (Country=="Bolivarian Republic of Venezuela") | ///
                        (Country=="Guyana") |  (Country=="Paraguay")  

replace region=2 if (Country=="Antigua and Barbuda") | (Country=="Belize") | (Country=="Aruba") | (Country=="Cuba") | (Country=="Dominican Republic") | ///
                         (Country=="Grenada") | (Country=="Jamaica") | (Country=="Saint Lucia") | (Country=="Saint Vincent and the Grenadines") | (Country=="Costa Rica") | ///
                         (Country=="El Salvador") | (Country=="Honduras") | (Country=="Nicaragua") | (Country=="Panama") | (Country=="Guatemala") | ///
                         (Country=="Guadeloupe") |  (Country=="Haiti") | (Country=="Martinique")| (Country=="Puerto Rico")| (Country=="Trinidad and Tobago")| ///
                         (Country=="Saint Lucia") | (Country=="Bahamas") | (Country=="Barbados") | (Country=="Saint Vincent and the Grenadine")

replace region=3 if (Country=="Algeria") | (Country=="Azerbaijan") | (Country=="Egypt") | (Country=="Georgia") | ///
                             (Country=="Iran") |   (Country=="Iraq") | (Country=="Jordan")  | (Country=="Kazakhstan") | (Country=="Lebanon") | ///
                             (Country=="Morocco") | (Country=="Tunisia")  | (Country=="Turkey") | (Country=="Yemen") | (Country=="Western Sahara") | ///
                             (Country=="Armenia") | (Country=="Uzbekistan") | (Country=="Kyrgyzstan") | (Country=="Tajikistan") | ///
                             (Country=="Libya") | (Country=="Syrian Arab Republic")  | (Country=="Turkmenistan") | (Country=="State of Palestine") 


replace region=4 if (Country=="Mongolia")  |  (Country=="China") | (Country=="Afghanistan") | (Country=="Bangladesh")| ///
                          (Country=="Bhutan") | (Country=="Maldives") | (Country=="India") |  (Country=="Nepal") | (Country=="Pakistan") | (Country=="Sri Lanka")  

replace region=5 if (Country=="Brunei Daruldclam") | (Country=="Lao People's Democratic Republic") | (Country=="Malaysia") |  (Country=="Indonesia") |  ///
                             (Country=="Philippines") | (Country=="Thailand") |    (Country=="Laos") |   (Country=="Cambodia") |  ///
                             (Country=="Myanmar") |  (Country=="Timor-Leste") |  (Country=="Viet Nam") | ///
							 (Country=="Fiji")| (Country=="Federated States of Micronesia") | (Country=="Papua New Guinea") |  ///
							 (Country=="Solomon Islands") | (Country=="Tonga") | (Country=="Vanuatu") | (Country=="Kiribati") |  ///
							 (Country=="Polynesia") | (Country=="Samoa") 

replace region=6 if (Country=="Botswana")  | (Country=="Burundi") |(Country=="Comoros") | ///
                        (Country=="Djibouti") | (Country=="Eritrea") |  (Country=="Ethiopia")   | ///
                        (Country=="Kenya") |  (Country=="Lesotho") |  (Country=="Madagascar") | (Country=="Malawi") | ///
                        (Country=="Mozambique") | (Country=="Namibia")   | (Country=="Rwanda")  | (Country=="Somalia")  | ///
                        (Country=="South Africa") | (Country=="Sudan") | (Country=="Swaziland") |  ///
                        (Country=="Uganda") | (Country=="United Republic of Tanzania") | (Country=="Zambia") | (Country=="Zimbabwe")  

replace region=7 if (Country=="Angola") | (Country=="Benin") | (Country=="Burkina Faso") | ///
                        (Country=="Cabo Verde") |(Country=="Cameroon") | (Country=="Central African Republic") | (Country=="Chad") | (Country=="Congo") | ///
                        (Country=="Côte d'Ivoire") | (Country=="Democratic Republic of the Congo") | (Country=="Equatorial Guinea") | ///
                        (Country=="Gabon") | (Country=="Gambia") | (Country=="Ghana")  | (Country=="Guinea") | (Country=="Mauritania") | ///
                        (Country=="Guinea-Bissau")  | (Country=="Liberia")  | (Country=="Mali") |  (Country=="Niger") | (Country=="Sao Tome and Principe") | ///
                        (Country=="Nigeria")  |  (Country=="Senegal")  | (Country=="Sierra Leone") |(Country=="Togo") 

recode region (1=2), gen(region6)
lab def region6 0 "Not specified"  2 "Latin America & Caribbeans" 3 "North Africa & West Asia" 4 "East Asia & South Asia" 5 "Southeast Asia & Pacific" 6 "East South Africa" 7 "West Central Africa"
lab val region6 region6

						
encode Country, gen(country)
cap drop date_integer*
gen date_integer=round(date-1980.5)
gen date_integer10=date_integer/10
gen popmoytot=popmoyrur+popmoyurb
lab var dMRG "Migration component"
lab var dNG "Natural component"
compress


save URPAS_world.dta, replace

*************************************************************************************

//Generalised structural equations - seemingly unrelated regressions

use URPAS_world.dta, clear

*proportions urban (PU) by region taken from data here (bysort region6: sum PU) 

//latin america & carib
ta country if region6==2, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(   7.country -> dMRG) 	(   7.country -> dNG) ///
		(  24.country -> dMRG) 	(  24.country -> dNG) ///
		(  25.country -> dMRG) 	(  25.country -> dNG) ///
		(  28.country -> dMRG) 	(  28.country -> dNG) ///
		(  43.country -> dMRG) 	(  43.country -> dNG) ///
		(  48.country -> dMRG) 	(  48.country -> dNG) ///
		(  66.country -> dMRG) 	(  66.country -> dNG) ///
		(  78.country -> dMRG) 	(  78.country -> dNG) ///
		(  92.country -> dMRG) 	(  92.country -> dNG) ///
		( 134.country -> dMRG) 	( 134.country -> dNG) ///
		( 160.country -> dMRG) 	( 160.country -> dNG) ///
		( 161.country -> dMRG) 	( 161.country -> dNG) ///
		( 199.country -> dMRG) 	( 199.country -> dNG) ///
		( 220.country -> dMRG) 	( 220.country -> dNG) ///
		(  6.country -> dMRG) 	(  6.country -> dNG) ///
		(  9.country -> dMRG) 	(  9.country -> dNG) ///
		( 15.country -> dMRG) 	( 15.country -> dNG) ///
		( 18.country -> dMRG) 	( 18.country -> dNG) ///
		( 21.country -> dMRG) 	( 21.country -> dNG) ///
		( 51.country -> dMRG) 	( 51.country -> dNG) ///
		( 53.country -> dMRG) 	( 53.country -> dNG) ///
		( 62.country -> dMRG) 	( 62.country -> dNG) ///
		( 68.country -> dMRG) 	( 68.country -> dNG) ///
		( 86.country -> dMRG) 	( 86.country -> dNG) ///
		( 87.country -> dMRG) 	( 87.country -> dNG) ///
		( 89.country -> dMRG) 	( 89.country -> dNG) ///
		( 93.country -> dMRG) 	( 93.country -> dNG) ///
		( 94.country -> dMRG) 	( 94.country -> dNG) ///
		(104.country -> dMRG) 	(104.country -> dNG) ///
		(129.country -> dMRG) 	(129.country -> dNG) ///
		(148.country -> dMRG) 	(148.country -> dNG) ///
		(158.country -> dMRG) 	(158.country -> dNG) ///
		(166.country -> dMRG) 	(166.country -> dNG) ///
		(174.country -> dMRG) 	(174.country -> dNG) ///
		(175.country -> dMRG) 	(175.country -> dNG) ///
		(209.country -> dMRG) 	(209.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region6==2 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent
		
bys Year: tabstat PU PU_2 if region6==2
tabstat PU if region6==2 , stat(mean, sd)
di 59.89252 +  21.9521 //8.2
di 59.89252 -  21.9521 //3.8

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90") yline(0) ///
			xline(8.2, lp(dot) lcol(dknavy)) xline(3.8, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference")  
*x-axis=Year
margins ,   at(PU=54.7  PU_2=3395.45 date_integer=2) ///
			at(PU=56.89  PU_2=3677.38 date_integer=7) ///
			at(PU=58.78  PU_2=3914.26 date_integer=12) ///
			at(PU=60.41  PU_2=4119.65 date_integer=17) ///
			at(PU=61.75  PU_2=4297.08 date_integer=22) ///
			at(PU=62.82  PU_2=4453.79  date_integer=27) ///
			at(PU=63.88  PU_2=4612.06  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 




//south america
ta country if region==1, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(   7.country -> dMRG) 	(   7.country -> dNG) ///
		(  24.country -> dMRG) 	(  24.country -> dNG) ///
		(  25.country -> dMRG) 	(  25.country -> dNG) ///
		(  28.country -> dMRG) 	(  28.country -> dNG) ///
		(  43.country -> dMRG) 	(  43.country -> dNG) ///
		(  48.country -> dMRG) 	(  48.country -> dNG) ///
		(  66.country -> dMRG) 	(  66.country -> dNG) ///
		(  78.country -> dMRG) 	(  78.country -> dNG) ///
		(  92.country -> dMRG) 	(  92.country -> dNG) ///
		( 134.country -> dMRG) 	( 134.country -> dNG) ///
		( 160.country -> dMRG) 	( 160.country -> dNG) ///
		( 161.country -> dMRG) 	( 161.country -> dNG) ///
		( 199.country -> dMRG) 	( 199.country -> dNG) ///
		( 220.country -> dMRG) 	( 220.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==1
tabstat PU if region==1 , stat(mean, sd)
di 70.54047 + 16.7359 //87.3
di 70.54047 - 16.7359 //53.8

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90") yline(0) ///
			xline(8.7, lp(dot) lcol(dknavy)) xline(5.4, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins , at(PU=64.72 PU_2=4446.5 date_integer=2) ///
			at(PU=67.12 PU_2= 4760.6 date_integer=7) ///
			at(PU=69.28 PU_2=5055.6 date_integer=12) ///
			at(PU=71.2 PU_2=5323.9 date_integer=17) ///
			at(PU=72.7 PU_2=5551.2 date_integer=22) ///
			at(PU=73.9 PU_2=5735.4  date_integer=27) ///
			at(PU=74.9 PU_2=5899.1  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 

//central america carib
ta country if region==2, nol
		
gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  6.country -> dMRG) 	(  6.country -> dNG) ///
		(  9.country -> dMRG) 	(  9.country -> dNG) ///
		( 15.country -> dMRG) 	( 15.country -> dNG) ///
		( 18.country -> dMRG) 	( 18.country -> dNG) ///
		( 21.country -> dMRG) 	( 21.country -> dNG) ///
		( 51.country -> dMRG) 	( 51.country -> dNG) ///
		( 53.country -> dMRG) 	( 53.country -> dNG) ///
		( 62.country -> dMRG) 	( 62.country -> dNG) ///
		( 68.country -> dMRG) 	( 68.country -> dNG) ///
		( 86.country -> dMRG) 	( 86.country -> dNG) ///
		( 87.country -> dMRG) 	( 87.country -> dNG) ///
		( 89.country -> dMRG) 	( 89.country -> dNG) ///
		( 93.country -> dMRG) 	( 93.country -> dNG) ///
		( 94.country -> dMRG) 	( 94.country -> dNG) ///
		(104.country -> dMRG) 	(104.country -> dNG) ///
		(129.country -> dMRG) 	(129.country -> dNG) ///
		(148.country -> dMRG) 	(148.country -> dNG) ///
		(158.country -> dMRG) 	(158.country -> dNG) ///
		(166.country -> dMRG) 	(166.country -> dNG) ///
		(174.country -> dMRG) 	(174.country -> dNG) ///
		(175.country -> dMRG) 	(175.country -> dNG) ///
		(209.country -> dMRG) 	(209.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==2 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==2

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins ,   at(PU=48.3 PU_2=2726.6 date_integer=2) ///
			at(PU=50.4 PU_2=2988.1 date_integer=7) ///
			at(PU=52.1 PU_2=3187.9 date_integer=12) ///
			at(PU=53.6 PU_2=3353.3 date_integer=17) ///
			at(PU=54.8 PU_2=3499 date_integer=22) ///
			at(PU=55.8 PU_2=3638.2  date_integer=27) ///
			at(PU=56.8 PU_2=3793  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 
			
//north africa west asia
ta country if region==3, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  4.country -> dMRG) 	(  4.country -> dNG) ///
		(  8.country -> dMRG) 	(  8.country -> dNG) ///
		( 14.country -> dMRG) 	( 14.country -> dNG) ///
		( 67.country -> dMRG) 	( 67.country -> dNG) ///
		( 82.country -> dMRG) 	( 82.country -> dNG) ///
		(100.country -> dMRG) 	(100.country -> dNG) ///
		(106.country -> dMRG) 	(106.country -> dNG) ///
		(107.country -> dMRG) 	(107.country -> dNG) ///
		(111.country -> dMRG) 	(111.country -> dNG) ///
		(116.country -> dMRG) 	(116.country -> dNG) ///
		(120.country -> dMRG) 	(120.country -> dNG) ///
		(140.country -> dMRG) 	(140.country -> dNG) ///
		(197.country -> dMRG) 	(197.country -> dNG) ///
		(203.country -> dMRG) 	(203.country -> dNG) ///
		(204.country -> dMRG) 	(204.country -> dNG) ///
		(210.country -> dMRG) 	(210.country -> dNG) ///
		(211.country -> dMRG) 	(211.country -> dNG) ///
		(212.country -> dMRG) 	(212.country -> dNG) ///
		(221.country -> dMRG) 	(221.country -> dNG) ///
		(227.country -> dMRG) 	(227.country -> dNG) ///
		(229.country -> dMRG) 	(229.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==3 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent
		
bys Year: tabstat PU PU_2 if region==3
tabstat PU if region==3 , stat(mean, sd)
di 56.60728 + 16.7149 // 73
di 56.60728 - 16.7149 //40

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			xline(7.3, lp(dot) lcol(dknavy)) xline(4, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins ,   at(PU=51.8 PU_2=2884.6 date_integer=2) ///
			at(PU=53.8 PU_2=3125.8 date_integer=7) ///
			at(PU=54.9 PU_2=3268.7 date_integer=12) ///
			at(PU=55.4 PU_2=3335.5 date_integer=17) ///
			at(PU=56 PU_2=3395.3 date_integer=22) ///
			at(PU=56.9 PU_2=3493.6  date_integer=27) ///
			at(PU=57.9 PU_2=3613.9  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
			
			

// sub-saharan africa
ta country if region==6 | region==7, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  5.country -> dMRG) 	(  5.country -> dNG) ///
		( 22.country -> dMRG) 	( 22.country -> dNG) ///
		( 27.country -> dMRG) 	( 27.country -> dNG) ///
		( 31.country -> dMRG) 	( 31.country -> dNG) ///
		( 32.country -> dMRG) 	( 32.country -> dNG) ///
		( 33.country -> dMRG) 	( 33.country -> dNG) ///
		( 35.country -> dMRG) 	( 35.country -> dNG) ///
		( 38.country -> dMRG) 	( 38.country -> dNG) ///
		( 41.country -> dMRG) 	( 41.country -> dNG) ///
		( 49.country -> dMRG) 	( 49.country -> dNG) ///
		( 50.country -> dMRG) 	( 50.country -> dNG) ///
		( 59.country -> dMRG) 	( 59.country -> dNG) ///
		( 61.country -> dMRG) 	( 61.country -> dNG) ///
		( 69.country -> dMRG) 	( 69.country -> dNG) ///
		( 70.country -> dMRG) 	( 70.country -> dNG) ///
		( 72.country -> dMRG) 	( 72.country -> dNG) ///
		( 80.country -> dMRG) 	( 80.country -> dNG) ///
		( 81.country -> dMRG) 	( 81.country -> dNG) ///
		( 84.country -> dMRG) 	( 84.country -> dNG) ///
		( 90.country -> dMRG) 	( 90.country -> dNG) ///
		(108.country -> dMRG) 	(108.country -> dNG) ///
		(117.country -> dMRG) 	(117.country -> dNG) ///
		(119.country -> dMRG) 	(119.country -> dNG) ///
		(123.country -> dMRG) 	(123.country -> dNG) ///
		(124.country -> dMRG) 	(124.country -> dNG) ///
		(127.country -> dMRG) 	(127.country -> dNG) ///
		(130.country -> dMRG) 	(130.country -> dNG) ///
		(141.country -> dMRG) 	(141.country -> dNG) ///
		(143.country -> dMRG) 	(143.country -> dNG) ///
		(149.country -> dMRG) 	(149.country -> dNG) ///
		(150.country -> dMRG) 	(150.country -> dNG) ///
		(172.country -> dMRG) 	(172.country -> dNG) ///
		(177.country -> dMRG) 	(177.country -> dNG) ///
		(179.country -> dMRG) 	(179.country -> dNG) ///
		(182.country -> dMRG) 	(182.country -> dNG) ///
		(187.country -> dMRG) 	(187.country -> dNG) ///
		(188.country -> dMRG) 	(188.country -> dNG) ///
		(198.country -> dMRG) 	(198.country -> dNG) ///
		(200.country -> dMRG) 	(200.country -> dNG) ///
		(207.country -> dMRG) 	(207.country -> dNG) ///
		(213.country -> dMRG) 	(213.country -> dNG) ///
		(217.country -> dMRG) 	(217.country -> dNG) ///
		(230.country -> dMRG) 	(230.country -> dNG) ///
		(231.country -> dMRG) 	(231.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==6 |  region==7 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==6 | region==7

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins ,   at(PU=26.1 PU_2=869.6 date_integer=2) ///
			at(PU=29.2 PU_2=1064.8   date_integer=7) ///
			at(PU=31.8 PU_2=1245.4 date_integer=12) ///
			at(PU=33.7 PU_2=1382.3    date_integer=17) ///
			at(PU=35.7 PU_2=1531.3 date_integer=22) ///
			at(PU=37.7 PU_2=1695.8 date_integer=27) ///
			at(PU=39.9 PU_2=1873  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 	

			
// south-east africa
ta country if region==6 , nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		( 27.country -> dMRG) 	( 27.country -> dNG) ///
		( 32.country -> dMRG) 	( 32.country -> dNG) ///
		( 49.country -> dMRG) 	( 49.country -> dNG) ///
		( 61.country -> dMRG) 	( 61.country -> dNG) ///
		( 70.country -> dMRG) 	( 70.country -> dNG) ///
		( 72.country -> dMRG) 	( 72.country -> dNG) ///
		(108.country -> dMRG) 	(108.country -> dNG) ///
		(117.country -> dMRG) 	(117.country -> dNG) ///
		(123.country -> dMRG) 	(123.country -> dNG) ///
		(124.country -> dMRG) 	(124.country -> dNG) ///
		(141.country -> dMRG) 	(141.country -> dNG) ///
		(143.country -> dMRG) 	(143.country -> dNG) ///
		(172.country -> dMRG) 	(172.country -> dNG) ///
		(187.country -> dMRG) 	(187.country -> dNG) ///
		(188.country -> dMRG) 	(188.country -> dNG) ///
		(198.country -> dMRG) 	(198.country -> dNG) ///
		(200.country -> dMRG) 	(200.country -> dNG) ///
		(207.country -> dMRG) 	(207.country -> dNG) ///
		(213.country -> dMRG) 	(213.country -> dNG) ///
		(217.country -> dMRG) 	(217.country -> dNG) ///
		(230.country -> dMRG) 	(230.country -> dNG) ///
		(231.country -> dMRG) 	(231.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==6  ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent
		
bys Year: tabstat PU PU_2 if region==6
tabstat PU if region==6 , stat(mean, sd)
di 27.7766 + 16.41705 //44
di 27.7766 - 16.41705 //11

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90") yline(0) ///
			xline(4.4, lp(dot) lcol(dknavy)) xline(1.1, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins ,   at(PU=21.9 PU_2=722 date_integer=2) ///
			at(PU=24.3 PU_2=841.3   date_integer=7) ///
			at(PU=26.5 PU_2=961.5 date_integer=12) ///
			at(PU=28.1 PU_2=1049.8    date_integer=17) ///
			at(PU=29.6 PU_2=1132.3 date_integer=22) ///
			at(PU=31.1 PU_2=1227.3 date_integer=27) ///
			at(PU=32.9 PU_2=1340.5  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 	
			
// west-central africa
ta country if region==7, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  5.country -> dMRG) 	(  5.country -> dNG) ///
		( 22.country -> dMRG) 	( 22.country -> dNG) ///
		( 31.country -> dMRG) 	( 31.country -> dNG) ///
		( 33.country -> dMRG) 	( 33.country -> dNG) ///
		( 35.country -> dMRG) 	( 35.country -> dNG) ///
		( 38.country -> dMRG) 	( 38.country -> dNG) ///
		( 41.country -> dMRG) 	( 41.country -> dNG) ///
		( 50.country -> dMRG) 	( 50.country -> dNG) ///
		( 59.country -> dMRG) 	( 59.country -> dNG) ///
		( 69.country -> dMRG) 	( 69.country -> dNG) ///
		( 80.country -> dMRG) 	( 80.country -> dNG) ///
		( 81.country -> dMRG) 	( 81.country -> dNG) ///
		( 84.country -> dMRG) 	( 84.country -> dNG) ///
		( 90.country -> dMRG) 	( 90.country -> dNG) ///
		(119.country -> dMRG) 	(119.country -> dNG) ///
		(127.country -> dMRG) 	(127.country -> dNG) ///
		(130.country -> dMRG) 	(130.country -> dNG) ///
		(149.country -> dMRG) 	(149.country -> dNG) ///
		(150.country -> dMRG) 	(150.country -> dNG) ///
		(177.country -> dMRG) 	(177.country -> dNG) ///
		(179.country -> dMRG) 	(179.country -> dNG) ///
		(182.country -> dMRG) 	(182.country -> dNG) ///
		(207.country -> dMRG) 	(207.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==7 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent
		
bys Year: tabstat PU PU_2 if region==7
tabstat PU if region==7 , stat(mean, sd)
di  38.44058 + 14.04356 //52.5
di  38.44058 - 14.04356 //24.4


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			xline(5.3, lp(dot) lcol(dknavy)) xline(2.4, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins ,   at(PU=29.96 PU_2=1004.3 date_integer=2) ///
			at(PU=33.7 PU_2=1269   date_integer=7) ///
			at(PU=36.7 PU_2=1504.7 date_integer=12) ///
			at(PU=38.8 PU_2=1685.8    date_integer=17) ///
			at(PU=41.2 PU_2=1895.7 date_integer=22) ///
			at(PU=43.7 PU_2=2123.5 date_integer=27) ///
			at(PU=46.3 PU_2=2359.3  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 	
			
			
//East Asia South Asia
ta country if region==4, nol
	
gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  1.country -> dMRG) 	(  1.country -> dNG) ///
		( 17.country -> dMRG) 	( 17.country -> dNG) ///
		( 23.country -> dMRG) 	( 23.country -> dNG) ///
		( 44.country -> dMRG) 	( 44.country -> dNG) ///
		( 97.country -> dMRG) 	( 97.country -> dNG) ///
		(126.country -> dMRG) 	(126.country -> dNG) ///
		(137.country -> dMRG) 	(137.country -> dNG) ///
		(144.country -> dMRG) 	(144.country -> dNG) ///
		(157.country -> dMRG) 	(157.country -> dNG) ///
		(196.country -> dMRG) 	(196.country -> dNG) ///
			(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==4 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent
		
bys Year: tabstat PU PU_2 if region==4
tabstat PU if region==4 , stat(mean, sd)
*di 28.44845 + 13.68145 //42
* di 28.44845 - 13.68145  // 14.8


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			xline(4.2, lp(dot) lcol(dknavy)) xline(1.5, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 	
*x-axis=Year
margins ,   at(PU=22.1  PU_2=636.4 date_integer=2) ///
			at(PU=23.95  PU_2=723.9 date_integer=7) ///
			at(PU=25.6  PU_2=797.4 date_integer=12) ///
			at(PU=27.4  PU_2=884.8 date_integer=17) ///
			at(PU=30.1  PU_2=1052.7 date_integer=22) ///
			at(PU=33.4  PU_2=1297.3  date_integer=27) ///
			at(PU=36.6  PU_2=1564.3 date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 	
	
// "Southeast Asia Pacific"		
ta country if region==5, nol
       	
gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		( 34.country -> dMRG) 	( 34.country -> dNG) ///
		( 74.country -> dMRG) 	( 74.country -> dNG) ///
		( 75.country -> dMRG) 	( 75.country -> dNG) ///
		( 98.country -> dMRG) 	( 98.country -> dNG) ///
		(109.country -> dMRG) 	(109.country -> dNG) ///
		(112.country -> dMRG) 	(112.country -> dNG) ///
		(125.country -> dMRG) 	(125.country -> dNG) ///
		(142.country -> dMRG) 	(142.country -> dNG) ///
		(159.country -> dMRG) 	(159.country -> dNG) ///
		(162.country -> dMRG) 	(162.country -> dNG) ///
		(164.country -> dMRG) 	(164.country -> dNG) ///
		(176.country -> dMRG) 	(176.country -> dNG) ///
		(186.country -> dMRG) 	(186.country -> dNG) ///
		(205.country -> dMRG) 	(205.country -> dNG) ///
		(208.country -> dMRG) 	(208.country -> dNG) ///
		(222.country -> dMRG) 	(222.country -> dNG) ///
		(223.country -> dMRG) 	(223.country -> dNG) ///
			(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==5 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent
	

bys Year: tabstat PU PU_2 if region==5
tabstat PU if region==5 , stat(mean, sd)
*di 30.16873  +  13.378 // 43.54673
*di 30.16873  - 13.378 // 16.79073


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			xline(4.4, lp(dot) lcol(dknavy)) xline(1.7, lp(dot) lcol(dknavy)) graphregion(col(white)) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 		
		
*x-axis=Year
margins ,   at(PU=24.98  PU_2=729.3 date_integer=2) ///
			at(PU=26.7  PU_2=835.2 date_integer=7) ///
			at(PU=28.4  PU_2=947  date_integer=12) ///
			at(PU=30.1  PU_2=1069.5  date_integer=17) ///
			at(PU=31.9  PU_2=1204.7  date_integer=22) ///
			at(PU=33.7  PU_2=1339.9  date_integer=27) ///
			at(PU=35.4  PU_2=1487.8 date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 	

		
*****************************************************************************
// excluding countries with no data


//latin america & carib
ta country if region6==2, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(   7.country -> dMRG) 	(   7.country -> dNG) ///
		(  24.country -> dMRG) 	(  24.country -> dNG) ///
		(  25.country -> dMRG) 	(  25.country -> dNG) ///
		(  28.country -> dMRG) 	(  28.country -> dNG) ///
		(  43.country -> dMRG) 	(  43.country -> dNG) ///
		(  48.country -> dMRG) 	(  48.country -> dNG) ///
		(  66.country -> dMRG) 	(  66.country -> dNG) ///
		(  78.country -> dMRG) 	(  78.country -> dNG) ///
		(  92.country -> dMRG) 	(  92.country -> dNG) ///
		( 134.country -> dMRG) 	( 134.country -> dNG) ///
		( 160.country -> dMRG) 	( 160.country -> dNG) ///
		( 161.country -> dMRG) 	( 161.country -> dNG) ///
		( 199.country -> dMRG) 	( 199.country -> dNG) ///
		( 220.country -> dMRG) 	( 220.country -> dNG) ///
		(  6.country -> dMRG) 	(  6.country -> dNG) ///
		(  9.country -> dMRG) 	(  9.country -> dNG) ///
		( 15.country -> dMRG) 	( 15.country -> dNG) ///
		( 18.country -> dMRG) 	( 18.country -> dNG) ///
		( 21.country -> dMRG) 	( 21.country -> dNG) ///
		( 51.country -> dMRG) 	( 51.country -> dNG) ///
		( 53.country -> dMRG) 	( 53.country -> dNG) ///
		( 62.country -> dMRG) 	( 62.country -> dNG) ///
		( 68.country -> dMRG) 	( 68.country -> dNG) ///
		( 86.country -> dMRG) 	( 86.country -> dNG) ///
		( 87.country -> dMRG) 	( 87.country -> dNG) ///
		( 89.country -> dMRG) 	( 89.country -> dNG) ///
		( 93.country -> dMRG) 	( 93.country -> dNG) ///
		( 94.country -> dMRG) 	( 94.country -> dNG) ///
		(104.country -> dMRG) 	(104.country -> dNG) ///
		(129.country -> dMRG) 	(129.country -> dNG) ///
		(148.country -> dMRG) 	(148.country -> dNG) ///
		(158.country -> dMRG) 	(158.country -> dNG) ///
		(166.country -> dMRG) 	(166.country -> dNG) ///
		(174.country -> dMRG) 	(174.country -> dNG) ///
		(175.country -> dMRG) 	(175.country -> dNG) ///
		(209.country -> dMRG) 	(209.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region6==2 & impute!=1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region6==2 & impute!=1
tabstat PU if region6==2 & impute!=1, stat(mean, sd)
*di 64.47036 + 17.32425 // 81.79461
* di 64.47036 - 17.32425 //47.14611


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90") yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference")  
			
*xaxis=PU - one SD above and below mean
margins ,  at(PU=50 PU_2=2500) 	at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "50" 2 "60" 3 "70" 4 "80" 5 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
*x-axis=Year
margins ,   at(PU=58.02  PU_2=3625.57 date_integer=2) ///
			at(PU=60.73  PU_2=3964.96 date_integer=7) ///
			at(PU=63.02  PU_2=4251.87 date_integer=12) ///
			at(PU=65.04  PU_2=4508.69 date_integer=17) ///
			at(PU=66.76  PU_2=4740.34 date_integer=22) ///
			at(PU=68.17  PU_2=4945.32  date_integer=27) ///
			at(PU=69.56  PU_2=5146.64  date_integer=32)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 


		
//north africa west asia
ta country if region==3 & impute!=1, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  4.country -> dMRG) 	(  4.country -> dNG) ///
		(  8.country -> dMRG) 	(  8.country -> dNG) ///
		( 14.country -> dMRG) 	( 14.country -> dNG) ///
		( 67.country -> dMRG) 	( 67.country -> dNG) ///
		( 82.country -> dMRG) 	( 82.country -> dNG) ///
		(100.country -> dMRG) 	(100.country -> dNG) ///
		(106.country -> dMRG) 	(106.country -> dNG) ///
		(107.country -> dMRG) 	(107.country -> dNG) ///
		(111.country -> dMRG) 	(111.country -> dNG) ///
		(120.country -> dMRG) 	(120.country -> dNG) ///
		(140.country -> dMRG) 	(140.country -> dNG) ///
		(197.country -> dMRG) 	(197.country -> dNG) ///
		(203.country -> dMRG) 	(203.country -> dNG) ///
		(204.country -> dMRG) 	(204.country -> dNG) ///
		(210.country -> dMRG) 	(210.country -> dNG) ///
		(211.country -> dMRG) 	(211.country -> dNG) ///
		(212.country -> dMRG) 	(212.country -> dNG) ///
		(221.country -> dMRG) 	(221.country -> dNG) ///
		(227.country -> dMRG) 	(227.country -> dNG) ///
		(229.country -> dMRG) 	(229.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==3 & impute!=1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==3 & impute!=1
tabstat PU if region==3 & impute!=1, stat(mean, sd)
*di  53.54317 + 15.20041 //68.74358
*di  53.54317 - 15.20041 //38.34276

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 

*xaxis=PU- sd
margins ,  at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) 	at(PU=60 PU_2=3600) at(PU=70 PU_2=4900)   
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "40" 2 "50" 3 "60" 4 "70" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 

*x-axis=Year
margins ,   at(PU=50.45 PU_2=2722.64 date_integer=2) ///
			at(PU=52.25 PU_2=2929.9 date_integer=7) ///
			at(PU=53.21 PU_2=3052.07 date_integer=12) ///
			at(PU=53.64 PU_2=3114.47 date_integer=17) ///
			at(PU=54.23 PU_2=3185.98 date_integer=22) ///
			at(PU=55.05 PU_2=3280.71  date_integer=27) ///
			at(PU=55.96 PU_2=3386.86  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 
			
			


// south-east africa
ta country if region==6 & impute!=1, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		( 27.country -> dMRG) 	( 27.country -> dNG) ///
		( 32.country -> dMRG) 	( 32.country -> dNG) ///
		( 49.country -> dMRG) 	( 49.country -> dNG) ///
		( 61.country -> dMRG) 	( 61.country -> dNG) ///
		( 70.country -> dMRG) 	( 70.country -> dNG) ///
		( 72.country -> dMRG) 	( 72.country -> dNG) ///
		(108.country -> dMRG) 	(108.country -> dNG) ///
		(117.country -> dMRG) 	(117.country -> dNG) ///
		(123.country -> dMRG) 	(123.country -> dNG) ///
		(124.country -> dMRG) 	(124.country -> dNG) ///
		(141.country -> dMRG) 	(141.country -> dNG) ///
		(143.country -> dMRG) 	(143.country -> dNG) ///
		(172.country -> dMRG) 	(172.country -> dNG) ///
		(187.country -> dMRG) 	(187.country -> dNG) ///
		(188.country -> dMRG) 	(188.country -> dNG) ///
		(198.country -> dMRG) 	(198.country -> dNG) ///
		(200.country -> dMRG) 	(200.country -> dNG) ///
		(207.country -> dMRG) 	(207.country -> dNG) ///
		(213.country -> dMRG) 	(213.country -> dNG) ///
		(217.country -> dMRG) 	(217.country -> dNG) ///
		(230.country -> dMRG) 	(230.country -> dNG) ///
		(231.country -> dMRG) 	(231.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==6  & impute!=1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==6 & impute!=1
tabstat PU if region==6 & impute!=1, stat(mean, sd)
*di 25.23409 + 13.40473 //38.63882
*di 25.23409 - 13.40473 //11.82936

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90") yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
*x-axis=Year
margins ,   at(PU=19.16 PU_2=498.39 date_integer=2) ///
			at(PU=21.52 PU_2=605.8   date_integer=7) ///
			at(PU=23.69 PU_2=722.22 date_integer=12) ///
			at(PU=25.42 PU_2=811.55    date_integer=17) ///
			at(PU=27.02 PU_2=902.82 date_integer=22) ///
			at(PU=28.87 PU_2=1014.81 date_integer=27) ///
			at(PU=30.95 PU_2=1148.96  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
			
// west-central africa
ta country if region==7 & impute!=1, nol

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  5.country -> dMRG) 	(  5.country -> dNG) ///
		( 22.country -> dMRG) 	( 22.country -> dNG) ///
		( 31.country -> dMRG) 	( 31.country -> dNG) ///
		( 33.country -> dMRG) 	( 33.country -> dNG) ///
		( 35.country -> dMRG) 	( 35.country -> dNG) ///
		( 38.country -> dMRG) 	( 38.country -> dNG) ///
		( 41.country -> dMRG) 	( 41.country -> dNG) ///
		( 50.country -> dMRG) 	( 50.country -> dNG) ///
		( 59.country -> dMRG) 	( 59.country -> dNG) ///
		( 69.country -> dMRG) 	( 69.country -> dNG) ///
		( 80.country -> dMRG) 	( 80.country -> dNG) ///
		( 81.country -> dMRG) 	( 81.country -> dNG) ///
		( 84.country -> dMRG) 	( 84.country -> dNG) ///
		( 90.country -> dMRG) 	( 90.country -> dNG) ///
		(119.country -> dMRG) 	(119.country -> dNG) ///
		(127.country -> dMRG) 	(127.country -> dNG) ///
		(130.country -> dMRG) 	(130.country -> dNG) ///
		(149.country -> dMRG) 	(149.country -> dNG) ///
		(150.country -> dMRG) 	(150.country -> dNG) ///
		(177.country -> dMRG) 	(177.country -> dNG) ///
		(179.country -> dMRG) 	(179.country -> dNG) ///
		(182.country -> dMRG) 	(182.country -> dNG) ///
		(207.country -> dMRG) 	(207.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==7 & impute!=1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==7 & impute!=1
tabstat PU if region==7 & impute!=1, stat(mean, sd)
*di 35.23955 + 12.87978 //48.11933
* di 35.23955 - 12.87978 //22.35977


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
*xaxis=PU- sd from mean only
margins ,   at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "20" 2 "30" 3 "40" 4 "50" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
			
*x-axis=Year
margins ,   at(PU=26.48 PU_2=777.11 date_integer=2) ///
			at(PU=29.94 PU_2=986.8   date_integer=7) ///
			at(PU=32.91 PU_2=1200.5 date_integer=12) ///
			at(PU=35.29 PU_2=1383.4    date_integer=17) ///
			at(PU=37.87 PU_2=1588.79 date_integer=22) ///
			at(PU=40.66 PU_2=1823.11 date_integer=27) ///
			at(PU=43.53 PU_2=2077.67  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
			
			
//East Asia South Asia
ta country if region==4 & impute!=1, nol
	
gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  1.country -> dMRG) 	(  1.country -> dNG) ///
		( 17.country -> dMRG) 	( 17.country -> dNG) ///
		( 23.country -> dMRG) 	( 23.country -> dNG) ///
		( 44.country -> dMRG) 	( 44.country -> dNG) ///
		( 97.country -> dMRG) 	( 97.country -> dNG) ///
		(126.country -> dMRG) 	(126.country -> dNG) ///
		(137.country -> dMRG) 	(137.country -> dNG) ///
		(144.country -> dMRG) 	(144.country -> dNG) ///
		(157.country -> dMRG) 	(157.country -> dNG) ///
		(196.country -> dMRG) 	(196.country -> dNG) ///
			(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==4 & impute!=1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==4 & impute!=1
tabstat PU if region==4 & impute!=1, stat(mean, sd)
*di  28.57404 + 14.36108 //42.93512
* di  28.57404 - 14.36108 //14.21296

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 	

*xaxis=PU- sd around mean
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 	

			
*x-axis=Year
margins ,   at(PU=22.97  PU_2=706.3 date_integer=2) ///
			at(PU=24.64  PU_2=789.4 date_integer=7) ///
			at(PU=25.97  PU_2=847.25 date_integer=12) ///
			at(PU=27.51  PU_2=913.11 date_integer=17) ///
			at(PU=29.96  PU_2=1061.91 date_integer=22) ///
			at(PU=33  PU_2=1286.92  date_integer=27) ///
			at(PU=35.97  PU_2=1528.35 date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
	
// "Southeast Asia Pacific"		
ta country if region==5 & impute!=1, nol
       	
gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		( 34.country -> dMRG) 	( 34.country -> dNG) ///
		( 74.country -> dMRG) 	( 74.country -> dNG) ///
		( 75.country -> dMRG) 	( 75.country -> dNG) ///
		( 98.country -> dMRG) 	( 98.country -> dNG) ///
		(109.country -> dMRG) 	(109.country -> dNG) ///
		(112.country -> dMRG) 	(112.country -> dNG) ///
		(125.country -> dMRG) 	(125.country -> dNG) ///
		(142.country -> dMRG) 	(142.country -> dNG) ///
		(159.country -> dMRG) 	(159.country -> dNG) ///
		(162.country -> dMRG) 	(162.country -> dNG) ///
		(164.country -> dMRG) 	(164.country -> dNG) ///
		(176.country -> dMRG) 	(176.country -> dNG) ///
		(186.country -> dMRG) 	(186.country -> dNG) ///
		(205.country -> dMRG) 	(205.country -> dNG) ///
		(208.country -> dMRG) 	(208.country -> dNG) ///
		(222.country -> dMRG) 	(222.country -> dNG) ///
		(223.country -> dMRG) 	(223.country -> dNG) ///
			(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==5 & impute!=1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==5 & impute!=1
tabstat PU if region==5 & impute!=1, stat(mean, sd)
*di 32.27582 + 13.74444 //46.02026
* di 32.27582 - 13.74444 //18.53138


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 	
			
*xaxis=PU- SD around mean
margins ,   at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "20" 2 "30" 3 "40" 4 "50" ) yline(0) ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 					
		
*x-axis=Year
margins ,   at(PU=26.13  PU_2=795.38 date_integer=2) ///
			at(PU=28.17  PU_2=922.01 date_integer=7) ///
			at(PU=30.11  PU_2=1055.73  date_integer=12) ///
			at(PU=32.17  PU_2=1207.38  date_integer=17) ///
			at(PU=34.37  PU_2=1373.18  date_integer=22) ///
			at(PU=36.45  PU_2=1535.2  date_integer=27) ///
			at(PU=38.53  PU_2=1712.1 date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
				
**********************************************************************************

*** for countries where data are imputed only

	
// west-central africa

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  5.country -> dMRG) 	(  5.country -> dNG) ///
		( 22.country -> dMRG) 	( 22.country -> dNG) ///
		( 31.country -> dMRG) 	( 31.country -> dNG) ///
		( 33.country -> dMRG) 	( 33.country -> dNG) ///
		( 35.country -> dMRG) 	( 35.country -> dNG) ///
		( 38.country -> dMRG) 	( 38.country -> dNG) ///
		( 41.country -> dMRG) 	( 41.country -> dNG) ///
		( 50.country -> dMRG) 	( 50.country -> dNG) ///
		( 59.country -> dMRG) 	( 59.country -> dNG) ///
		( 69.country -> dMRG) 	( 69.country -> dNG) ///
		( 80.country -> dMRG) 	( 80.country -> dNG) ///
		( 81.country -> dMRG) 	( 81.country -> dNG) ///
		( 84.country -> dMRG) 	( 84.country -> dNG) ///
		( 90.country -> dMRG) 	( 90.country -> dNG) ///
		(119.country -> dMRG) 	(119.country -> dNG) ///
		(127.country -> dMRG) 	(127.country -> dNG) ///
		(130.country -> dMRG) 	(130.country -> dNG) ///
		(149.country -> dMRG) 	(149.country -> dNG) ///
		(150.country -> dMRG) 	(150.country -> dNG) ///
		(177.country -> dMRG) 	(177.country -> dNG) ///
		(179.country -> dMRG) 	(179.country -> dNG) ///
		(182.country -> dMRG) 	(182.country -> dNG) ///
		(207.country -> dMRG) 	(207.country -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==7 & impute==1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==7 & impute==1
tabstat PU if region==7 & impute==1, stat(mean, sd, max, min, ran)
*di 40.72703 + 14.45223  //55.2
*di 40.72703 - 14.45223  //26.3

*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			xline(5.5, lp(dot) lcol(dknavy)) xline(2.6, lp(dot) lcol(dknavy)) graphregion(col(white))  ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
*xaxis=PU - sd above/below mean
margins ,  at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) at(PU=60 PU_2=3600)   
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "30" 2 "40" 3 "50" 4 "60"  ) yline(0) ///
			graphregion(col(white))  ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
*x-axis=Year
margins ,   at(PU=31.7 PU_2=1123.9 date_integer=2) ///
			at(PU=35.7 PU_2=1426 date_integer=7) ///
			at(PU=38.9 PU_2=1680.9 date_integer=12) ///
			at(PU=41.1 PU_2=1867.8   date_integer=17) ///
			at(PU=43.5 PU_2=2087.7 date_integer=22) ///
			at(PU=45.9 PU_2=2319.5 date_integer=27) ///
			at(PU=48.3 PU_2=2552.4  date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
			
			
//East Asia South Asia
	
gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(  1.country -> dMRG) 	(  1.country -> dNG) ///
		( 17.country -> dMRG) 	( 17.country -> dNG) ///
		( 23.country -> dMRG) 	( 23.country -> dNG) ///
		( 44.country -> dMRG) 	( 44.country -> dNG) ///
		( 97.country -> dMRG) 	( 97.country -> dNG) ///
		(126.country -> dMRG) 	(126.country -> dNG) ///
		(137.country -> dMRG) 	(137.country -> dNG) ///
		(144.country -> dMRG) 	(144.country -> dNG) ///
		(157.country -> dMRG) 	(157.country -> dNG) ///
		(196.country -> dMRG) 	(196.country -> dNG) ///
			(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region==4 & impute==1 ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent

bys Year: tabstat PU PU_2 if region==4 & impute==1
tabstat PU if region==4 & impute==1, stat(mean, sd, max, min, ran)
*di  27.94613 +  10.98223 // 38.9
*di  27.94613 - 10.98223  // 17


*xaxis=PU
margins ,  at(PU=10 PU_2=100) at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900) at(PU=80 PU_2=6400) at(PU=90 PU_2=8100)  
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "10" 2 "20" 3 "30" 4 "40" 5 "50" 6 "60" 7 "70" 8 "80" 9 "90" ) yline(0) ///
			xline(3.9, lp(dot) lcol(dknavy)) xline(1.7, lp(dot) lcol(dknavy)) graphregion(col(white))  ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 	
			
*xaxis=PU - sd above/below mean
margins ,  at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600)   
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "20" 2 "30" 3 "40" ) yline(0) ///
			graphregion(col(white))  ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
*x-axis=Year
margins ,   at(PU=18.7  PU_2=356.8 date_integer=2) ///
			at(PU=21.2  PU_2= 451.7 date_integer=7) ///
			at(PU=24  PU_2=597.8 date_integer=12) ///
			at(PU=27  PU_2=771.6 date_integer=17) ///
			at(PU=30.1  PU_2=1015.8 date_integer=22) ///
			at(PU=34.9  PU_2=1339  date_integer=27) ///
			at(PU=39.1  PU_2=1708.2 date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white))  ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 		
	
		
*************************************************************************************
//all LMICs 

gsem 	(2b.date_integer -> dMRG) (2b.date_integer -> dNG) ///
		 (7.date_integer -> dMRG)  (7.date_integer -> dNG) ///
		(12.date_integer -> dMRG) (12.date_integer -> dNG) ///
		(17.date_integer -> dMRG) (17.date_integer -> dNG) ///
		(22.date_integer -> dMRG) (22.date_integer -> dNG) ///
		(27.date_integer -> dMRG) (27.date_integer -> dNG) ///
		(32.date_integer -> dMRG) (32.date_integer -> dNG) ///
		(PU -> dMRG) (PU -> dNG) (PU_2 -> dMRG) (PU_2 -> dNG) /// 
		if region!=0  ///
		[pweight = popmoytot] , ///
		cov( e.dMRG*e.dNG ) nocapslatent


*xaxis=PU- sd
margins ,   at(PU=20 PU_2=400) at(PU=30 PU_2=900) at(PU=40 PU_2=1600) at(PU=50 PU_2=2500) ///
			at(PU=60 PU_2=3600) at(PU=70 PU_2=4900)   
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) ///
			xlab(1 "20" 2 "30" 3 "40" 4 "50" 5 "60" 6 "70"  ) yline(0) ///
			graphregion(col(white))  ///
			title(" ") xtitle("Percentage Urban") ytitle("Urban-Rural Difference") 
			
*x-axis=Year
margins ,   at(PU=38  PU_2=1885.4 date_integer=2) ///
			at(PU=40.4  PU_2=2096.5 date_integer=7) ///
			at(PU=42.4  PU_2=2272.4   date_integer=12) ///
			at(PU=44  PU_2=2413.7   date_integer=17) ///
			at(PU=45.6  PU_2=2557.8   date_integer=22) ///
			at(PU=47.2  PU_2=2713.1  date_integer=27) ///
			at(PU=49  PU_2=2880.4 date_integer=32) 
marginsplot, recast(line) recastci(rarea) ciopts(fintensity(inten20)) graphregion(col(white)) ///
			xlab(1 "1985" 2 "1990" 3 "1995" 4 "2000" 5 "2005" 6 "2010" 7 "2015") yline(0) xscale(range(1 7)) yscale(range(-2 5)) ///
			title(" ") xtitle("Year") ytitle("Urban-Rural Difference") 	
			
		