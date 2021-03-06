﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	Движения.ТоварыВСистеме.Записывать = Истина;
	Движения.СтатусТовара.Записывать = Истина;
	Для Каждого ТекСтрокаСписокТоваров Из СписокТоваров Цикл
		Движение = Движения.ТоварыВСистеме.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Товар = ТекСтрокаСписокТоваров.Товар;
		Движение.Партия = Ссылка;
		Движение.РабочееМесто = Справочники.РабочиеМеста.ОсновнойСклад;
		Движение.Количество = ТекСтрокаСписокТоваров.Количество;
		// 
		// регистр СтатусТовара Приход
		ДвижениеСТ = Движения.СтатусТовара.Добавить();
		ДвижениеСТ.ВидДвижения = ВидДвиженияНакопления.Приход;
		ДвижениеСТ.Период = Дата;
		ДвижениеСТ.Товар = ТекСтрокаСписокТоваров.Товар;
		ДвижениеСТ.Количество = ТекСтрокаСписокТоваров.Количество;
		ДвижениеСТ.Документ = Ссылка;
		ДвижениеСТ.Статус = Перечисления.СтатусыТовара.Новый;
	КонецЦикла;
КонецПроцедуры
