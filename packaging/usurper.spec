Name:           usurper
Version:        %{pkg_version}
Release:        %{pkg_release}%{?dist}
Summary:        Usurper BBS Door Game - classic fantasy multi-player RPG

License:        GPLv2+
URL:            https://github.com/fewtarius/Usurper

BuildArch:      x86_64

%description
Usurper is a classic BBS door game - a fast-paced multi-player fantasy
RPG originally written in Borland Pascal 7.0, now ported to Free Pascal.

Players fight monsters and each other, form gangs, become king, or
ascend to godhood. Sex, drugs, steroids, gangwars, and kicking fantasy.
Runs as a door from BBS software over serial or telnet connections.

%install
rm -rf %{buildroot}

# Create game directory
install -d %{buildroot}/usr/share/games/usurper
install -d %{buildroot}/usr/share/games/usurper/DOCS
install -d %{buildroot}/usr/share/games/usurper/SAMPLES
install -d %{buildroot}/usr/share/games/usurper/TEXT
install -d %{buildroot}/usr/share/games/usurper/UPGRADES
install -d %{buildroot}/usr/share/doc/usurper

# Install binaries
install -m 0755 %{_sourcedir}/USURPER %{buildroot}/usr/share/games/usurper/USURPER
install -m 0755 %{_sourcedir}/EDITOR  %{buildroot}/usr/share/games/usurper/EDITOR

# Install RELEASE content
install -m 0644 %{_sourcedir}/RELEASE/COPYING        %{buildroot}/usr/share/games/usurper/
install -m 0644 %{_sourcedir}/RELEASE/DESC.SDI        %{buildroot}/usr/share/games/usurper/
install -m 0644 %{_sourcedir}/RELEASE/FILE_ID.DIZ     %{buildroot}/usr/share/games/usurper/
install -m 0644 %{_sourcedir}/RELEASE/SDN.ID          %{buildroot}/usr/share/games/usurper/

install -m 0644 %{_sourcedir}/RELEASE/DOCS/*          %{buildroot}/usr/share/games/usurper/DOCS/
install -m 0644 %{_sourcedir}/RELEASE/SAMPLES/*       %{buildroot}/usr/share/games/usurper/SAMPLES/
install -m 0644 %{_sourcedir}/RELEASE/TEXT/*           %{buildroot}/usr/share/games/usurper/TEXT/
install -m 0644 %{_sourcedir}/RELEASE/UPGRADES/*      %{buildroot}/usr/share/games/usurper/UPGRADES/

# Symlink docs
ln -sf /usr/share/games/usurper/DOCS/SYSOP.TXT   %{buildroot}/usr/share/doc/usurper/SYSOP.TXT
ln -sf /usr/share/games/usurper/DOCS/USURPER.TXT  %{buildroot}/usr/share/doc/usurper/USURPER.TXT
ln -sf /usr/share/games/usurper/DOCS/WHATSNEW.TXT %{buildroot}/usr/share/doc/usurper/WHATSNEW.TXT

%files
%license /usr/share/games/usurper/COPYING
/usr/share/games/usurper/USURPER
/usr/share/games/usurper/EDITOR
/usr/share/games/usurper/DESC.SDI
/usr/share/games/usurper/FILE_ID.DIZ
/usr/share/games/usurper/SDN.ID
/usr/share/games/usurper/DOCS/
/usr/share/games/usurper/SAMPLES/
/usr/share/games/usurper/TEXT/
/usr/share/games/usurper/UPGRADES/
/usr/share/doc/usurper/

%changelog
* Sun Mar 15 2026 Usurper Dev Team <fewtarius@steamfork.org> - %{pkg_version}-%{pkg_release}
- Automated release build
