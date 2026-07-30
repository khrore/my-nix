{
  lib,
  mylib,
  system,
  ...
}:

let
  isDarwin = mylib.isDarwin system;
  isLinux = mylib.isLinux system;
  weeklyDarwinInterval = [
    {
      Weekday = 7;
      Hour = 3;
      Minute = 15;
    }
  ];
in
{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    }
    // lib.optionalAttrs isLinux {
      dates = "weekly";
    }
    // lib.optionalAttrs isDarwin {
      interval = weeklyDarwinInterval;
    };

    optimise = {
      automatic = true;
    }
    // lib.optionalAttrs isLinux {
      dates = [ "weekly" ];
    }
    // lib.optionalAttrs isDarwin {
      interval = weeklyDarwinInterval;
    };
  };
}
