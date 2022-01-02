-- Script to extract event_type(s) and calculate total ABs, batting average, on-base percentage, slugging percentage
select 
	pm.player_id as 'PlayerID', 
    pm.name_last as 'Last Name',
    pm.name_use as 'First Name',
	ab.atbats as 'AB (At Bats)',
    round((ifnull(hits.total_hits,0) / ab.atbats), 3) as 'BA', 
	round((ifnull(obp.ob_event,0) / pa.plate_appearances), 3) as 'OBP',
	round(((ifnull(slg1.slg_single, 0) + ifnull(slg2.slg_double*2, 0) + ifnull(slg3.slg_triple*3, 0) + ifnull(slg4.slg_homerun*4,0)) / ab.atbats), 3) as 'SLG'    
    from play_by_play pbp
	-- Join player and play by play tables to merge names with player IDs
	join player_master pm on pm.player_id = pbp.batter_id
    -- Join tmp table that gives hit count by player, regular season
    join (	select batter_id, count(*) as total_hits
			from play_by_play where event_type in ('single','double','triple','home_run') and game_type = 'R' group by batter_id) as hits
            on hits.batter_id = pbp.batter_id
    -- Join tmp table that gives total AB count, regular season        
	join (	select batter_id, count(*) as atbats
			from play_by_play where event_type in (
            'double', 'double_play', 'field_error', 'field_out', 'fielders_choice', 'fielders_choice_out', 
            'force_out', 'grounded_into_double_play', 'home_run', 'single', 'strikeout', 'strikeout_double_play',
            'strikeout_triple_play', 'triple', 'triple_play') and game_type = 'R' group by batter_id) as ab
            on ab.batter_id = pbp.batter_id
	-- Join tmp table that gives total plate appearance count, regular season        
	join (	select batter_id, count(*) as plate_appearances
			from play_by_play where event_type in (
            'double', 'double_play', 'field_error', 'field_out', 'fielders_choice', 'fielders_choice_out', 
            'force_out', 'grounded_into_double_play', 'home_run', 'single', 'strikeout', 'strikeout_double_play',
            'strikeout_triple_play', 'triple', 'triple_play', 'walk', 'intent_walk', 'hit_by_pitch', 'sac_fly', 'sac_fly_double_play') and game_type = 'R' group by batter_id) as pa
            on pa.batter_id = pbp.batter_id
	-- Join tmp table for on base events, regular season
    left join (	select batter_id, count(*) as ob_event
			from play_by_play where event_type in ('single','double','triple','home_run','walk','intent_walk','hit_by_pitch') and game_type = 'R' group by batter_id) as obp
            on obp.batter_id = pbp.batter_id
	-- Join tmp table(s) to calculate slugging percentage, regular season
    left join (	select batter_id, count(*) as slg_single
				from play_by_play where event_type = 'single' and game_type = 'R' group by batter_id order by slg_single) as slg1
				on slg1.batter_id = pbp.batter_id
    left join (	select batter_id, count(*) as slg_double
				from play_by_play where event_type = 'double' and game_type = 'R' group by batter_id) as slg2
				on slg2.batter_id = pbp.batter_id
    left join (	select batter_id, count(*) as slg_triple
				from play_by_play where event_type = 'triple' and game_type = 'R' group by batter_id) as slg3
				on slg3.batter_id = pbp.batter_id
    left join (	select batter_id, count(*) as slg_homerun
				from play_by_play where event_type = 'home_run' and game_type = 'R' group by batter_id) as slg4
				on slg4.batter_id = pbp.batter_id
	group by pbp.batter_id
	order by pm.name_last, pm.name_use
