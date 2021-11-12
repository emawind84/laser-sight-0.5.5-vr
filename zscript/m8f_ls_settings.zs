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

class m8f_ls_Settings
{

  bool   targetColorChange;
  bool   friendlyColorChange;

  bool   hideWithMeleeWeapon;
  bool   hideOnCloseDistance;
  bool   onlyWhenReady;

  string noTargetColor;
  string targetColor;
  string friendlyColor;

  double scale;
  double opacity;

  private void read(PlayerInfo player)
  {
    targetColorChange   = CVar.GetCVar("m8f_wm_TSChangeLaserColor"    , player).GetInt();
    friendlyColorChange = CVar.GetCVar("m8f_ls_TSChangeColorFriendly" , player).GetInt();

    hideWithMeleeWeapon = CVar.GetCVar("m8f_ls_HideWithMeleeWeapon"   , player).GetInt();
    hideOnCloseDistance = CVar.GetCVar("m8f_ls_hide_close"            , player).GetInt();
    onlyWhenReady       = CVar.GetCVar("m8f_ls_OnlyWhenReady"         , player).GetInt();

    noTargetColor       = CVar.GetCVar("m8f_ls_CustomColor"           , player).GetString();
    targetColor         = CVar.GetCVar("m8f_ls_ColorOnTarget"         , player).GetString();
    friendlyColor       = CVar.GetCVar("m8f_ls_FriendlyColor"         , player).GetString();

    scale               = CVar.GetCVar("m8f_ls_Scale"                 , player).GetFloat();
    opacity             = CVar.GetCVar("m8f_ls_Opacity"               , player).GetFloat();
  }

  m8f_ls_Settings init(PlayerInfo player)
  {
    read(player);
    return self;
  }

  void maybeUpdate(PlayerInfo player)
  {
    int optionsUpdatePeriod = CVar.GetCVar("m8f_ls_UpdatePeriod", player).GetInt();

    if (optionsUpdatePeriod == 0) { read(player); }

    else if (optionsUpdatePeriod != -1
             && (level.time % optionsUpdatePeriod) == 0)
    {
      read(player);
    }
  }

} // class m8f_ls_Settings
