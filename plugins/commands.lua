  cmds = {
    ping =
      function(event)
        --TODO
        if (event == "help") then
          return "В ответ на данную команду бот (если доступен) скажет PONG."
            .."\n"
            .."Дополнительным эффектом является присылание ботом статуса «онлайн» "
            .."на случай, если из-за бага со связью между серверами он выглядит как "
            .."оффлайн-контакт в Вашем ростере."
        end --[[ event help ]]
        if (event == "info") then
          return "Проверка доступности бота"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      --  c:set_status({show = "dnd", prio = 10, msg = "okay"})
        print(event.sender.jid.." pinged me!")
        xIOn:send(
          xIOn.XMPP.presence({to = event.sender.jid, from = config.jid})
      --[[
          :tag("show"):text("online"):up()
          :tag("priority"):text("10"):up()
          :tag("status"):text("Okay!"):up()
      ]]
        );
        xIOn:send_message(event.sender.jid, event.stanza.attr.type, "\n".."PONG");
      end;

    on =
      function(event)
        --TODO
        if (event == "help") then
          return "Команда используется для того, чтобы указать боту на то, что "
            .."с данного момента можно снова (после предыдушего включения режима "
            .."молчания) пересылать Вам сообщения из Вашей ленты."
            .."\n"
            .."Команда игнорирует любые передаваемые аргументы."
        end --[[ event help ]]
        if (event == "info") then
          return "Выйти из режима молчания"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
		xIOn.XMPP.roster.delgroup(xIOn.XMPP.bare_jid(event.sender.jid),"OFF");
        xIOn:send(xIOn.XMPP.presence({to = event.sender.jid, from = config.jid}));
        xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n".."Доставка сообщений включена.")
        end;

    off =
      function(event)
        --TODO
        if (event == "help") then
          return "Команда используется для того, чтобы указать боту на то, что "
            .."с данного момента (и до последующего использования команды ON) не "
            .."нужно пересылать Вам сообщения из Вашей ленты."
            .."\n"
            .."Команда игнорирует любые передаваемые аргументы."
        end --[[ event help ]]
        if (event == "info") then
          return "Режим молчания"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
		xIOn.XMPP.roster.addgroup(xIOn.XMPP.bare_jid(event.sender.jid),"OFF");
		xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n".."Доставка сообщений отключена.")
        end;

    here =
      function(event)
        --TODO
        if (event == "help") then
          return "Команда используется для того, чтобы указать боту на то, что JID "
            .."с которого Вы отправили команду стоит считать основным и отправлять "
            .."сообщения на него."
            .."\n"
            .."Команда требует, чтобы JID, с которого Вы её отправляете был указан "
            .."в настройках Вашего профиля. Любые передаваемые аргументы игнорируются"
        end --[[ event help ]]
        if (event == "info") then
          return "Смена активного JID для доставки сообщений"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n".."Доставка сообщений теперь будет производиться на этот JID.")
        end;
      
    hide =
      function(event)
        --TODO
        if (event == "help") then
          return "Команда используется для того, чтобы попросить бота отправить "
            .."Вам статус «оффлайн» и временно отключить доставку сообщений. Для "
            .."выхода из скрытого режима требуется отправить боту команду ON."
        end --[[ event help ]]
        if (event == "info") then
          return "Попросить бота спрятаться из ростера (скрытый режим)"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        xIOn:send(
          xIOn.XMPP.presence({to = event.sender.jid, from=jid,
          type = "unavailable"})
          :tag("status"):text("Прячемся от начальника"):up()
        );
      end;
      
    help =
      function(event)
        --TODO
        if (event == "help") then
          return "Команда используется для вывода справки о работе с сервисом и о "
          .."других командах."
          .."\n"
          .."При вызове без аргументов выводит список всех команд и пунктов "
          .."справки сервиса (с краткими примечаниями)."
          .."\n"
          .."При передаче в качестве аргумента команды или пункта справки сервиса — "
          .."выводит текст справки, относящийся к данной команде или пункту справки."
        end --[[ event help ]]
        if (event == "info") then
          return "Вывод справки по командам"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        local help_text = "";
        if event.body:lower() == "help" then
          help_text = xIOn:print_help();
          xIOn:send_message(event.sender.jid,event.stanza.attr.type,help_text);
        else
          local cmd = event.body:lower():match("help (.*)");
          print(cmd);
          cmd = cmds[cmd] or help_points[cmd] or handlers.non_existant_command;
          help_text = cmd("help");
          xIOn:send_message(event.sender.jid,event.stanza.attr.type,"\n"..help_text);
        end
      end;

    set =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда используется для изменения настроек Вашего профиля."
            .."\n"
            .."Синтаксис данной команды выглядит как\n    set option = value\n"
            .."где option — название настройки, которую требуется изменить, а "
            .."value — её значение."
            .."\n"
            .."Список доступных для изменения Вами настроек:"
            .."\n"
            .."    <ещё не готово>"
        end --[[ event help ]]
        if (event == "info") then
          return "Управление пользовательскими настройками"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;

    ["#"] =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда, вызванная без аргументов, показывает последние "
            .."сообщения из Вашей ленты."
            .."\n"
            .."При передаче команде в качестве основного (без пробела) аргумента "
            .."номера #сообщения или #/комментария — будет показано его содержимое. Если же "
            .."кроме сообщения или комментария через пробел указать текст, то данный текст "
            .."будет опубликован в качестве ответа на сообщение или комментарий."
            .."\n"
            .."При передаче же в качестве аргумента к #номеру_сообщения какого-либо *тегов —"
            .."данные теги будут добавлены (или убраны, в случае если такие теги уже установлены)."
            .."\n"
            .."Так же, внутри текста сообщения можно использовать #хештеги, которые "
            .."будут интерпретированы и добавлены к основным тегам поста."
        end --[[ event help ]]
        if (event == "info") then
          return "Просмотр последних сообщений Вашей ленты/публикация ответа."
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
      
    ["*"] =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда, вызванная без аргументов (если в сообщении нет "
            .."ничего кроме звёздочек и пробелов), показывает статистику "
            .."использования Вами тегов с сортировкой по количеству употреблений."
            .."\n"
            .."При передаче в качестве аргументов *тегов — выводит последние N "
            .."сообщений из Вашей ленты, содержащие указанные теги. Теги могут "
            .."содержать пробелы. Следующий тег обозначается *звёздочкой, перед "
            .."которой стоит пробел."
            .."\n"
            .."При передаче на следующей после тегов строке какого-либо текста — "
            .."текст будет опубликован, как сообщение с указанными тегами."
            .."\n"
            .."Так же, вместо переноса строки (например, если Вы пишете с "
            .."мобильного устройства, на котором затруднён набор переноса строки, "
            .."или же используете сложные виды письменности) "
            .."для обозначения окончания тегов и начала тела сообщения сообщения "
            .."можно использовать последовательность «**». То есть, якобы поставить "
            .."в конце списка тегов специальный тег-звёздочку. В этом случае всё "
            .."после «**» будет интерпретировано как тело сообщения."
        end --[[ event help ]]
        if (event == "info") then
          return "Просмотр статистики употребления Вами тегов/публикация сообщения с тегами"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        local post;
        post = xIOn:parse_post(event);
        if (not post.err) and (#post.tags>0 and #post.text==0) then
          xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
            ..'Ваши последние сообщения, содержащие среди тегов "'
            ..xIOn:tags_to_string(post.tags)
            ..'":\n'
            ..xIOn:last_user_messages("tags",post.author,post.tags));
          return;
        elseif (not post.err) and (#post.tags==0 and #post.text==0) then
          xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
            .."Статистика по употребляемым Вами тегам:"
            .."\n"
            ..xIOn:last_user_messages("alltags", xIOn:get_user_id(event.sender.jid)));
          return;
        elseif (not post.err) and (#post.text>0) then
          xIOn:write_post(post,event);
        else
          xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
            .."Вам удалось поймать ошибку, которую невозможно поймать в обычных условиях! "
            .."Пожалуйста, свяжитесь с @mva и расскажите ему о том, как Вам это удалось."
            .."А так же скажите ему кодовое имя ошибки: pt#549"
          );
          return;
        end; --[[ post ]]
      end; --[[ tags and post function ]]
      
    ["@"] =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда, при вызове без параметров показывает TOP10 "
            .."(по активности) пользователей сервиса."
            .."\n"
            .."Со временем будет показывать так же рекомендованных Вам пользователей."
            .."\n"
            .."При передаче в качестве основного аргумента (без пробела) @имени_пользователя "
            .."будет показана информация о данном пользователе."
            .."\n"
            .."Если после @имени_пользователя написать сообщение — оно будет "
            .."являться обращением к нему и оно будет опубликовано в его ленте "
            .."даже если он не подписан на Вас."
            .."\n"
            .."Так же, сообщение увидят все @пользователи, упомянутые в тексте сообщения "
            .."(если оно не является приватным. Если Вам нужно отправить приватное "
            .."сообщение группе перечисленных в нём людей — используйте вместе с "
            .."тегом *private так же тег *group)."
        end
        --TODO
        if (event == "info") then
          return "Просмотр информации о @пользователе"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end
        local post = xIOn:parse_post(event);
      
        if event.body == "@" then
          xIOn:top_blogs(event); --TODO
          return;
        end
      
        if post.dest and (#post.dest == 1) and (post.text == post.dest) then
          xIOn:send_message(event.sender.jid, event.stanza.attr.type, "\n"
            .."Инфо о пользователе @"
            ..post.dest[1]
            ..":\n\n"
            .."<будет включено на следующей стадии тестирования>"
          );
          -- search requested user and his activity;
          -- print results
          return;
        end
        xIOn:write_post(post,event);
      end;
    
    ["!"] =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда при вызове без параметров показывает последние "
            .."рекомендованные Вами сообщения и комментарии из Вашей ленты."
            .."\n"
            .."При передаче в качестве аргумента номера (в любой нотации, см. «help "
            .."notation») #сообщения или #/комментария "
            .."и опционально Ваш комментарий для рекомендации — "
            .."рекомендация будет добавлена в Вашу ленту с указанным комментарием."
            .."\n"
            .."При передаче в качестве аргумента @имени_пользователя "
            .."будут показаны рекомендованные Вами сообщения данного пользователя."
            .."\n"
            .."При передаче в качестве аргумента слова или фразы — будет выполнен "
            .."полнотекстовый поиск фразы среди рекомендованных Вами сообщений "
            .."и выведен результат."
        end --[[ event help ]]
        if (event == "info") then
          return "Рекомендовать #пост или #/комментарий"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        local what = event.body:match("![%s]*(.*)")
        local post_id,rec_comment = what:match([[[#]*([^%s]+)[%s]*(.*)]]);
        if not post_id then
          xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
            .."Последние рекомендованные Вами сообщения:"
            .."\n"
            ..xIOn:last_user_messages("recomendations",event));
          return
        end
        rec_comment = (rec_comment and #rec_comment>0) and rec_comment or nil;
        xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
          .."Пост номер "
          ..post_id
          .." рекомендован"
          ..(
            rec_comment and [[ с комментарием: «]]
              ..rec_comment
              ..[[»]] or [[]]
          )
          .."!");
      end;
      
    ["?"] =
      function(event)
        --TODO
        if (event == "help") then
          return cmds["help"]("help");
        end --[[ event help ]]
        if (event == "info") then
          return "Алиас для команды HELP";
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        event.body = event.body:gsub("?","help")
        cmds["help"](event)
      end;
    
   ["~"] =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда добавляет пост в закладки, для облегчения его нахождения в дальнейшем.";
        end --[[ event help ]]
        if (event == "info") then
          return "Добавить в закладки";
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
        local what = event.body:match("~[%s]*(.*)")
        local post_id,bookmark_comment = what:match([[[#]*([^%s]+)[%s]*(.*)]]);
        if not post_id then
          xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
            .."Последние добавленные в закладки сообщения:"
            .."\n"
            ..xIOn:last_user_messages("bookmarks",event));
          return
        end
        bookmark_comment = (bookmark_comment and #bookmark_comment>0) and bookmark_comment or nil;
        xIOn:send_message(event.sender.jid, event.stanza.attr.type,"\n"
          .."Пост номер "
          ..post_id
          .." добавлен в закладки"
          ..(
            bookmark_comment and [[ с комментарием: «]]
              ..bookmark_comment
              ..[[»]] or [[]]
          )
          .."!");
      end;
    
    d =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда используется для удаления сообщений или "
            .."комментариев. При передаче в качестве аргумента номера "
            .."#сообщения или #/комментария удаляет данное сообщение или комментарий "
            .."(при условии что данное сообщение или комментарий принадлежит Вам, или "
            .."относится к Вашему сообщению."
        end --[[ event help ]]
        if (event == "info") then
          return "Удалить #пост или #/комментарий, опубликованный Вами или в Вашем посте"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
      
    e =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда используется для редактирования сообщений или "
            .."комментариев. При передаче в качестве аргумента номера "
            .."#сообщения или #/комментария и нового текста в качестве второго — изменяет"
            .."данное сообщение или комментарий и отправляет уведомление об этом "
            .."подписчикам или участникам обсуждения соответственно"
            .."(при условии что данное сообщение или комментарий принадлежит Вам."
        end --[[ event help ]]
        if (event == "info") then
          return "Редактировать #пост или #/комментарий, опубликованный Вами"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
    
    s =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда используется для подписки на #сообщение или "
            .."@пользователя. Принимает в качестве аргумента либо #номер_сообщения, "
            .."либо @имя_пользователя."
            .."\n"
            .."При вызове без параметров — показывает список пользователей, на "
            .."которых Вы подписаны и список пользователей, подписанных на Вас.";
        end --[[ event help ]]
        if (event == "info") then
          return "Подписаться на #пост или @пользователя"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
    
    u =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда используется для того, чтобы отпиисаться от "
            .."получения уведомления об ответах на #сообщение или о новых сообщениях "
            .."@пользователя. Принимает в качестве аргумента либо #номер_сообщения, "
            .."либо @имя_пользователя."
        end --[[ event help ]]
        if (event == "info") then
          return "Отписаться от #поста или @пользователя"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
    
    bl =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда используется для того, чтобы управлять Вашим "
            .."персональным чёрным списком пользоваталей. @Пользователи, находящиеся "
            .."в чёрном списке не могут отправлять комментарии в Ваши посты и писать "
            .."Вам приватные сообщения. Так же от вас будут скрыты их комментарии в "
            .."чужих сообщениях, а так же рекомендации ими Ваших сообщений."
        end --[[ event help ]]
        if (event == "info") then
          return "Управление чёрным списком"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
    
    wl =
      function(event)
        --TODO
        if (event == "help") then
          return "Данная команда позволяет управлять белым списком Ваших подписчиков."
            .."\n"
            .."Белый список несёт следующие полезные функции:"
            .."\n"
            .."* При использовании режима приватного блога. "
            .."В данном случае подписаться на Ваш блог и читать сообщения из "
            .."Вашего блога смогут читать только те "
            .."пользователи, которых Вы занесли в белый список."
            .."\n"
            .."* При нахождении в режиме молчания (OFF) приватные сообщения "
            .."от пользователей, находящихся в белом списке будут доставляться "
            .."Вам в Jabber-клиент. Если данное поведение Вам мешает — "
            .."Вы можете отключить его командой «set white_offline = 0»."
            .."\n"
            .."\n"
            .."Принимает в качестве аргумента @имя_пользователя. Всё, что указано "
            .."после него — считается комментарием, который будет выводиться при "
            .."просмотре списка напротив @имени_пользователя."
            .."\n"
            .."При вызове без аргументов — показывается содержимое списка."
        end --[[ event help ]]
        if (event == "info") then
          return "Управление «белым списком»"
        end --[[ event info ]]
        if not (type(event) == "table") then
          return --TODO
        end --[[ event table ]]
      end;
  }

  help_points = {
    reg =
      function(event)
        --TODO
        if (event == "help") then
          return "Регистрация будет производиться через веб-интерфейс, который пока "
            .."ещё не закончен. На данный момент (на время тестирования) регистрация "
            .."происходит в виде ручного присылания подписки администратором."
        end --[[ event help ]]
        if (event == "info") then
          return "Справка по регистрации"
        end --[[ event info ]]
      end;

    tos =
      function(event)
        --TODO
        if (event == "help") then
          return "Основным и самым главным правилом сервиса является уважение "
            .."всех участников друг к другу вне зависимости от любых факторов."
			.."\n"
			.."Допускается только вежливое общение между пользователями. "
			.."Любая дискриминация запрещена. Грубое общение допускается "
			.."только по обоюдному согласию и вне первого сообщения поста."
			.."\n"
			.."На сервисе так же рекомендуется соблюдение общечеловеческих "
			.."моральных норм и ценностей."
			.."\n"
			.."Несоблюдение вышеописанных рекомендаций может привести к "
			.."насильному переводу личного блога нарушителя в непубличный "
			.."режим, а так же применение к нему политики WhiteList'инга: "
			.."каждый, кто добровольно согласен общаться с нарушителем должен "
			.."будет либо быть подписан на нарушителя, либо добавить его в WL."
			.."\n"
			.."Таким образом предполагается ограждать новых пользователей от "
			.."слишком навязчивого внимания и от не очень конструктивных бесед "
			.."с не очень конструктивными личностями."
        end --[[ event help ]]
        if (event == "info") then
          return "Справка по правилам использования сервиса"
        end --[[ event info ]]
      end;

    pm =
      function(event)
        --TODO
        if (event == "help") then
          return "Приватные сообщения пока что не отправляются вообще (как, "
            .."впрочем, и обычные). Будет реализовано в ближайшее время."
        end --[[ event help ]]
        if (event == "info") then
          return "Справка по отправке приватных сообщений"
        end --[[ event info ]]
      end;

    notation =
      function(event)
        --TODO
        if (event == "help") then
          return "Так называемая «нотация» постов подразумевает под собой "
            .."используемый алгоритм отображения нумерации:"
            .."\n"
            .."* Psto.Net/Point.IM подобный (#stone) [psto]"
            .."\n"
            .."* SHA-хеш сообщения (точнее, его окончание, в hex-представлении). "
            .."Используется в системе контроля версий «git», а так же, вроде, в "
            .."BNW.im. Ну и у нас в веб-интерфейсе (#d34df00d) [sha]"
            .."\n"
            .."* Десятичное представление aka juick-подобная нотация (#31337) [dec]"
            .."\n"
            .."* Текущий выбранный по умолчанию администратором сервиса [default]"
            .."\n\n"
            .."Стоит отметить, что в случаях «dec» и «psto» идёт относительная "
            .."(в пределах Вашей ленты) нумерация."
            .."\n"
            .."Возможно, по итогам обсуждений, в будущем останется только sha-нотация."
            .."\n\n"
            .."Выбрать подходящий вариант можно с помощью команды"
            .."\n"
            .."    set notation=<вариант>"
            .."\n\n"
            .."#/комментарии при этом всегда имеют десятичную запись (возможно, "
            .."изменится в будущем), чтобы не уподобляться Твиттеру."
        end --[[ event help ]]
        if (event == "info") then
          return "Справка по нумерации сообщений"
        end --[[ event info ]]
      end;
  }

  handlers = {
    non_existant_command =
      function(event)
        --TODO
        if (event == "help") or (event == "info") then
          return "Данная команда не поддерживается ботом"
        end
      end;
  }

  return cmds;
