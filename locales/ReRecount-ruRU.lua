local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
--ruRU by Аrgonavt (update and fix by StingerSoft)
local L = AceLocale:NewLocale("ReRecount", "ruRU")
if not L then return end

	L["Profiles"] = "Профиля"
	L["GUI"] = "Интерфейс"
	L["gui"] = "gui"
	L["Open Ace3 Config GUI"] = "Открывает интерфейс настроек Ace3"
	L["Sync"] = "Синхр"
	L["sync"] = "sync"
	L["Toggles sending synchronization messages"] = "Вкл/Выкл отсылку сообщений синхронизации"
	L["Reset"] = "Сброс"
	L["reset"] = "reset"
	L["Resets the data"] = "Сбрасывает все данные"
	L["VerChk"] = "Проверка версии"
	L["verChk"] = "verChk"
	L["Displays the versions of players in the raid"] = "Показывает версии игроков участвующих Рейде"
	L["Displaying Versions"] = "Отображение версии"
	L["Show"] = "Отображение"
	L["show"] = "show"
	L["Shows the main window"] = "Показать основное окно"
	L["Hide"] = "Скрыть"
	L["Hides the main window"] = "Скрыть основное окно"
	L["Toggle"] = "Переключить"
	L["Toggles the main window"] = "Переключится на основное окно"
	L["Report"] = "Отчет"
	L["Allows the data of a window to be reported"] = "Позволяет сообщать данные окна"
	L["Detail"] = "Детали"
	L["Report the Detail Window Data"] = "Отчет деталей окна данных"
	L["Main"] = "Основное"
	L["Report the Main Window Data"] = "Отчет основного окна данных"
	L["Config"] = "Настр-ки"
	L["Shows the config window"] = "Показать окно настройки"
	L["ResetPos"] = "Сброс позиции"
	L["Resets the positions of the detail, graph, and main windows"] = "Сброс позиций деталей, графика, и основного окна"
	L["Lock"] = "Закрепить"
	L["Toggles windows being locked"] = "Вкл/Выкл фиксицию окна"
	L["|cffff4040Disabled|r"] = "|cffff4040Отключено|r"
	L["|cff40ff40Enabled|r"] = "|cff40ff40Включено|r"
	L["Unknown Spells"] = "Неизвестные Заклинания"
	L["Shows found unknown spells in BabbleSpell"] = "Отображать найденные неизвестные заклинания в BabbleSpell"
	L["Unknown Spells:"] = "Неизвестные заклятия:"
	L["Realtime"] = "Реальное время"
	L["Specialized Realtime Graphs"] = "Специализированные графики в реальном времени"
	L["FPS"] = "Кадров в сек"
	L["Starts a realtime window tracking your FPS"] = "Открыть окно отслеживание в реальном времени кадров в секунду (FPS)"
	L["Lag"] = "Задержка"
	L["Starts a realtime window tracking your latency"] = "Открыть окно отслеживания в реальном времени вашего периода ожидания (ping)"
	L["Upstream Traffic"] = "Исходящий трафик"
	L["Starts a realtime window tracking your upstream traffic"] = "Открыть окно отслеживания в реальном времени ваш исходящий сетевой трафик"
	L["Downstream Traffic"] = "Входящий трафик"
	L["Starts a realtime window tracking your downstream traffic"] = "Открыть окно отслеживания в реальном времени ваш входящий сетевой трафик"
	L["Available Bandwidth"] = "Пропускная способность"
	L["Starts a realtime window tracking amount of available AceComm bandwidth left"] = "Открыть окно отслеживания в реальном времени значение доступной AceComm пропускной способности"
	L["Tracks your entire raid"] = "Отслеживать рейд"
	L["DPS"] = "УВС"
	L["Tracks Raid Damage Per Second"] = "Отслеживать урон рейда в секунду (DPS)"
	L["DTPS"] = "ПУВС"
	L["Tracks Raid Damage Taken Per Second"] = "Отслеживать получаемый урон рейда в секунду (DTPS)"
	L["HPS"] = "ИВС"
	L["Tracks Raid Healing Per Second"] = "Отслеживать исцеление рейда в секунду (HPS)"
	L["HTPS"] = "ПИВС"
	L["Tracks Raid Healing Taken Per Second"] = "Отслеживать получаемое исцеление рейда в секунду (HTPS)"
	L["Pet"] = "Питомец" -- Elsia: Stuff from here down is not yet fully localized.
	L["Mob"] = "Моб"
	L["Title"] = "Заголовок"
	L["Background"] = "Фон"
	L["Title Text"] = "Заглавный текст"
	L["Bar Text"] = "Текст панели"
	L["Total Bar"] = "Общая панель"
	L["Show previous main page"] = "Показать предыдущую основную страницу" -- Elsia: And even more stuff not yet fully localized.
	L["Show next main page"] = "Показать следующую основную страницу"
	L["Display"] = "Отображение"
	L["Damage Done"] = "Нанесено урона"
	L["Friendly Fire"] = "Дружеский огонь"
	L["Damage Taken"] = "Получено урона"
	L["Healing Done"] = "Нанесено исцеления"
	L["Healing Taken"] = "Получено исцеления"
	L["Overhealing Done"] = "Получено пере-исцелении"
	L["Deaths"] = "Смертей"
	L["DOT Uptime"] = "Время УЗВ(DOT)"
	L["HOT Uptime"] = "Время ИЗВ(HOT)"
	L["Dispels"] = "Рассеивании"
	L["Dispelled"] = "Рассеяно"
	L["Interrupts"] = "Прерываний"
	L["Ressers"] = "Воскрешении"
	L["CC Breakers"] = "Встали по КД(СС)"
	L["Activity"] = "Активность"
	L["Threat"] = "Угроза"
	L["Mana Gained"] = "Маны Получено"
	L["Energy Gained"] = "Энергии Получено"
	L["Rage Gained"] = "Ярости Получено"
	L["Network Traffic(by Player)"] = "Сетевой трафик (по игрокам)"
	L["Network Traffic(by Prefix)"] = "Сетевой трафик (по префиксу)"
	L["Bar Color Selection"] = "Выбор цвета панели"
	L["Class Colors"] = "Классовые цвета"
	L["Reset Colors"] = "Сбросить цвета"
	L["Is this shown in the main window?"] = "Это показывать в главном окне?"
	L["Record Data"] = "Запись данных"
	L["Whether data is recorded for this type"] = "Запись данных для этого типа"
	L["Record Time Data"] = "Запись времени данных"
	L["Whether time data is recorded for this type (used for graphs can be a |cffff2020memory hog|r if you are concerned about memory)"] = "Запись времени данных для этого типа (используя для графиков может |cffff2020сожрать много памети|r )"
	L["Record Deaths"] = "Запись смертей"
	L["Records when deaths occur and the past few actions involving this type"] = "Запись смертей и подобных эффектов"
	L["Record Buffs/Debuffs"] = "Запись положительных/отрицательных эффектов"
	L["Records the times and applications of buff/debuffs on this type"] = "Запись времени и использования положительных/отрицательных эффектов (баффов/дебаффов)"
	L["Filters"] = "Фильтры"
	L["Players"] = "Игроки"
	L["Self"] = "Лично"
	L["Grouped"] = "Группы"
	L["Ungrouped"] = "Без группы"
	L["Pets"] = "Питомцы"
	L["Mobs"] = "Мобы"
	L["Trivial"] = "Обычные"
	L["Non-Trivial"] = "Не обычные"
	L["Bosses"] = "Боссы"
	L["Unknown"] = "Неизвестные"
	L["Bar Selection"] = "Выбор полос"
	L["Font Selection"] = "Выбор шрифта"
	L["General Window Options"] = "Окно общих опций"
	L["Reset Positions"] = "Сброс позиции"
	L["Window Scaling"] = "Прокрутка окна"
	L["Data Deletion"] = "Вычеркивание Данных"
	L["Instance Based Deletion"] = "Основные удаления"
	L["Group Based Deletion"] = "Групповые удаления"
	L["Global Realtime Windows"] = "Общие окна действий"
	L["Network"] = "Сеть"
	L["Latency"] = "Задержка"
	L["Up Traffic"] = "Исх.трафик"
	L["Down Traffic"] = "Вхд.трафик"
	L["Bandwidth"] = "Проп.Способ."
	L["ReRecount Version"] = "Версия ReRecountа"
	L["Check Versions"] = "Проверить версию"
	L["Data Options"] = "Опции данных"
	L["Combat Log Range"] = "Даиапозон журнала боя"
	L["Yds"] = "Метры"
	L["Fix Ambiguous Log Strings"] = "Налаживать неоднозначные строки журнала"
	L["Merge Pets w/ Owners"] = "Объединить Питомца/Хозяина"
	L["Main Window Options"] = "Опции основного окна"
	L["Show Buttons"] = "Показать кнопки"
	L["File"] = "Файл"
	L["Previous"] = "Пред"
	L["Next"] = "След"
	L["Row Height"] = "Высота строк"
	L["Row Spacing"] = "Промежуток строк"
	L["Autohide On Combat"] = "Убирать во время боя"
	L["Show Scrollbar"] = "Показ полосу прокрутки"
	L["Data"] = "Данные"
	L["Appearance"] = "Внешний вид"
	L["Color"] = "Цвет"
	L["Window"] = "Окно"
	L["Window Color Selection"] = "Окно выбора цвета"
	L["Main Window"] = "Основное окно"
	L["Other Windows"] = "Другие окна"
	L["Global Data Collection"] = "Глобальный сбор данных"
	L["Autoswitch Shown Fight"] = "Авто-переключения"
	L["Lock Windows"] = "Зафиксировать окно"
	L["Autodelete Time Data"] = "Авто-уд. времени данных"
	L["Delete on Entry"] = "Удал.входящее"
	L["New"] = "Новое"
	L["Confirmation"] = "Подтверждение"
	L["Delete on New Group"] = "Удалить в новой группе"
	L["Delete on New Raid"] = "Удалить в новом рейде"
	L["Sync Data"] = "Синх данных"
	L["Set Combat Log Range"] = "Уст. радиуса журнала боя"
	L["Detail Window"] = "Окно деталей"
	L["Death Details for"] = "Детали смертей в"
	L["Health"] = "Здоровье"
	L["ReRecount"] = "ReRecount"
	L["Outgoing"] = "Исходящий"
	L["Incoming"] = "Входящий"
	L["Damage Report for"] = "Отчёт по урону"
	L["Damage"] = "Урон"
	L["Resisted"] = "Сопрот."
	L["Report for"] = "Отчет"
	L["Glancing"] = "Скользящие"
	L["Hit"] = "Удар"
	L["Crushing"] = "Сокрушительный"
	L["Crit"] = "Крит"
	L["Miss"] = "Промах"
	L["Dodge"] = "Уворот"
	L["Parry"] = "Парирование"
	L["Block"] = "Блок"
	L["Resist"] = "Сопротивление"
	L["Tick"] = "Импульсов"
	L["Split"] = "Разделенный"
	L["X Gridlines Represent"] = "X линии сетки"
	L["Seconds"] = "Секунд"
	L["Graph Window"] = "Окно графика"
	L["Data Name"] = "Название данных"
	L["Enabled"] = "Включено"
	L["Fought"] = "Бой"
	L["Start"] = "Начало"
	L["End"] = "Конец"
	L["Normalize"] = "Нормализовать"
	L["Integrate"] = "Объединить"
	L["Stack"] = "Стек"
	L["Report Data"] = "Отчет Данных"
	L["Report To"] = "Сообщить в"
	L["Report Top"] = "Сообщить о первых"
	L["Reset ReRecount?"] = "Сбросить ReRecount?"
	L["Do you wish to reset the data?"] = "Вы хотите сбросить данные?"
	L["Yes"] = "Да"
	L["No"] = "Нет"
	L["Show Details (Left Click)"] = "Показать детали (Левый Клик)"
	L["Show Graph (Shift Click)"] = "Показать график (Shift-Клик)"
	L["Add to Current Graph (Alt Click)"] = "Добавить в текущий график(Alt-Клик)"
	L["Show Realtime Graph (Ctrl Click)"] = "Показ график в реальном времени (Ctrl-Клик)"
	L["Delete Combatant (Ctrl-Alt Click)"] = "Удалить бойца (Ctrl-Alt-Клик)"
	L[" for "] = " из "
	L["Overall Data"] = "Полный отчет"
	L["Current Fight"] = "Текущий отчет"
	L["Last Fight"] = "Последний бой"
	L["Fight"] = "Бой"
	L["Top Color"] = "Цвет верха"
	L["Bottom Color"] = "Цвет низа"
	L["Ability Name"] = "Название способности"
	L["Type"] = "Тип"
	L["Min"] = "Мин"
	L["Avg"] = "Сред"
	L["Max"] = "Макс"
	L["Count"] = "Сумма"
	L["Player/Mob Name"] = "Имя Игрока/Моба"
	L["Attack Name"] = "Название атаки"
	L["Time (s)"] = "Время (с)"
	L["Heal Name"] = "Имя Исцеления"
	L["Heal"] = "Исцеление"
	L["Healed"] = "Исцелено"
	L["Overheal"] = "Пере-исцелено"
	L["Ability"] = "Способность"
	L["DOT Time"] = "Время УЗВ(DOT)"
	L["Ticked on"] = "Помечен на"
	L["Duration"] = "Продолжительность"
	L["HOT Time"] = "Время ИЗВ(HOT)"
	L["Interrupted Who"] = "Кто прервал"
	L["Interrupted"] = "Прерван"
	L["Ressed Who"] = "Кто Воскрешен"
	L["Times"] = "Время"
	L["Who"] = "Кто"
	L["Broke"] = "Сломался"
	L["Broke On"] = "Сломался на"
	L["Gained"] = "Получено"
	L["From"] = "От"
	L["Prefix"] = "Префикс"
	L["Messages"] = "Сообщение"
	L["Distribution"] = "Распределение"
	L["Bytes"] = "Байты"
	L["'s Hostile Attacks"] = "'s Враждебные Атаки"
	L["Damaged Who"] = "Кто Нанес Урон"
	L["'s Partial Resists"] = "'s Текущие Резисты"
	L["'s Time Spent Attacking"] = "'s Время в Атаке"
	L["'s Friendly Fire"] = "'s Дружеский огонь"
	L["Friendly Fired On"] = "Дружеский огонь От"
	L["Took Damage From"] = "Получено Повреждений От"
	L["'s Effective Healing"] = " эффективное исцеление"
	L["Healed Who"] = "Кто Излечен"
	L["'s Overhealing"] = "'s Пере-исцелено"
	L["'s Time Spent Healing"] = "'s Время Лечения"
	L["was Healed by"] = "был Исцелен"
	L["'s DOT Uptime"] = "'s время УЗВ"
	L["'s HOT Uptime"] = "'s время ИЗВ"
	L["'s Interrupts"] = "'s прерываний"
	L["'s Resses"] = "'s Воскрешено"
	L["'s Dispels"] = "'s Рассеяно"
	L["was Dispelled by"] = "рассеял"
	L["'s Time Spent"] = "'s прошло времени"
	L["CC Breaking"] = "Встали по КД(СС)"
	L["'s Mana Gained"] = "'s получено маны"
	L["'s Mana Gained From"] = "'s получено маны от"
	L["'s Energy Gained"] = "'s получено энергии"
	L["'s Energy Gained From"] = "'s получено энергии от"
	L["'s Rage Gained"] = "'s получено ярости"
	L["'s Rage Gained From"] = "'s получено ярости от"
	L["'s Network Traffic"] = "'s сетевого трафика"
	L["Top 3"] = "Топ 3"
	L["Damage Abilities"] = "Способность урона"
	L["Attacked"] = "Атакован"
	L["Pet Damage Abilities"] = "Урон способностей питомца"
	L["Pet Attacked"] = "Атак питомца"
	L["Click for more Details"] = "Клик для большей инфы"
	L["Friendly Attacks"] = "Аттак союзника"
	L["Attacked by"] = "Атакованный"
	L["Heals"] = "Исцеление"
	L["Healed By"] = "Вылечено"
	L["Over Heals"] = "Пере-исцелено"
	L["DOTs"] = "УзВ (DOTs)"
	L["HOTs"] = "ИзВ (HOTs)"
	L["Dispelled By"] = "Рассеяно"
	L["Attacked/Healed"] = "Атаковано/Вылечено"
	L["Time Damaging"] = "Время Урона"
	L["Time Healing"] = "Время Исцеления"
	L["Mana Abilities"] = "Способности маны"
	L["Mana Sources"] = "Источники маны"
	L["Energy Abilities"] = "Способности энергии"
	L["Energy Sources"] = "Источники энергии"
	L["Rage Abilities"] = "Способности ярости"
	L["Rage Sources"] = "Источники ярости"
	L["CC's Broken"] = "Встали по КД(СС)"
	L["Ressed"] = "Воскрешено"
	L["Network Traffic"] = "Сетевой трафик"
	L["'s DPS"] = "'s DPS"
	L["'s DTPS"] = "'s DTPS"
	L["'s HPS"] = "'s HPS"
	L["'s HTPS"] = "'s HTPS"
	L["'s TPS"] = "'s TPS"
	L["Threat on"] = "Угроза на"
	L["Name of Ability"] = "Назв.способности"
	L["Time"] = "Время"
	L["Killed By"] = "Убит"
	L["Combat Messages"] = "Сообщения боя"
	L["Misc"] = "Разное"
	L["Show Graph"] = "Показать график"
	L["Config ReRecount"] = "Настройки ReRecount"
	L["Death Graph"] = "График смертей"
	L["Melee"] = "Ближний"
	L["Physical"] = "Физический"
	L["Arcane"] = "Теневая"
	L["Fire"] = "Огонь"
	L["Frost"] = "Холод"
	L["Holy"] = "Святая"
	L["Nature"] = "Природная"
	L["Shadow"] = "Темная"
	L["Total"] = "Всего"
	L["Taken"] = "Получено"
	L["Damage Focus"] = "Фокус урона"
	L["Avg. DOTs Up"] = "в сред. УЗВя"
	L["Pet Damage"] = "Урон Пита"
	L["No Pet"] = "Нет Питомца"
	L["Pet Time"] = "Время Питомца"
	L["Pet Focus"] = "Фокус Питомца"
	L["Healing"] = "Исцеления"
	L["Overhealing"] = "Пере-исцелено"
	L["Heal Focus"] = "Фокус Исцеления"
	L["Avg. HOTs Up"] = "в Сред. ИзВ"
	L["Attack Summary Outgoing (Click for Incoming)"] = "Общая Сумма исходящей Атаки (Клик для просмотра входящей)"
	L["Attack Summary Incoming (Click for Outgoing)"] = "Общая Сумма входящей Атаки (Клик для просмотра исходящей)"
	L["Summary Report for"] = "Финальный отчет для"
	L["Say"] = "Сказать"
	L["Party"] = "Группу"
	L["Raid"] = "Рейд"
	L["Guild"] = "Гильдию"
	L["Officer"] = "Офицерам"
	L["Whisper"] = "Шепнуть"
	L["Whisper Target"] = "Шепнуть цели"
	L["Blocked"] = "Блокировано"
	L["Absorbed"] = "Поглощено"
	L["Guardian"] = "Охранник"
	L["Click for next Pet"] = "Клик для след.пита"
	L["Outside Instances"] = "Внешние инсты"
	L["Party Instances"] = "Групповые подземелья"
	L["Raid Instances"] = "Рейдовые подземелья"
	L["Battlegrounds"] = "ПС"
	L["Arenas"] = "Арены"
	L["Content-based Filters"] = "Фильтры осн-содерж"
	L["Show Total Bar"] = "Показ всех панелей"
	L["Config Access"] = "Опции Доступа"
	L["Window Options"] = "Окно опций"
	L["Sync Options"] = "Опции Синх"
	L["Hostile"] = "Враги"
	L["Rank Number"] = "Уровень"
	L["Bar Text Options"] = "Опции текста панелей"
	L["Per Second"] = "В секунду"
	L["Percent"] = "Процент"
	L["Fight Segmentation"] = "Сегментация боя"
	L["Keep Only Boss Segments"] = "Только сегменты босса"
	L["Click|r to toggle the ReRecount window"] = "Клик| чтобы переключить окно ReRecountа" 
	L["Right-click|r to open the options menu"] = "Правый-клик|r скрыть меню опций"
	L["Number Format"] = "Числовой формат"
	L["Standard"] = "Обычное"
	L["Commas"] = "С запятой"
	L["Short"] = "Сокращенные"
	L["Hide When Not Collecting"] = "Прятать при простое"
	L["DoT"] = "УзВ"
	L["HoT"] = "ИзВ"
	L["Recorded Fights"] = "Записано боев"
	L["Set the maximum number of recorded fight segments"] = "Установить максимальное число записываемых боев"
