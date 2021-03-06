﻿Процедура ОбработкаПроведения(Отказ, Режим)
	Перем сзОтсутствующиеТовары;
	сзОтсутствующиеТовары = Новый СписокЗначений();
	РежимКонтроля  = 2;
	омКонтрольОстатковСервер.КонтрольОстатковНаСервере(СписокТоваров.Выгрузить(), Контрагент, Отказ, Дата, сзОтсутствующиеТовары, РежимКонтроля);
	
	Если Отказ Тогда 		
		// Обработать список из предыдущей процедуры
		Для Каждого ССписка Из сзОтсутствующиеТовары Цикл
			Сообщить(" Не хватает товара: " + ССписка.Значение.Товар.Наименование + 
				Символы.ПС + Символы.Таб + ". Количество остаток " + Строка(ССписка.Значение.Остаток) +
			    Символы.ПС + Символы.Таб + ". Количество резерв " + Строка(ССписка.Значение.Резерв) +
			    Символы.ПС + Символы.Таб + ". Свободный остаток " + Строка(ССписка.Значение.СвободныйОстаток) +
				Символы.ПС + Символы.Таб + ". Запрошено: " + Строка(ССписка.Значение.Запрошено)				
			, СтатусСообщения.Внимание );
		КонецЦикла;		
		Возврат; 
	КонецЕсли;
	
	Движения.РезервыТоваров.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;
	Движения.ПартииТоваров.Записывать  = Истина;
	
	РЗапросаРезервКПогашению = омКонтрольОстатковСервер.РезервКПогашениюПоПокупателю(СписокТоваров.Выгрузить(), Контрагент);
	тзРезервыКПогашению = РЗапросаРезервКПогашению.Выгрузить();
	
	Для каждого СтрокаТовара Из СписокТоваров Цикл		
		
		ПроведениеПоРегиструОстатки(СтрокаТовара);
		
		СтруктураОтбора = Новый Структура("Товар", СтрокаТовара.Товар);
		тзРезультатРезерва = тзРезервыКПогашению.Скопировать(СтруктураОтбора);	
		
		ПроведениеПоРегиструРезерва(СтрокаТовара, тзРезультатРезерва);
		
	КонецЦикла;	
	
	ПроведениеПоРегиструПартии(Отказ);	
	
КонецПроцедуры
///////////////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры проведения по регистрам
///////////////////////////////////////////////////////////////////////////////////////////

// Остатки
Процедура ПроведениеПоРегиструОстатки(СтрокаТовара)
		// Регистр ОстаткиТоваров +++
		// Уменьшаем остаток		
		Движение = Движения.ОстаткиТоваров.Добавить();		
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Товар = СтрокаТовара.Товар;
		Движение.Количество = СтрокаТовара.Количество;
		// Регистр ОстаткиТоваров ---
КонецПроцедуры	

// FIFO Резервов
Процедура ПроведениеПоРегиструРезерва(СтрокаТовара, тзРезультатРезерва)
		// Регистр РезервыТоваров +++
		// Гасим резерв Если есть, что гасить.
		тзРезультатРезерва.Сортировать("Партия ВОЗР");  // Дополнительная сортировка партии, т.к. было условие
		// Нет строк в выборке, не должно такого быть, но так как, обращаемся по индексу, необходимо проверить на наличие строк
		КПогашению = 0;
		Если тзРезультатРезерва.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;
		
		// Гасим резерв по ФИФО как описано в условии задачи
		НеПогашенныйОстатокПоРезерву = СтрокаТовара.Количество; // Объем к погашению остатка
		Для Каждого СтрРЗ из тзРезультатРезерва Цикл
			КПогашению = Мин(НеПогашенныйОстатокПоРезерву,СтрРЗ.Резерв); // Сколко гасим исходя из резерва
			Если КПогашению <= 0 Тогда
				Продолжить; // Пропускаем нулевые и отрицательные
			КонецЕсли;
			НеПогашенныйОстатокПоРезерву = НеПогашенныйОстатокПоРезерву-КПогашению; // Корректируем объем к погашению
			ДвижениеРТ = Движения.РезервыТоваров.Добавить();
			ДвижениеРТ.ВидДвижения = ВидДвиженияНакопления.Расход;
			ДвижениеРТ.ПартияРезерва  = СтрРЗ.Партия;
			ДвижениеРТ.Период = Дата;
			ДвижениеРТ.Контрагент = Контрагент;
			ДвижениеРТ.Товар = СтрокаТовара.Товар;
			ДвижениеРТ.Количество = КПогашению;							
		КонецЦикла;
		// Регистр РезервыТоваров ---					
КонецПроцедуры

// FIFO Партии
Процедура ПроведениеПоРегиструПартии(Отказ)
	// Регистр ПартииТоваров +++
	// Гасим партии (подготовили на сервере)
	сзПартииКСписанию = Новый СписокЗначений();
	омПартионныйУчетСервер.ВыбратьДанныеПартионногоУчетаПоСпискуТоваров(Дата,СписокТоваров.Выгрузить(),сзПартииКСписанию, Отказ);

	Если Отказ 
		ИЛИ сзПартииКСписанию.Количество() = 0 Тогда 
		Сообщить("Не хватает товара для списания партии, проверьте резерв или остаток!" );
		Для Каждого СтрПартии Из сзПартииКСписанию Цикл
			Если СтрПартии.Значение.ФлагНарушенияПУ Тогда
				Сообщить("Товар: " + 
					СтрПартии.Значение.Товар.Наименование + 
					Символы.ПС + Символы.Таб + " Необходимо списать: "  + Строка(СтрПартии.Значение.Количество) + 
					Символы.ПС + Символы.Таб + " Остаток по партиям: "  + Строка(СтрПартии.Значение.КоличествоОстаток), СтатусСообщения.Внимание
				);
			КонецЕсли;
		КонецЦикла;
		Возврат; 
	КонецЕсли;
		
	Для Каждого ЭлементСписания Из сзПартииКСписанию Цикл
		ДвижениеПУ = Движения.ПартииТоваров.Добавить();
		ЗаполнитьЗначенияСвойств(ДвижениеПУ,ЭлементСписания.Значение);
		ДвижениеПУ.Период = Дата;
		ДвижениеПУ.ВидДвижения = ВидДвиженияНакопления.Расход;
	КонецЦикла;
	// Регистр ПартииТоваров ---		
КонецПроцедуры
	