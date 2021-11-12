// Copyright 2018-2019 Alexander Kromm (m8f/mmaulwurff)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/

class m8f_ls_EventHandler : EventHandler
{

  // attributes section ////////////////////////////////////////////////////////

  private bool            _isTitlemap;
  private bool            _isInitialized;
  private m8f_ls_Settings _settings;
  private PlayerInfo      _player;
  private Actor           _puffMainhand;
  private Actor           _puffOffhand;

  // overrides section /////////////////////////////////////////////////////////

  override void OnRegister()
  {
    _isInitialized = false;
  }

  override void WorldLoaded(WorldEvent event)
  {
    _isTitlemap = CheckTitlemap();
  }

  override void WorldTick()
  {
    if (_isTitlemap) { return; }

    if (!_isInitialized) { SetupPuff(players[consolePlayer]); }

    if (!_puffMainhand && !_puffOffhand) { return; }

    _puffMainhand.bInvisible = true;
    _puffOffhand.bInvisible = true;

    _settings.maybeUpdate(_player);

    bool showLaserSight = CVar.GetCVar("m8f_wm_ShowLaserSight", _player).GetInt();
    if (!showLaserSight) { return; }

    CVar targetCVar       = CVar.GetCVar("m8f_ts_has_target", _player);
    CVar friendlyCVar     = CVar.GetCVar("m8f_ts_friendly_target", _player);
    bool hasTarget        = (targetCVar   != null && targetCVar.GetInt());
    bool isTargetFriendly = (friendlyCVar != null && friendlyCVar.GetInt());

    bool negative = (_settings.targetColorChange   && hasTarget);
    bool friendly = (_settings.friendlyColorChange && isTargetFriendly);

    ShowLaserSight(negative, friendly, _player);
  }

  // methods section ///////////////////////////////////////////////////////////

  private void SetupPuff(PlayerInfo player)
  {
    if (player == null) { return; }

    // clear existing laser points
    Array<Actor> deleteList;
    let iterator = ThinkerIterator.Create("m8f_ls_LaserPuff");
    Actor toDelete;
    while (toDelete = Actor(iterator.next(true)))
    {
      deleteList.push(toDelete);
    }
    int size = deleteList.size();
    for (int i = 0; i < size; ++i)
    {
      deleteList[i].Destroy();
    }

    _player        = players[consolePlayer];
    _settings      = new("m8f_ls_Settings").init(_player);
    _puffMainhand  = Actor.Spawn("m8f_ls_LaserPuff");
    _puffOffhand   = Actor.Spawn("m8f_ls_LaserPuff");
    _isInitialized = true;

    _puffMainhand.bInvisible = true;
    _puffOffhand.bInvisible = true;
  }

  private void ShowLaserSight(bool negative, bool friendly, PlayerInfo player)
  {
    Actor a = player.mo;
    if (a == null) { return; }

    double pitch = a.AimTarget() ? a.BulletSlope(null, ALF_PORTALRESTRICT) : a.pitch;

    if (player.ReadyWeapon != null)
    {
      MaybeShowDot(pitch, a, negative, friendly, 0);
    }
    if (player.OffhandWeapon != null)
    {
      MaybeShowDot(pitch, a, negative, friendly, 1);
    }
  }

  private void MaybeShowDot(double pitch, Actor a, bool negative, bool friendly, int hand)
  {
    if (_settings.hideWithMeleeWeapon && IsMeleeWeapon(_player, hand)) { return; }
    if (_settings.onlyWhenReady && !IsWeaponReady(_player, hand)) { return; }
    Actor  tempPuff = a.LineAttack( a.angle
                                  , 4000.0
                                  , pitch
                                  , 0
                                  , "none"
                                  , "m8f_ls_InvisiblePuff"
                                  , lFlags | (!!hand ? LAF_ISOFFHAND : 0)
                                  );

    if (tempPuff == null) { return; }

    double distance = a.Distance3D(tempPuff);
    if (_settings.hideOnCloseDistance && distance < minDistance) { return; }

    double scale   = _settings.scale * distance / 250.0;
    double opacity = _settings.opacity;

    string shade;
    if (friendly)      { shade = _settings.friendlyColor; }
    else if (negative) { shade = _settings.targetColor;   }
    else               { shade = _settings.noTargetColor; }

    let _puff = !!hand ? _puffOffhand : _puffMainhand;
    _puff.SetShade(shade);
    _puff.scale.x    = scale;
    _puff.scale.y    = scale;
    _puff.bInvisible = false;
    _puff.alpha      = opacity;
    _puff.SetOrigin(tempPuff.pos, true);
  }

  // static functions section //////////////////////////////////////////////////

  private play static bool IsMeleeWeapon(PlayerInfo player, int hand)
  {
    Weapon w = !!hand ? player.OffhandWeapon : player.ReadyWeapon;
    if (w == null) { return false; }

    return w.bMeleeWeapon;
    // int located;
    // int slot;
    // [located, slot] = player.weapons.LocateWeapon(w.GetClassName());

    // bool slot1 = (slot == 1);
    // return slot1;
  }

  private static bool CheckTitlemap()
  {
    bool isTitlemap = (level.mapname == "TITLEMAP");
    return isTitlemap;
  }

  private static bool IsWeaponReady(PlayerInfo player, int hand)
  {
    if (!player) { return false; }
    int readystate = !!hand ? WF_OFFHANDREADY : WF_WEAPONREADY;
    int altstate = !!hand ? WF_OFFHANDREADYALT : WF_WEAPONREADYALT;
    bool isReady = (player.WeaponState & readystate)
      || (player.WeaponState & altstate);

    return isReady;
  }

  // constants section /////////////////////////////////////////////////////////

  const minDistance = 50.0;
  const lFlags      = LAF_NOIMPACTDECAL | LAF_NORANDOMPUFFZ;

} // class m8f_ls_EventHandler
