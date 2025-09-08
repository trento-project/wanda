#
# spec file for package trento-wanda
#
# Copyright (c) 2024 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/


Name:           trento-wanda
Version:        0
Release:        0
Summary:        Trento wanda component
License:        Apache-2.0
URL:            https://github.com/trento-project/wanda
Source:         %{name}-%{version}.tar.gz
Source1:        deps.tar.gz
Group:          System/Monitoring
BuildRequires:  elixir >= 1.15
BuildRequires:  elixir-hex
BuildRequires:  erlang-rebar3
BuildRequires:  git-core
BuildRequires:  rust1.88
BuildRequires:  cargo1.88
# avoid conflicting aliases in the rust dependency tree
#!BuildIgnore: cargo
#!BuildIgnore: rust
Requires:       trento-checks

%description
Trento is an open cloud-native web application for SAP Applications administrators.

Within Trento, Wanda is the service responsible to orchestrate Checks executions on the monitored nodes.

%prep
%autosetup -a1

%build
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
export MIX_ENV=prod
export MIX_HOME=/usr/bin
export MIX_REBAR3=/usr/bin/rebar3
export MIX_PATH=/usr/lib/elixir/lib/hex/ebin
mix phx.digest
mix release

%install
mkdir -p %{buildroot}/usr/lib/wanda
cp -a _build/prod/rel/wanda %{buildroot}/usr/lib
install -D -m 0644 packaging/suse/rpm/systemd/trento-wanda.service %{buildroot}%{_unitdir}/trento-wanda.service
install -D -m 0600 packaging/suse/rpm/systemd/trento-wanda.example %{buildroot}/etc/trento/trento-wanda.example

%pre  
%service_add_pre trento-wanda.service  

%post  
%service_add_post trento-wanda.service  

%preun  
%service_del_preun trento-wanda.service  

%postun  
%service_del_postun trento-wanda.service  

%files
/usr/lib/wanda
%{_unitdir}/trento-wanda.service
/etc/trento
/etc/trento/trento-wanda.example

%license LICENSE
%doc README.md guides

%changelog
