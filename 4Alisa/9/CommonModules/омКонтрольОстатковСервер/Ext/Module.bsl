﻿&НаСервере
Функция ВернутьЗапросРежим1()
	Возврат "ВЫБРАТЬ
	        |	тзТовары.Товар
	        |ПОМЕСТИТЬ ВТ_ТЧ
	        |ИЗ
	        |	&тзТовары КАК тзТовары
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	ОстаткиТоваровОстатки.Товар КАК Товар,
	        |	ОстаткиТоваровОстатки.КоличествоОстаток КАК Остаток
	        |ПОМЕСТИТЬ ВТ_ОСТАТКИ
	        |ИЗ
	        |	РегистрНакопления.ОстаткиТоваров.Остатки(
	        |			,
	        |			Товар В
	        |				(ВЫБРАТЬ
	        |					Товары.Товар КАК Товар
	        |				ИЗ
	        |					ВТ_ТЧ КАК Товары)) КАК ОстаткиТоваровОстатки
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	ТЧ.Товар КАК Товар,
	        |	ЕСТЬNULL(ОСТ.Остаток, 0) КАК Остаток,
	        |	0 КАК Резерв,
	        |	ЕСТЬNULL(ОСТ.Остаток, 0) КАК СвободныйОстаток
	        |ИЗ
	        |	ВТ_ТЧ КАК ТЧ
	        |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОСТАТКИ КАК ОСТ
	        |		ПО (ОСТ.Товар = ТЧ.Товар)
	        |ГДЕ
	        |	ЕСТЬNULL(ОСТ.Остаток, 0) <= 0";
КонецФункции

&НаСервере
Функция ВернутьЗапросРежим2()
	Возврат "ВЫБРАТЬ
	        |	тзТовары.Товар
	        |ПОМЕСТИТЬ ВТ_ТЧ
	        |ИЗ
	        |	&тзТовары КАК тзТовары
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	ОстаткиТоваровОстатки.Товар КАК Товар,
	        |	ОстаткиТоваровОстатки.КоличествоОстаток КАК Остаток
	        |ПОМЕСТИТЬ ВТ_ОСТАТКИ
	        |ИЗ
	        |	РегистрНакопления.ОстаткиТоваров.Остатки(
	        |			&ДатаСреза,
	        |			Товар В
	        |				(ВЫБРАТЬ
	        |					Товары.Товар КАК Товар
	        |				ИЗ
	        |					ВТ_ТЧ КАК Товары)) КАК ОстаткиТоваровОстатки
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	РезервыТоваровОстатки.Товар КАК Товар,
	        |	РезервыТоваровОстатки.КоличествоОстаток КАК Остаток
	        |ПОМЕСТИТЬ ВТ_РЕЗЕРВЫ
	        |ИЗ
	        |	РегистрНакопления.РезервыТоваров.Остатки(
	        |			,
	        |			Товар В
	        |					(ВЫБРАТЬ
	        |						Товары.Товар КАК Товар
	        |					ИЗ
	        |						ВТ_ТЧ КАК Товары)
	        //|				И Контрагент <> &Контрагент
			| ) КАК РезервыТоваровОстатки
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	ТЧ.Товар КАК Товар,
	        |	ЕСТЬNULL(ОСТ.Остаток, 0) КАК Остаток,
	        |	ЕСТЬNULL(РЕЗ.Остаток, 0) КАК Резерв,
	        |	ЕСТЬNULL(ОСТ.Остаток, 0) - ЕСТЬNULL(РЕЗ.Остаток, 0) КАК СвободныйОстаток
	        |ИЗ
	        |	ВТ_ТЧ КАК ТЧ
	        |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОСТАТКИ КАК ОСТ
	        |		ПО (ОСТ.Товар = ТЧ.Товар)
	        |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_РЕЗЕРВЫ КАК РЕЗ
	        |		ПО (РЕЗ.Товар = ТЧ.Товар)";
КонецФункции


&НаСервере
Функция РезервКПогашениюПоПокупателю(тзТовары, Контрагент) Экспорт
	ТекстЗапроса = "ВЫБРАТЬ
	               |	тзТовары.Товар
	               |ПОМЕСТИТЬ ВТ_ТЧ
	               |ИЗ
	               |	&тзТовары КАК тзТовары
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	РезервыТоваровОстатки.ПартияРезерва КАК Партия,
	               |	РезервыТоваровОстатки.Товар КАК Товар,
	               |	СУММА(ЕСТЬNULL(РезервыТоваровОстатки.КоличествоОстаток, 0)) КАК Резерв
	               |ИЗ
	               |	РегистрНакопления.РезервыТоваров.Остатки(
	               |			,
	               |			Товар В
	               |					(ВЫБРАТЬ
	               |						Товары.Товар КАК Товар
	               |					ИЗ
	               |						ВТ_ТЧ КАК Товары)
	               |				И Контрагент = &Контрагент) КАК РезервыТоваровОстатки
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	РезервыТоваровОстатки.ПартияРезерва,
	               |	РезервыТоваровОстатки.Товар
	               |
	               |УПОРЯДОЧИТЬ ПО
				   |	Товар,
	               |	Партия";
	               
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("тзТовары", тзТовары);
	Запрос.УстановитьПараметр("Контрагент",Контрагент);
	РЗапроса = Запрос.Выполнить();
	Возврат РЗапроса;
КонецФункции

// 1 Таблица значений, поле товар обязательно
// 2 Отказ - флаг результата процедуры (ЛОЖЬ)
// 3 Список значений для последующей оброаботки в вышестоящей процедуре
// 4 Режим контроля 1 - контролировать только остатки
//					2 - контролировать остатки + реезрв
//
&НаСервере
Процедура КонтрольОстатковНаСервере(тзТовары, Контрагент, Отказ, ДатаСреза, сзОтсутствующиеТовары = Неопределено, РежимКонтроля = 1 ) Экспорт
	
	ТекстЗапроса = ?(РежимКонтроля = 1, ВернутьЗапросРежим1(), ВернутьЗапросРежим2());
		
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("тзТовары", тзТовары);
	Запрос.УстановитьПараметр("Контрагент",Контрагент);
	Запрос.УстановитьПараметр("ДатаСреза",ДатаСреза);
	РЗапроса = Запрос.Выполнить();	
	Выборка = РЗапроса.Выбрать();
	
	Если Выборка.Количество() > 0 Тогда
		Пока Выборка.Следующий() Цикл			
			// По условию только свободный остаток контролируется
			Если Выборка.СвободныйОстаток <=0 Тогда
				Отказ = Истина;	// Есть отрицательные остатки, или весь товар в резерве или товара нет в наличии - флаг Отказ ставим в истина;
			КонецЕсли;
			
			// Проверяем можем ли мы продать объем запрошенный в накладной, хватит ли для этого свободного остатка
			КоличествоВНакладной = 0;
			тзОбъемЗакупки = тзТовары.Скопировать(Новый Структура("Товар", Выборка.Товар));			
			Если тзОбъемЗакупки.Количество() > 0 Тогда
				тзОбъемЗакупки.Свернуть("Товар","Количество");
				КоличествоВНакладной = тзОбъемЗакупки[0].Количество;
				Если КоличествоВНакладной > Выборка.СвободныйОстаток Тогда
					Отказ = Истина ;					
				КонецЕсли;
			КонецЕсли;				
			
			Если ( сзОтсутствующиеТовары  = Неопределено ) Тогда
				Продолжить;
			КонецЕсли;							
			
			Если (ТипЗнч(сзОтсутствующиеТовары) <> Тип("СписокЗначений")) Тогда // Тип значения 3 параметра это список значений, проверяем. для того чтобы быть уверенными что третий параметр  это он и есть, а вдруг какой то хулиган нам туда отправит NULL или число иил еще чего нибудь (в общем другой тип)
				Продолжить;
			КонецЕсли;
			
			стОстатков = Новый Структура("Товар,Остаток,Резерв,СвободныйОстаток,Запрошено", Выборка.Товар, Выборка.Остаток, Выборка.Резерв, Выборка.СвободныйОстаток,КоличествоВНакладной);
			сзОтсутствующиеТовары.Добавить(стОстатков);
		КонецЦикла;		
	КонецЕсли;	
КонецПроцедуры