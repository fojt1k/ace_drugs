fx_version 'adamant'

game 'gta5'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua'
}


client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client/pickup.lua',
    'client/process.lua',
    'client/sell.lua'
}

server_scripts {
    'config.lua',
    'server/server.lua',
    'server/logs.lua'
}

dependencies {
	'es_extended',
    'ox_lib'
}