murshun_giveUniform_fnc = {
	_unit = _this select 0;
	_string = _this select 1;

	if (count _string != 0) then {
		_unit forceAddUniform _string;
	};
};

murshun_giveVest_fnc = {
	_unit = _this select 0;
	_string = _this select 1;

	if (count _string != 0) then {
		_unit addVest _string;
	};
};

murshun_giveHeadgear_fnc = {
	_unit = _this select 0;
	_string = _this select 1;

	if (count _string != 0) then {
		_unit addHeadgear _string;
	};
};

murshun_giveBackpack_fnc = {
	_unit = _this select 0;
	_string = _this select 1;

	if (count _string != 0) then {
		_unit addBackpack _string;
	};
};

murshun_giveGoggles_fnc = {
	_unit = _this select 0;
	_string = _this select 1;

	if (count _string != 0) then {
		_unit addGoggles _string;
	};
};

murshun_giveWeapon_fnc = {
	_unit = _this select 0;
	_array = _this select 1;

	if (count _array == 3) then {
		_weapon = _array select 0;
		_mags = _array select 1;
		_devices = _array select 2;

		if (count _weapon != 0) then {
			_unit addWeapon _weapon;
		};
		
		{
			if (count _x == 2) then {
				if (count (_x select 0) != 0) then {
					if (([_weapon] call ace_common_fnc_getItemType) select 1 == "primary") then {
						_unit addPrimaryWeaponItem (_x select 0);
					};
					if (([_weapon] call ace_common_fnc_getItemType) select 1 == "handgun") then {
						_unit addHandgunItem (_x select 0);
					};
					if (([_weapon] call ace_common_fnc_getItemType) select 1 == "secondary") then {
						_unit addSecondaryWeaponItem (_x select 0);
					};
				};
			};
		} foreach _mags;
		
		{
			if (count _x == 2) then {
				if (count (_x select 0) != 0) then {
					_unit addMagazines _x;
				};
			};
		} foreach _mags;

		{
			if (count _x != 0) then {
				if (([_weapon] call ace_common_fnc_getItemType) select 1 == "primary") then {
					_unit addPrimaryWeaponItem _x;
				};
				if (([_weapon] call ace_common_fnc_getItemType) select 1 == "handgun") then {
					_unit addHandgunItem _x;
				};
				if (([_weapon] call ace_common_fnc_getItemType) select 1 == "secondary") then {
					_unit addSecondaryWeaponItem _x;
				};
			};
		} foreach _devices;
	};
};

murshun_giveItems_fnc = {
	_unit = _this select 0;
	_array = _this select 1;

	{
		if (count _x == 2) then {
			if (count (_x select 0) != 0) then {
				for "_i" from 1 to (_x select 1) do {_unit addItem (_x select 0)};
			};
		};
	} foreach _array;
};

murshun_giveLinkItems = {
	_unit = _this select 0;
	_array = _this select 1;

	{
		if (count _x != 0) then {
			_unit linkItem _x;
		};
	} foreach _array;
};

murshun_fillBox_fnc = {
	_unit = _this select 0;
	_divider = _this select 1;
	
	if (count (_loadoutArray select 1) == 2) then {
		{
			if (count _x == 2) then {
				if (count (_x select 0) != 0) then {
					_unit addItemCargoGlobal [_x select 0, ceil (100 / _divider)];
				};
			};
		} foreach (_loadoutArray select 1 select 0);
	};

	{
		_weaponsArray = _x select 1 select 1;
		
		{
			if (count _x == 3) then {
				_mags = _x select 1;
				
				{
					if (count _x == 2) then {
						if (count (_x select 0) != 0) then {
							_unit addMagazineCargoGlobal [_x select 0, ceil (50 / _divider)];
						};
					};
				} foreach _mags;
			};
		} foreach _weaponsArray;

	} foreach (_loadoutArray select 0);

	{
		if (count _x == 2) then {
			if (count (_x select 0) != 0) then {
				_unit addItemCargoGlobal [_x select 0, ceil ((_x select 1) / _divider)];
			};
		};
	} foreach (_loadoutArray select 2);
};

debugLoadout_fnc = {
	waitUntil {time > 1};

	{
		[_x] execVM "scripts\loadout.sqf";
		[_x] spawn murshun_assignTeam_fnc;
	} foreach switchableUnits - [player];
};

murshun_assignTeam_fnc = {
	_unit = _this select 0;
	_radio_channel = _unit getVariable ["radio_channel", [6, 4]];

	_squad = _radio_channel select 0;
	_team = _radio_channel select 1;

	_teamsArray = ["MAIN", "RED", "GREEN", "BLUE", "YELLOW"];

	waitUntil {time > 1};

	if (_team > 0 and _team < 5) then {
		[[_unit, _teamsArray select _team], "ace_interaction_fnc_joinTeam"] call BIS_fnc_MP;
	};
};

murshun_framework_revivePlayers_fnc = {
	"respawn" setMarkerPos getMarkerPos "base_marker";
	
	{
		[[], "murshun_disableSpectator_fnc", _x] call BIS_fnc_MP;
	} foreach (nearestObjects [spectator_respawn_flag, ["Man"], 10]);

	{
		[[_x, false], "murshun_addToSpectatorArray_fnc", false] call BIS_fnc_MP;
	} foreach murshun_respawnArray;
	
	murshun_respawnArrayLocal = [];
	publicVariable "murshun_respawnArrayLocal";
};

if (!isMultiplayer) then {
	{
		if (!isPlayer _x) then {
			_x disableAI "ANIM";
		};
	} foreach switchableUnits;
	
	[] spawn debugLoadout_fnc;

	[player] spawn BIS_fnc_traceBullets;
};

if (!isNil "ZE_Zeus") then {
	if (isMultiplayer) then {
		deleteVehicle ZE_Zeus;
	};
};

murshun_frameworkInit = true;
