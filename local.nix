let
  path = toString ../yukigram-worktree/out/Debug;
  yukigram-data = pkgs:
    pkgs.stdenv.mkDerivation {
      name = "yukigram-data";
      src = ../yukigram-worktree/app/share;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share
        cp -r $src/. $out/share/
      '';
    };
  yukigram-fhs-env = pkgs:
    pkgs.buildFHSEnv {
      name = "yukigram-dev-env";
      targetPkgs = p:
        with p; [
          libgcc
          fontconfig
          freetype
          glib
          libX11
          wayland
          mesa
          gtk3
          libxkbcommon
          xkeyboard-config
          libGL
          webkitgtk_4_1
          dbus
          kdePackages.breeze-icons
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          pulseaudio
          pango
          cairo
          (yukigram-data p)
        ];
      executableName = "yukigram";
      runScript = path + "/io.github.yukigram.devel";
    };
  yukigram' = pkgs:
    pkgs.symlinkJoin {
      name = "yukigram-local";
      paths = [
        (yukigram-fhs-env pkgs)
        (yukigram-data pkgs)
      ];
      meta.mainProgram = "yukigram";
    };
  customNixpakConfig = {pkgs, ...}: {
    bubblewrap.bind.ro = [path];
    app.package = pkgs.lib.mkForce (yukigram' pkgs);
  };
  d = import ./. {};
  o = prev: {
    nixpak.yukigram = prev.nixpak.yukigram.override {
      appId = "io.github.yukigram.devel";
      inherit customNixpakConfig;
    };
  };
  d' = d.override o;
in
  d'.packages.nixpak
