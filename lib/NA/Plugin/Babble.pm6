unit class NA::Plugin::Babble;
use NA::Config;
use IRC::Client::Message;

subset BotAdmin of IRC::Client::Message where .host eq conf<bot-admins>.any;

multi method irc-to-me (BotAdmin $e where /:i ^ 'hey' $/ ) { ｢yo｣ }
multi method irc-to-me (BotAdmin $e where /:i ^ 'yo' $/  ) {
    ｢Yo, yo, yo! What up, homeslice?｣
}
multi method irc-to-me (BotAdmin $e where /:i 'thank' /  ) {
    ｢any time, buddy!｣
}

multi method irc-to-me (BotAdmin $e where /:i ^ ["it is"|"it's"] ' time' $/ ) {
    ｢Oh boy! Really?! Release time!!!! YEY!｣
}
