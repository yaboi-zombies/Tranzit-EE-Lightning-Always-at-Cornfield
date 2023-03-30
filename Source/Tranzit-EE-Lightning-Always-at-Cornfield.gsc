#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\zm_transit_bus;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_ai_avogadro;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_sidequests;
#include maps\mp\zm_transit_utility;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_buildables;

init()
{
	replaceFunc(maps\mp\zombies\_zm_ai_avogadro::cloud_update_fx, ::custom_cloud_update_fx);
}

custom_cloud_update_fx()
{
	self endon( "cloud_fx_end" );
	level endon( "end_game" );
	region = [];
	region[ 0 ] = "cornfield";
	self.current_region = undefined;
	if ( !isDefined( self.sndent ) )
	{
		self.sndent = spawn( "script_origin", ( 0, 0, 1 ) );
		self.sndent playloopsound( "zmb_avogadro_thunder_overhead" );
	}
	cloud_time = getTime();
	vo_counter = 0;
	while ( 1 )
	{
		if ( getTime() >= cloud_time )
		{
			if ( isDefined( self.current_region ) )
			{
				exploder_num = level.transit_region[ self.current_region ].exploder;
				stop_exploder( exploder_num );
			}
			rand_region = array_randomize( region );
			region_str = rand_region[ 0 ];
			if ( !isDefined( self.current_region ) )
			{
				region_str = region[ 0 ];
			}
			idx = 0;
			if ( idx >= 0 )
			{
				region_str = region[ idx ];
			}
			avogadro_print( "clouds in region " + region_str );
			self.current_region = region_str;
			exploder_num = level.transit_region[ region_str ].exploder;
			exploder( exploder_num );
			self.sndent moveto( level.transit_region[ region_str ].sndorigin, 3 );
			cloud_time = getTime() + 30000;
		}
		if ( vo_counter > 50 )
		{
			player = self get_player_in_region();
			if ( isDefined( player ) )
			{
				if ( isDefined( self._in_cloud ) && self._in_cloud )
				{
					player thread do_player_general_vox( "general", "avogadro_above", 90, 10 );
				}
				else
				{
					player thread do_player_general_vox( "general", "avogadro_arrive", 60, 40 );
				}
			}
			else
			{
				level thread avogadro_storm_vox();
			}
			vo_counter = 0;
		}
		wait 0.1;
		vo_counter++;
	}
}