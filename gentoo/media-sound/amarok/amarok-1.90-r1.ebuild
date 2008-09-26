# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

NEED_KDE="4.2"
inherit kde4overlay-base

# Install to KDEDIR rather than /usr, to slot properly.
PREFIX="${KDEDIR}"

DESCRIPTION="Advanced audio player based on KDE framework."
HOMEPAGE="http://amarok.kde.org/"

LICENSE="GPL-2"
KEYWORDS="~x86"
SLOT="4.2"
IUSE="cdaudio daap debug ifp ipod mp3tunes mp4 mtp mysql njb visualization opengl"
SRC_URI="mirror://kde/unstable/${PN}/${PV}/src/${P}.tar.bz2"

# daap are automagic

DEPEND="
	>=app-misc/strigi-0.5.7
	dev-db/sqlite:3
	>=media-libs/taglib-1.5
	|| ( x11-libs/qt-phonon:4 media-sound/phonon )
	kde-base/kdelibs:${SLOT}
	kde-base/libplasma:${SLOT}
	x11-libs/qt-webkit:4
	cdaudio? ( kde-base/libkcompactdisc:${SLOT}
		   kde-base/libkcddb:${SLOT} )
	ifp? ( media-libs/libifp )
	ipod? ( >=media-libs/libgpod-0.4.2 )
	mp3tunes? ( net-misc/curl
		    dev-libs/libxml2 )
	mp4? ( media-libs/libmp4v2 )
	mtp? ( >=media-libs/libmtp-0.3.0 )
	mysql? ( >=virtual/mysql-4.0 )
	njb? ( >=media-libs/libnjb-2.2.4 )
	opengl? ( virtual/opengl )
	visualization? ( media-libs/libsdl
		=media-plugins/libvisual-plugins-0.4* )
	mp3tunes? ( net-misc/curl
		    dev-libs/libxml2 )
	"
RDEPEND="${DEPEND}
	app-arch/unzip
	daap? ( www-servers/mongrel )
	"

src_compile() {
	epatch "${FILESDIR}"/amarok-kde4.2.patch

	if use debug; then
		mycmakeargs="${mycmakeargs} -DCMAKE_BUILD_TYPE=debugfull"
	fi
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX=${PREFIX}
		$(cmake-utils_use_with cdaudio KdeMultimedia)
		$(cmake-utils_use_with ipod Ipod)
		$(cmake-utils_use_with ifp Ifp)
		$(cmake-utils_use_with mp4 Mp4v2)
		$(cmake-utils_use_with mtp Mtp)
		$(cmake-utils_use_with mysql MySQL)
		$(cmake-utils_use_with njb Njb)
		$(cmake-utils_use_with opengl OpenGL)
		$(cmake-utils_use_with visualization Libvisual)
	"
	kde4overlay-base_src_compile
}
