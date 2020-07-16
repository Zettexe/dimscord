import dimscord, asyncdispatch, strutils, options, tables

let discord = newDiscordClient("<your bot token goes here>")

proc getGuild(s: Shard, guild_id: string): Future[Guild] {.async.} =
    if guild_id in s.cache.guilds:
        return s.cache.guilds[guild_id]

    result = await discord.api.getGuild(guild_id)

proc getGuildChannel(s: Shard, guild_id, chan_id: string): Future[GuildChannel] {.async.} =
    if chan_id in s.cache.guildChannels:
        return s.cache.guildChannels[chan_id]

    let channels = await discord.api.getGuildChannels(guild_id) # We would to find the channel we are looking for,
    for channel in channels: # by iterating through every channel,
        if chan_id == channel.id: # then checking the channel id is equal,
            return channel # and finally returning the channel if it is.

proc getUser(s: Shard, user_id: string): Future[User] {.async.} =
    if user_id in s.cache.users:
        return s.cache.users[user_id]

    result = await discord.api.getUser(user_id)

proc messageCreate(s: Shard, m: Message) {.async.} =
    if m.author.bot or not m.member.isSome: return # If the message author is a bot or the message was in a DM, then stop.
    if m.content == "#!getguild": # Gets a guild from rest or cache
        discard await discord.api.sendMessage(
            m.channel_id, "Getting guild!"
        )
        let guild = await s.getGuild(get m.guild_id)
        echo guild[]
    elif m.content == "#!getgchan": # Gets a guild channel from rest or cache
        discard await discord.api.sendMessage(
            m.channel_id, "Getting guild channel!"
        )
        let channel = await s.getGuildChannel(get m.guild_id, m.channel_id)
        echo channel[]
    elif m.content == "#!getuser": # Gets a user from rest or cache
        discard await discord.api.sendMessage(
            m.channel_id, "Getting user!"
        )
        let user = await s.getUser(m.author.id)
        echo user[]

discord.events.message_create = messageCreate

when defined(noCaching): # Turn off caching when you define noCaching `-d:noCaching`
    waitFor discord.startSession(
        cache_users = false,
        cache_guilds = false,
        cache_guild_channels = false,
        cache_dm_channels = false
    )
else:
    waitFor discord.startSession()