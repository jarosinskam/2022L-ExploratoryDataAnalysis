library(dplyr)

df <- read.csv("E:/RStudio/eskplo/house_data.csv")
str(df)



# 1. Jaka jest �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia?

mediana = median(df$grade)

df %>%
  select(grade, waterfront, price) %>%
  filter(grade >= mediana) %>%
  filter(waterfront == 1) %>%
  summarise(mean(price))

# Odp: 1784152




# 2. Czy nieruchomo�ci o 2 pi�trach maj� wi�ksz� (w oparciu o warto�ci mediany) liczb� �azienek ni� nieruchomo�ci o 3 pi�trach?

df %>%
  select(bathrooms, floors) %>%
  filter(floors == 2 | floors == 3) %>%
  group_by(floors) %>%
  summarise(median(bathrooms)) 

# Odp: Nie (o dziwo obie te mediany wysz�y akurat 2.5).




# 3. O ile procent wi�cej jest nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d?

# Tu przyda si� komentarz definiuj�cy, co to znaczy "po�udniowy wsch�d" i 
# "p�nocny zach�d":
# Przyjrza�em si� warto�ciom szeroko�ci i d�ugo�ci geograficznej z ramki i 
# z zasi�gu przyjmowanego przez te warto�ci (kt�ry dosta�em po prostu klikaj�c
# by RStudio posortowa�o mi je rosn�co/malej�co), przy u�yciu konwertera 
# wsp�rz�dnych geograficznych do lokacji, ustali�em, �e dane dotycz�
# nieruchomo�ci w okolicach Seattle-USA.
# W zwi�zku z tym, naturaln� definicj� "le�enia na p�nocny zach�d" jest le�enie
# na p�nocny zach�d wzgl�dem centrum miasta. Analogicznie zdefiniowa�em le�enie
# na po�udniowy wsch�d.
# Z tego samego konwertera odczyta�em wsp�rz�dne geograficzne centrum miasta i
# po zaokr�gleniu (nie wp�ywaj�cym na ostateczne wyniki, bo dane z ramki s�
# zaokr�glone jeszcze bardziej grubo) dosta�em warto�ci:

lat_center = 47.62184 
long_center = -122.3509

# Jako, �e zadanie bez tej definicji jest nie�cis�e, prosz� uprzejmie o nie
# ucinanie punkt�w, je�li moja interpretacja polecenia rozmija si� z wizj�
# uk�adaj�cego zadanie.

df %>%
  select(lat,long) %>%
  mutate("direction" = (lat>lat_center) + 2*(long>long_center)) %>%
  group_by(direction) %>%
  summarise(n()) -> dir_info

# Ramka dir_info zawiera teraz informacje o liczbie nieruchomo�ci w konkretnych
# �wiartkach uk�adu wsp�rz�dnych, zakodowane w nast�puj�cy spos�b:
# 0 <- SW (Bo lat<=lat_center = S i long<=long_center = W)
# 1 <- NW (Bo lat>lat_center = N i long<=long_center = W)
# 2 <- SE (Bo lat<=lat_center = S i long>long_center = E)
# 3 <- NE (Bo lat>lat_center = N i long>long_center = E)

# Odpowied� na pytanie mo�na wi�c wyczyta� z tabelki:
result = (dir_info[[2,2]]/dir_info[[3,2]] - 1)*100

# Odp: Wcale nie jest wi�cej, jest mniej i to o ok 82.5%.




# 4. Jak zmienia�a si� (mediana) liczba �azienek dla nieruchomo�ci wybudownych w latach 90 XX wieku wzgl�dem nieruchmo�ci wybudowanych roku 2000?

df %>%
  select(yr_built, bathrooms) %>%
  filter(yr_built >= 1990 & yr_built <= 2000) %>%
  group_by(yr_built) %>%
  summarise(median(bathrooms))

# Odp: Nie zmienia�a si� (i ca�y czas by�a r�wna 2.5, te dane s� jakie� dziwne).




# 5. Jak wygl�da warto�� kwartyla 0.25 oraz 0.75 jako�ci wyko�czenia nieruchomo�ci po�o�onych na p�nocy bior�c pod uwag� czy ma ona widok na wod� czy nie ma?

# Definicja "po�o�enia na p�nocy" analogicznie do zadania nr.3.
?quantile()

df %>%
  select(grade, waterfront, lat) %>%
  filter(lat > lat_center) %>%
  group_by(waterfront) %>%
  summarise(quantile(grade, prob = c(0.25,0.75)))

# Poniewa� kwartyl 0.75 na pewno jest wi�kszy ni� kwartyl 0.25, �atwo odczyta�
# odpowied� z powy�szej tabelki.

# Odp: Dla nieruchomo�ci bez widoku na wod�, wynios�y one odpowiednio 7 i 8, podczas gdy dla nieruchomo�ci po�o�onych nad wod� by�y one wy�sze i wynios�y odpowiednio 8 i 11.




# 6. Pod kt�rym kodem pocztowy jest po�o�onych najwi�cej nieruchomo�ci i jaki jest rozst�p miedzykwartylowy dla ceny nieruchomo�ci po�o�onych pod tym adresem?

df %>%
  select(zipcode, price) %>%
  group_by(zipcode) %>%
  mutate("n" = n()) %>%
  arrange(-n) %>%     # Na tym etapie wiem ju� jaki kod wyst�pi� najwi�cej razy.
  filter(zipcode == 98103) %>%
  summarise(quantile(price, prob = 0.75) - quantile(price, prob = 0.25))
  
# Odp: Tym kodem jest 98103, a rozst�p mi�dzykwartylowy ich cen to 262875 (zapewne dolar�w).




# 7. Ile procent nieruchomo�ci ma wy�sz� �redni� powierzchni� 15 najbli�szych s�siad�w wzgl�dem swojej powierzchni?

df %>%
  select(sqft_living, sqft_living15) %>%
  filter(sqft_living15 > sqft_living) %>%
  summarise(n())

# T� w�asno�� posiada 9206 nieruchomo�ci, a wszystkich nieruchomo�ci jest 21613,
# st�d szukana odpowied� to:

percentage7 = (9206/21613)*100

# Odp: oko�o 42.6%




# 8. Jak� liczb� pokoi maj� nieruchomo�ci, kt�rych cena jest wi�ksza ni� trzeci kwartyl oraz mia�y remont w ostatnich 10 latach (pamietaj�c �e nie wiemy kiedy by�y zbierane dne) oraz zosta�y zbudowane po 1970?

# Zgodnie z wytycznymi otrzymanymi na teamsie - 2015 (rok na kt�rym si� urywaj�
# dane) jest dobrym rokiem odniesienia, interesuj� nas tylko remonty, �wie�e
# budowy nie maj� znaczenia, �azienki si� nie licz�, a wynikiem powinna by�
# tabelka: liczba pokoi - liczba nieruchomo�ci spe�niaj�cych kryteria.

prog_cenowy = quantile(df$price, prob = 0.75)

df %>%
  select(bedrooms, bathrooms, price, yr_built, yr_renovated) %>%
  filter(price > prog_cenowy) %>%
  filter(yr_renovated > 2005) %>%
  filter(yr_built > 1970) %>%
  group_by(bedrooms) %>%
  summarise(n())

# Odp: W�r�d nieruchomo�ci spe�niaj�cych kryteria jest 7 3-pokojowych, 9 4-pokojowych i 5 5-pokojowych.




# 9. Patrz�c na definicj� warto�ci odstaj�cych wed�ug Tukeya (wykres boxplot) wska� ile jest warto�ci odstaj�cych wzgl�dem powierzchni nieruchomo�ci(dolna i g�rna granica warto�ci odstajacej).

q1 = quantile(df$sqft_living, prob = 0.25)
q3 = quantile(df$sqft_living, prob = 0.75)
iqr = q3-q1
dolna_gr = q1 - 1.5*iqr
gorna_gr = q3 + 1.5*iqr
# Jak wida�, dolna granica nie ma sensu, bo raczej nie ma co oczekiwa� 
# nieruchomo�ci o ujemnej powierzchni, dlatego nale�y jedynie zobaczy�, ile
# wynik�w przekracza granic� g�rn�.

df %>%
  select(sqft_living) %>%
  filter(sqft_living > gorna_gr) %>%
  summarise(n())

# Odp: Warto�ci odstaj�ce to te nieruchomo�ci, kt�rych powierzchnia przekracza 4234 ft^2. Takich nieruchomo�ci jest 572.




# 10. W�r�d nieruchomo�ci wska� jaka jest najwi�ksz� cena za metr kwadratowy bior�c pod uwag� tylko powierzchni� mieszkaln�.

# 1m^2 ~ 10.764 ft^2

df %>%
  select(sqft_living, price) %>%
  mutate("cena_za_metrkw" = price/(sqft_living/10.764)) %>%
  arrange(-cena_za_metrkw) %>%
  head(1)

# Odp: Najdro�sza nieruchomo�� w przeliczeniu na koszt m^2 kosztowa�a ok. 8720 dolar�w za metr kw..