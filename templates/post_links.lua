return {
["delimiter"] = "<span> </span>";
["delete"] = [[<a]]
                          ..[[ class="post_del_link"]]
                          ..[[ style="text-decoration: none; color: #FF0000; font-weight: bold;"]]
                          ..[[ title="Удалить пост"]]
                          ..[[ href="xmpp:__VAR:jid__?message;type=__VAR:stanza_type__;body=D%20%23__VAR:post_id__">]]
                          ..[[D</a>]];
["edit"] = [[<a]]
                      ..[[ class="post_edit_link"]]
                      ..[[ style="text-decoration: none; color: #00FF00; font-weight: bold;"]]
                      ..[[ title="Исправить"]]
                      ..[[ href="xmpp:__VAR:jid__?message;type=__VAR:stanza_type__;body=e%20%23__VAR:post_id__">]]
                      ..[[E</a>]];
["subscribe"] = [[<a]]
                      ..[[ class="post_sub_link"]]
                      ..[[ style="text-decoration: none; color: #00AAFF; font-weight: bold;"]]
                      ..[[ title="Подписаться на пост"]]
                      ..[[ href="xmpp:__VAR:jid__?message;type=__VAR:stanza_type__;body=S%20%23__VAR:post_id__">]]
                      ..[[S</a>]];
["unsubscribe"] = [[<a]]
                      ..[[ class="post_unsub_link"]]
                      ..[[ style="text-decoration: none; color: #00AAFF; font-weight: bold;"]]
                      ..[[ title="Отписаться от поста"]]
                      ..[[ href="xmpp:__VAR:jid__?message;type=__VAR:stanza_type__;body=U%20%23__VAR:post_id__">]]
                      ..[[U</a>]];
["bookmark"] = [[<a]]
                      ..[[ class="post_bookmark_link"]]
                      ..[[ style="text-decoration: none; color: #0055FF; font-weight: bold;"]]
                      ..[[ title="Добавить в закладки"]]
                      ..[[ href="xmpp:__VAR:jid__?message;type=__VAR:stanza_type__;body=~%20%23__VAR:post_id__">]]
                      ..[[~</a>]];
["read"] = [[<a ]]
                      ..[[ class="post_read_link"]]
                      ..[[ style="text-decoration: none; color: #D14606; font-weight: bold;"]]
                      ..[[ title="Прочитать пост со всеми комментариями"]]
                      ..[[ href="xmpp:__VAR:jid__?message;type=__VAR:stanza_type__;body=%23__VAR:post_id__+">]]
                      ..[[#__VAR:post_id__</a>]];
}
