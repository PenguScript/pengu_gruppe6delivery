fx_version 'cerulean'
game 'gta5'

description 'QB-GarbageJob'
version '1.2.0'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua', -- If you use OX Dialog uncomment this.

}

client_script {

	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua'
}
server_script 'server/main.lua'

lua54 'yes'
