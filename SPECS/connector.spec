%{!?_httpd_modsecdir: %global _httpd_modsecdir %{_sysconfdir}/httpd/modsecurity.d}
%{!?_httpd_confdir: %global _httpd_confdir %{_sysconfdir}/httpd/conf.d}

%global rundir /run

Name:   mod_security-clamav-connector
Version:  2.0
Release:  2%{?dist}
Summary:  mod_security to ClamAV connector
Group:    System Environment/Daemons
License:  ASL 2.0
BuildArch: noarch 
URL:    https://github.com/apisnetworks/mod_security-clamav-connector
Source0:  runAV.lua
Source1:  mod_security-clamav.conf
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(id -nu)
BuildRequires:  httpd-devel >= 2.4, 
Requires: mod_security, clamav

%description
mod_security-clamav-connector provides an anti-virus scanner and rejection
policy for file uploads in Apache.

%prep

%build

%install
install -Dm 750 %{SOURCE0} %{buildroot}%{_httpd_modsecdir}/runAV.lua
install -Dp -m 0644 %{SOURCE1} %{buildroot}%{_httpd_modsecdir}/activated_rules/clamav-post.conf

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%config(noreplace) %{_httpd_modsecdir}/activated_rules/clamav-post.conf
%attr(750,root,apache) %{_httpd_modsecdir}/runAV.lua

%changelog
* Sat Aug 07 2021 Matt Saladna <matt@apisnetworks.com> - 2.0-2
- ClamAV bypass marker
* Wed Feb 12 2020 Matt Saladna <matt@apisnetworks.com> - 2.0-1
- Downgrade "Inspection" notice to debug level
* Thu Dec 05 2019 Matt Saladna <matt@apisnetworks.com> - 2.0-0
- Switch scanner to Lua script
* Sat May 26 2018 Matt Saladna <matt@apisnetworks.com> - 1.0-0
- Initial release
