﻿&НаСервере
Функция ВернутьТекстЗапросаПартии()
Возврат "ВЫБРАТЬ
        |	тзТовары.Товар
        |ПОМЕСТИТЬ ВТ_ТЧ
        |ИЗ
        |	&тзТовары КАК тзТовары
        |;
        |
        |////////////////////////////////////////////////////////////////////////////////
        |ВЫБРАТЬ
        |	ПартииТоваровОстатки.Товар КАК Товар,
        |	ПартииТоваровОстатки.Партия КАК Партия,
        |	ЕСТЬNULL(ПартииТоваровОстатки.КоличествоОстаток, 0) КАК ОстатокПартии
        |ИЗ
        |	РегистрНакопления.ПартииТоваров.Остатки(
        |			&ДатаСреза,
        |			Товар В
        |				(ВЫБРАТЬ
        |					Товары.Товар КАК Товар
        |				ИЗ
        |					ВТ_ТЧ КАК Товары)) КАК ПартииТоваровОстатки
        |
        |УПОРЯДОЧИТЬ ПО
        |	Товар,
        |	Партия";
КонецФункции

&НаСервере
Процедура ВыбратьДанныеПартионногоУчетаПоСпискуТоваров(ДатаСреза, тзТовары, сзПартииКСписанию, Отказ=ЛОЖЬ) Экспорт
	ТекстЗапроса = ВернутьТекстЗапросаПартии();
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("тзТовары",тзТовары);
	Запрос.УстановитьПараметр("ДатаСреза",ДатаСреза);		
	РЗапроса = Запрос.Выполнить();
	тзОстаткиПартий = РЗапроса.Выгрузить();
	СтрокаПолейСтруктуры = "Товар,Партия,Количество,КоличествоОстаток,ФлагНарушенияПУ";
	Для Каждого СтрТ из тзТовары Цикл		
		ОбъемКСписанию = СтрТ.Количество;
		ОтборПартий = Новый Структура("Товар", СтрТ.Товар);
		тзПартииПоТовару = тзОстаткиПартий.Скопировать(ОтборПартий);
		тзПартииПоТовару.Сортировать("Партия");
		Пока ОбъемКСписанию > 0 Цикл
			Для Каждого СтрППТ из тзПартииПоТовару Цикл
				КоличествоВПартии = СтрППТ.ОстатокПартии;
				ТекЗнПоСписанию = Мин(КоличествоВПартии,ОбъемКСписанию);
				сзПартииКСписанию.Добавить(Новый Структура(СтрокаПолейСтруктуры, СтрППТ.Товар,СтрППТ.Партия,ТекЗнПоСписанию,СтрППТ.ОстатокПартии,ЛОЖЬ));
				ОбъемКСписанию = ОбъемКСписанию - ТекЗнПоСписанию;
				Если ОбъемКСписанию <= 0 Тогда Прервать; КонецЕсли;
			КонецЦикла;
			
			// Если партионный учет нарушен, то остаток положительный, тогда
			// Гасим весь оставшийся объем пустой ссылкой на поступление для данного товара,
			// В допполе пишем флаг нарушения ПУ и прерываем цикл по данному товару
			Если ОбъемКСписанию > 0 Тогда
			    сзПартииКСписанию.Добавить(Новый Структура(СтрокаПолейСтруктуры, СтрППТ.Товар,Документы.ПриходнаяНакладная.ПустаяСсылка(),ОбъемКСписанию,СтрППТ.ОстатокПартии,ИСТИНА));
				ОбъемКСписанию = 0;
				Отказ = Истина;
				Прервать;
			КонецЕсли;	
			
			Прервать; // делаем невозможным бесконечный цикл (контрольно)
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры
